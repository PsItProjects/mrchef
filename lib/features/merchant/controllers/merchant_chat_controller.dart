import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/services/fcm_service.dart';
import 'package:mrsheaf/core/services/realtime_chat_service.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/merchant/services/merchant_chat_service.dart';
import 'package:mrsheaf/features/merchant/services/order_sync_service.dart';
import 'package:mrsheaf/features/support/services/support_service.dart';
import '../../../core/services/toast_service.dart';

class MerchantChatController extends GetxController {
  final MerchantChatService _chatService = MerchantChatService();
  final ApiClient _apiClient = ApiClient.instance;
  final SupportService _supportService = SupportService();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable state
  final Rx<ConversationModel?> conversation = Rx<ConversationModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isUploadingImage = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxInt highlightedMessageId = 0.obs;
  final RxBool isOtherTyping = false.obs;

  // Track updating status per order (orderId -> isUpdating)
  final RxMap<int, bool> updatingOrders = <int, bool>{}.obs;

  // Store order data per order ID (orderId -> orderData)
  final RxMap<int, Map<String, dynamic>> ordersData =
      <int, Map<String, dynamic>>{}.obs;

  // Legacy single order data (for backward compatibility)
  final Rx<Map<String, dynamic>?> orderData = Rx<Map<String, dynamic>?>(null);

  // Text controller for message input
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // GlobalKeys for each message to enable scrolling to specific messages
  final Map<int, GlobalKey> messageKeys = {};

  // Real-time subscriptions
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;

  int? conversationId;

  // Customer info from order or arguments
  String? customerName;
  String? customerPhone;
  String? customerAvatar;

  @override
  void onInit() {
    super.onInit();

    // Get conversation ID from route parameters or arguments
    if (Get.parameters.containsKey('id') && Get.parameters['id'] != null && Get.parameters['id']!.isNotEmpty) {
      conversationId = int.parse(Get.parameters['id']!);
    } else if (Get.arguments != null) {
      // Try to get conversationId from arguments
      if (Get.arguments is int) {
        conversationId = Get.arguments as int;
      } else if (Get.arguments is Map<String, dynamic>) {
        final args = Get.arguments as Map<String, dynamic>;
        // Try both camelCase and snake_case
        if (args.containsKey('conversationId')) {
          conversationId = args['conversationId'] as int?;
        } else if (args.containsKey('conversation_id')) {
          conversationId = args['conversation_id'] as int?;
        }
        // Also try to get from conversation object if present
        if (conversationId == null && args.containsKey('conversation')) {
          final convData = args['conversation'];
          if (convData is ConversationModel) {
            conversationId = convData.id;
          } else if (convData is Map<String, dynamic>) {
            conversationId = convData['id'] as int?;
          }
        }
        // Also try to extract from nested order data
        if (conversationId == null && args.containsKey('order')) {
          final orderData = args['order'];
          if (orderData is Map<String, dynamic>) {
            final convId = orderData['conversation_id'];
            if (convId is int) {
              conversationId = convId;
            } else if (convId != null) {
              conversationId = int.tryParse(convId.toString());
            }
          }
        }
      }
    }

    if (conversationId == null || conversationId == 0) {
      if (kDebugMode) {
        print('❌ MERCHANT CHAT: Invalid conversation ID');
        print('   Parameters: ${Get.parameters}');
        print('   Arguments: ${Get.arguments}');
      }
      // Defer toast and navigation to avoid build-phase errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastService.showError('Invalid conversation ID');
        Get.back();
      });
      return;
    }

    if (kDebugMode) {
      print('✅ MERCHANT CHAT: Initialized with conversationId: $conversationId');
    }

    // Get conversation from arguments if passed
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;

      // Get customer info from arguments (passed from conversations list)
      if (args.containsKey('customer_name')) {
        customerName = args['customer_name']?.toString();
      }
      if (args.containsKey('customer_avatar')) {
        customerAvatar = args['customer_avatar']?.toString();
      }

      if (args.containsKey('conversation')) {
        final convData = args['conversation'];
        if (convData is ConversationModel) {
          conversation.value = convData;
          // Get customer info from conversation if not already set
          customerName ??= convData.customer.name;
          customerAvatar ??= convData.customer.avatar;
        } else if (convData is Map<String, dynamic>) {
          conversation.value = ConversationModel.fromJson(convData);
          customerName ??= conversation.value?.customer.name;
          customerAvatar ??= conversation.value?.customer.avatar;
        }
      }

      if (args.containsKey('order')) {
        final order = args['order'];
        if (order != null && order is Map) {
          orderData.value = Map<String, dynamic>.from(order);

          if (order['customer'] != null) {
            final customerData = order['customer'];
            if (customerData is Map) {
              // Handle name - could be String or Map
              final nameData = customerData['name'];
              if (nameData is String) {
                customerName ??= nameData;
              } else if (nameData is Map) {
                customerName ??= nameData['current']?.toString() ??
                    nameData['en']?.toString();
              } else {
                customerName ??= customerData['full_name']?.toString() ??
                    '${customerData['first_name'] ?? ''} ${customerData['last_name'] ?? ''}'
                        .trim();
              }
              // Handle phone - could be 'phone' or 'phone_number'
              customerPhone = customerData['phone']?.toString() ??
                  customerData['phone_number']?.toString();
              // Handle avatar
              customerAvatar ??= customerData['avatar']?.toString();
            }
          }
        }
      }
    }

    loadMessages();

    // Notify backend that user entered this chat
    _enterChat();

    // Setup real-time listeners
    _setupRealtimeListeners();
  }

  @override
  void onClose() {
    // Cancel subscriptions
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();

    // Notify backend that user left this chat
    _leaveChat();

    // Clean up realtime service
    if (Get.isRegistered<RealtimeChatService>() && conversationId != null) {
      RealtimeChatService.instance.disposeConversation(conversationId!);
    }

    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Setup real-time listeners for messages and typing
  void _setupRealtimeListeners() {
    if (!Get.isRegistered<RealtimeChatService>() || conversationId == null) return;

    final realtimeService = RealtimeChatService.instance;

    // Listen to new messages with merchant user type for proper API calls
    _messagesSubscription =
        realtimeService.listenToMessages(conversationId!, userType: 'merchant').listen((receivedMessages) {
      // IMPORTANT: Never replace messages with empty list!
      if (receivedMessages.isEmpty) {
        if (kDebugMode) {
          print('CHAT: Received empty messages list - keeping current messages');
        }
        return;
      }

      // Check if there are actual changes
      final receivedIds = receivedMessages.map((msg) => msg.id).toSet();
      final currentIds = messages.map((msg) => msg.id).toSet();

      // Only update UI if there are actual new messages or changes
      final hasNewMessages = receivedIds.difference(currentIds).isNotEmpty;
      final hasRemovedMessages = currentIds.difference(receivedIds).isNotEmpty;
      final countChanged = receivedMessages.length != messages.length;

      if (hasNewMessages || hasRemovedMessages || countChanged) {
        if (kDebugMode) {
          print('CHAT: Updating messages (new: $hasNewMessages, removed: $hasRemovedMessages, count: ${receivedMessages.length})');
        }

        // Update the entire list to ensure consistency
        messages.assignAll(receivedMessages);

        // Update message keys only for new messages
        for (var message in receivedMessages) {
          if (!messageKeys.containsKey(message.id)) {
            messageKeys[message.id] = GlobalKey();
          }
        }

        // Scroll to bottom when new messages arrive (like WhatsApp)
        if (hasNewMessages) {
          _forceScrollToBottom();
        }

        // Fetch order details for any new product_attachment messages
        _fetchOrdersFromMessages();

        // Refresh cached order data when new messages arrive
        // This ensures status updates (customer accept/reject price) are reflected
        if (hasNewMessages) {
          _refreshCachedOrders();
        }
      }
    });

    // Listen to typing indicator
    _typingSubscription = realtimeService
        .listenToTyping(conversationId!, 'customer')
        .listen((isTyping) {
      isOtherTyping.value = isTyping;
    });
  }

  Future<void> reportConversation({required String reason, String? details}) async {
    try {
      if (conversationId == null) return;
      
      await _supportService.reportConversation(
        userType: 'merchant',
        conversationId: conversationId!,
        reason: reason,
        details: details,
      );
      ToastService.showSuccess('report_submitted'.tr);
    } catch (e) {
      ToastService.showError(TranslationHelper.tr('error'));
    }
  }

  /// Notify backend that user entered this chat (to prevent push notifications)
  Future<void> _enterChat() async {
    try {
      if (Get.isRegistered<FCMService>() && conversationId != null) {
        await FCMService.instance.enterChat(conversationId!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error entering chat: $e');
      }
    }
  }

  /// Notify backend that user left this chat
  Future<void> _leaveChat() async {
    try {
      if (Get.isRegistered<FCMService>()) {
        await FCMService.instance.leaveChat();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving chat: $e');
      }
    }
  }

  /// Check if specific order is pending and can be approved
  bool canApproveOrderById(int orderId) {
    final order = ordersData[orderId];
    if (order == null) return false;
    return order['status']?.toString() == 'pending';
  }

  /// Check if specific order is being updated
  bool isOrderUpdating(int orderId) {
    return updatingOrders[orderId] ?? false;
  }

  /// Get order status by ID
  String? getOrderStatus(int orderId) {
    return ordersData[orderId]?['status']?.toString();
  }

  /// Get order data by ID
  Map<String, dynamic>? getOrderById(int orderId) {
    return ordersData[orderId];
  }

  /// Legacy getters for backward compatibility
  bool get canApproveOrder {
    final order = orderData.value;
    if (order == null) return false;
    return order['status']?.toString() == 'pending';
  }

  double get orderTotalAmount {
    final order = orderData.value;
    if (order == null) return 0;
    return double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0;
  }

  String get orderNumber {
    final order = orderData.value;
    if (order == null) return '';
    final orderNum = order['order_number'];
    if (orderNum is String) return orderNum;
    if (orderNum is Map) {
      return orderNum['current']?.toString() ??
          orderNum['en']?.toString() ??
          '#${order['id']}';
    }
    return '#${order['id']}';
  }

  /// Update order status for a specific order
  Future<bool> updateOrderStatusById(int orderId, String newStatus,
      {double? agreedPrice, double? agreedDeliveryFee}) async {
    try {
      updatingOrders[orderId] = true;

      final data = <String, dynamic>{'status': newStatus};
      if (agreedPrice != null) {
        data['agreed_price'] = agreedPrice;
      }
      if (agreedDeliveryFee != null) {
        data['agreed_delivery_fee'] = agreedDeliveryFee;
      }

      final response = await _apiClient.patch(
        '/merchant/orders/$orderId/status',
        data: data,
      );

      if (response.data['success'] == true) {
        // Update stored order data
        final updatedOrder =
            Map<String, dynamic>.from(response.data['data']['order']);
        ordersData[orderId] = updatedOrder;

        // Also update legacy orderData if it's the same order
        if (orderData.value?['id'] == orderId) {
          orderData.value = updatedOrder;
        }

        // Broadcast to all other controllers for instant cross-page sync
        OrderSyncService.instance
            .broadcastOrderUpdate(orderId, updatedOrder, fromController: 'chat');

        // Reload messages to show price_proposal / status change messages
        await loadMessages();

        ToastService.showSuccess('order_status_updated'.tr);
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating order status: $e');
      }
      ToastService.showError('error_updating_status'.tr);
      return false;
    } finally {
      updatingOrders[orderId] = false;
    }
  }

  /// Fetch order details by ID and store them
  Future<Map<String, dynamic>?> fetchOrderDetails(int orderId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && ordersData.containsKey(orderId)) {
      return ordersData[orderId];
    }

    try {
      final response = await _apiClient.get('/merchant/orders/$orderId');
      if (response.data['success'] == true) {
        final orderData =
            Map<String, dynamic>.from(response.data['data']['order']);
        ordersData[orderId] = orderData;
        return orderData;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching order details: $e');
      }
    }
    return null;
  }

  /// Legacy update order status
  Future<bool> updateOrderStatus(String newStatus,
      {double? agreedPrice, double? agreedDeliveryFee, int? orderId}) async {
    final targetOrderId = orderId ?? orderData.value?['id'];
    if (targetOrderId == null) return false;
    return updateOrderStatusById(targetOrderId, newStatus,
        agreedPrice: agreedPrice, agreedDeliveryFee: agreedDeliveryFee);
  }

  /// Load messages for this conversation
  Future<void> loadMessages() async {
    try {
      if (conversationId == null) {
        if (kDebugMode) {
          print('❌ MERCHANT CHAT: Cannot load messages - conversationId is null');
        }
        return;
      }
      
      if (kDebugMode) {
        print('📨 MERCHANT CHAT: Loading messages for conversation #$conversationId...');
      }
      
      isLoading.value = true;

      final fetchedMessages = await _chatService.getMessages(conversationId!);
      
      if (kDebugMode) {
        print('✅ MERCHANT CHAT: Fetched ${fetchedMessages.length} messages');
      }
      final seenIds = <int>{};
      final deduped = <MessageModel>[];
      for (final msg in fetchedMessages) {
        if (seenIds.add(msg.id)) {
          deduped.add(msg);
        }
      }
      messages.value = deduped;

      // Create GlobalKeys for each message
      messageKeys.clear();
      for (var message in messages) {
        messageKeys[message.id] = GlobalKey();
      }

      // Fetch order details for product_attachment messages
      _fetchOrdersFromMessages();

      // Scroll to bottom after loading messages (force with multiple attempts)
      _forceScrollToBottom();
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ToastService.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch order details for all product_attachment messages
  void _fetchOrdersFromMessages() {
    for (var message in messages) {
      if (message.messageType == 'product_attachment' &&
          message.attachments != null) {
        final orderId = message.attachments!['order_id'];
        if (orderId != null && !ordersData.containsKey(orderId)) {
          fetchOrderDetails(orderId);
        }
      }
    }
  }

  /// Refresh all cached order data to get latest status
  /// Called when new messages arrive (e.g. customer accept/reject price)
  Future<void> _refreshCachedOrders() async {
    final orderIds = ordersData.keys.toList();
    for (final orderId in orderIds) {
      try {
        await fetchOrderDetails(orderId, forceRefresh: true);
      } catch (e) {
        if (kDebugMode) {
          print('Error refreshing order $orderId: $e');
        }
      }
    }
  }

  /// Send a message
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty || conversationId == null) return;

    try {
      isSending.value = true;
      messageController.clear();

      final newMessage =
          await _chatService.sendMessage(conversationId!, messageText);

      // Add message to list immediately for instant UI feedback
      if (!messages.any((m) => m.id == newMessage.id)) {
        messages.add(newMessage);
        messageKeys[newMessage.id] = GlobalKey();
      }

      // Scroll to bottom immediately to show the sent message
      _scrollToBottom();

      // Sync to Firestore for real-time and add to cache
      if (Get.isRegistered<RealtimeChatService>()) {
        final realtimeService = RealtimeChatService.instance;

        // Add to cache immediately
        realtimeService.addMessageToCache(conversationId!, newMessage);

        // Sync to Firestore
        realtimeService.syncMessageToFirestore(conversationId!, newMessage);

        // Trigger refresh for other participants
        await realtimeService.triggerManualRefresh(conversationId!);
      }

      _scrollToBottom();
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ToastService.showError(errorMessage);
      messageController.text = messageText;
    } finally {
      isSending.value = false;
    }
  }

  /// Pick an image (without sending)
  Future<void> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      selectedImage.value = File(pickedFile.path);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ToastService.showError(errorMessage);
    }
  }

  /// Clear selected image
  void clearSelectedImage() {
    selectedImage.value = null;
  }

  /// Send the selected image
  Future<void> sendSelectedImage() async {
    if (selectedImage.value == null || conversationId == null) return;

    try {
      isUploadingImage.value = true;

      final newMessage = await _chatService.sendImageMessage(
        conversationId!,
        selectedImage.value!,
      );

      // Clear selected image
      selectedImage.value = null;

      // Add message to list immediately for instant UI feedback
      if (!messages.any((m) => m.id == newMessage.id)) {
        messages.add(newMessage);
        messageKeys[newMessage.id] = GlobalKey();
      }

      // Scroll to bottom immediately to show the sent message
      _scrollToBottom();

      // Sync to Firestore for real-time and add to cache
      if (Get.isRegistered<RealtimeChatService>()) {
        final realtimeService = RealtimeChatService.instance;

        // Add to cache immediately
        realtimeService.addMessageToCache(conversationId!, newMessage);

        // Sync to Firestore
        realtimeService.syncMessageToFirestore(conversationId!, newMessage);

        // Trigger refresh for other participants
        await realtimeService.triggerManualRefresh(conversationId!);
      }

      _scrollToBottom();
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ToastService.showError(errorMessage);
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Show image source picker bottom sheet
  void showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.amber),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                pickImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.amber),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                pickImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom({bool immediate = false}) {
    if (!scrollController.hasClients) return;

    if (immediate) {
      // Jump immediately without animation
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    } else {
      // Animate to bottom
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Force scroll to bottom after UI is built (with multiple attempts)
  void _forceScrollToBottom() {
    // First attempt - immediate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(immediate: true);

      // Second attempt after short delay (for images/heavy content)
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom(immediate: true);
      });

      // Third attempt after longer delay (ensure all content is rendered)
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    });
  }

  void scrollToMessage(int messageId) {
    final key = messageKeys[messageId];
    if (key == null || key.currentContext == null) return;

    highlightedMessageId.value = messageId;
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.2,
    );

    Future.delayed(const Duration(seconds: 2), () {
      highlightedMessageId.value = 0;
    });
  }

  Future<void> refreshMessages() async => await loadMessages();

  /// Notify that user is typing
  void setTyping(bool isTyping) {
    if (Get.isRegistered<RealtimeChatService>() && conversationId != null) {
      RealtimeChatService.instance
          .setTyping(conversationId!, 'merchant', isTyping);
    }
  }
}
