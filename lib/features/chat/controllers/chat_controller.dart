import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/services/fcm_service.dart';
import 'package:mrsheaf/core/services/realtime_chat_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/chat/services/chat_service.dart';
import 'package:mrsheaf/features/support/services/support_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final SupportService _supportService = SupportService();
  final ImagePicker _imagePicker = ImagePicker();
  final ApiClient _apiClient = ApiClient.instance;

  // Observable state
  final Rx<ConversationModel?> conversation = Rx<ConversationModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isUploadingImage = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxInt highlightedMessageId = 0.obs;
  final RxBool isOtherTyping = false.obs;

  // Order data for product attachment cards (orderId -> orderData)
  final RxMap<int, Map<String, dynamic>> ordersData =
      <int, Map<String, dynamic>>{}.obs;
  final RxMap<int, bool> confirmingOrders = <int, bool>{}.obs;

  // Text controller for message input
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // GlobalKeys for each message to enable scrolling to specific messages
  final Map<int, GlobalKey> messageKeys = {};

  // Real-time subscriptions
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;

  int? conversationId;
  int? repliedToMessageId; // For storing the message ID to reply to

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
      }
    }

    if (conversationId == null || conversationId == 0) {
      if (kDebugMode) {
        print('❌ CUSTOMER CHAT: Invalid conversation ID');
        print('   Parameters: ${Get.parameters}');
        print('   Arguments: ${Get.arguments}');
      }
      ToastService.showError('Invalid conversation ID');
      Get.back();
      return;
    }

    if (kDebugMode) {
      print('✅ CUSTOMER CHAT: Initialized with conversationId: $conversationId');
    }

    // Get conversation from arguments if passed
    if (Get.arguments != null) {
      if (Get.arguments is ConversationModel) {
        conversation.value = Get.arguments as ConversationModel;
      } else if (Get.arguments is Map<String, dynamic>) {
        final args = Get.arguments as Map<String, dynamic>;

        // Check if conversation data is passed
        if (args.containsKey('conversation')) {
          final convData = args['conversation'];
          if (convData is ConversationModel) {
            conversation.value = convData;
          } else if (convData is Map<String, dynamic>) {
            conversation.value = ConversationModel.fromJson(convData);
          }
        }

        // Check if orderMessageId is passed (when navigating from order details)
        if (args.containsKey('orderMessageId')) {
          repliedToMessageId = args['orderMessageId'] as int?;
          if (kDebugMode) {
            print('💬 Order message ID set for reply: $repliedToMessageId');
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

  Future<void> reportConversation({required String reason, String? details}) async {
    try {
      if (conversationId == null) return;
      
      await _supportService.reportConversation(
        userType: 'customer',
        conversationId: conversationId!,
        reason: reason,
        details: details,
      );
      ToastService.showSuccess('report_submitted'.tr);
    } catch (e) {
      ToastService.showError(TranslationHelper.tr('error'));
    }
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

    // Listen to new messages with customer user type
    _messagesSubscription =
        realtimeService.listenToMessages(conversationId!, userType: 'customer').listen((receivedMessages) {
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
      }
    });

    // Listen to typing indicator
    _typingSubscription = realtimeService
        .listenToTyping(conversationId!, 'merchant')
        .listen((isTyping) {
      isOtherTyping.value = isTyping;
    });
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

  /// Load messages for this conversation
  Future<void> loadMessages() async {
    try {
      if (conversationId == null) {
        if (kDebugMode) {
          print('❌ CUSTOMER CHAT: Cannot load messages - conversationId is null');
        }
        return;
      }
      
      if (kDebugMode) {
        print('📨 CUSTOMER CHAT: Loading messages for conversation #$conversationId...');
      }
      
      isLoading.value = true;

      final fetchedMessages = await _chatService.getMessages(conversationId!);
      
      if (kDebugMode) {
        print('✅ CUSTOMER CHAT: Fetched ${fetchedMessages.length} messages');
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

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ToastService.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  /// Send a message
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();

    if (messageText.isEmpty || conversationId == null) return;

    try {
      isSending.value = true;

      // Clear input immediately for better UX
      messageController.clear();

      // Send message with optional replied_to_message_id
      final newMessage = await _chatService.sendMessage(
        conversationId!,
        messageText,
        repliedToMessageId: repliedToMessageId,
      );

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

      // Clear replied message reference
      repliedToMessageId = null;

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ToastService.showError(errorMessage);

      // Restore message text on error
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
        repliedToMessageId: repliedToMessageId,
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

      // Clear replied message reference
      repliedToMessageId = null;

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
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

  /// Fetch order details by ID and store them
  Future<Map<String, dynamic>?> fetchOrderDetails(int orderId) async {
    if (ordersData.containsKey(orderId)) {
      return ordersData[orderId];
    }
    try {
      final response = await _apiClient.get('/customer/orders/$orderId');
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

  /// Get order status by ID
  String? getOrderStatus(int orderId) {
    return ordersData[orderId]?['status']?.toString();
  }

  /// Check if order is being confirmed
  bool isOrderConfirming(int orderId) {
    return confirmingOrders[orderId] ?? false;
  }

  /// Confirm delivery for an order (customer confirms receipt)
  Future<bool> confirmDelivery(int orderId) async {
    try {
      confirmingOrders[orderId] = true;

      final response = await _apiClient.post(
        '/customer/orders/$orderId/confirm-delivery',
      );

      if (response.data['success'] == true) {
        // Update local order data
        final updatedOrder = response.data['data']?['order'];
        if (updatedOrder != null) {
          ordersData[orderId] = Map<String, dynamic>.from(updatedOrder);
        } else {
          // Manually update status if API doesn't return full order
          if (ordersData.containsKey(orderId)) {
            ordersData[orderId]!['status'] = 'completed';
            ordersData.refresh();
          }
        }
        ToastService.showSuccess('order_confirmed'.tr);
        return true;
      } else {
        ToastService.showError(
            response.data['message'] ?? 'error'.tr);
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error confirming delivery: $e');
      }
      ToastService.showError('error'.tr);
      return false;
    } finally {
      confirmingOrders[orderId] = false;
    }
  }

  /// Accept price proposal for an order
  Future<bool> acceptPrice(int orderId) async {
    try {
      confirmingOrders[orderId] = true;

      final response = await _apiClient.post(
        '/customer/orders/$orderId/accept-price',
      );

      if (response.data['success'] == true) {
        // Update local order data
        final updatedOrder = response.data['data']?['order'];
        if (updatedOrder != null) {
          ordersData[orderId] = Map<String, dynamic>.from(updatedOrder);
        } else {
          if (ordersData.containsKey(orderId)) {
            ordersData[orderId]!['status'] = 'confirmed';
            ordersData.refresh();
          }
        }
        ToastService.showSuccess('price_accepted'.tr);
        // Reload messages to show the updated status
        await loadMessages();
        return true;
      } else {
        ToastService.showError(
            response.data['message'] ?? 'error'.tr);
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting price: $e');
      }
      ToastService.showError('error'.tr);
      return false;
    } finally {
      confirmingOrders[orderId] = false;
    }
  }

  /// Reject price proposal for an order
  Future<bool> rejectPrice(int orderId) async {
    try {
      confirmingOrders[orderId] = true;

      final response = await _apiClient.post(
        '/customer/orders/$orderId/reject-price',
      );

      if (response.data['success'] == true) {
        // Update local order data
        final updatedOrder = response.data['data']?['order'];
        if (updatedOrder != null) {
          ordersData[orderId] = Map<String, dynamic>.from(updatedOrder);
        } else {
          if (ordersData.containsKey(orderId)) {
            ordersData[orderId]!['status'] = 'pending';
            ordersData.refresh();
          }
        }
        ToastService.showSuccess('price_rejected'.tr);
        // Reload messages to show the updated status
        await loadMessages();
        return true;
      } else {
        ToastService.showError(
            response.data['message'] ?? 'error'.tr);
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error rejecting price: $e');
      }
      ToastService.showError('error'.tr);
      return false;
    } finally {
      confirmingOrders[orderId] = false;
    }
  }

  /// Scroll to bottom of messages
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

  /// Scroll to a specific message by ID
  void scrollToMessage(int messageId) {
    final key = messageKeys[messageId];
    if (key == null || key.currentContext == null) {
      print(
          '⚠️ Message key not found or context is null for message #$messageId');
      return;
    }

    // Highlight the message
    highlightedMessageId.value = messageId;

    // Scroll to the message
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.2, // Position message at 20% from top of viewport
    );

    // Remove highlight after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      highlightedMessageId.value = 0;
    });
  }

  /// Refresh messages (pull to refresh)
  Future<void> refreshMessages() async {
    await loadMessages();
  }

  /// Notify that user is typing
  void setTyping(bool isTyping) {
    if (Get.isRegistered<RealtimeChatService>() && conversationId != null) {
      RealtimeChatService.instance
          .setTyping(conversationId!, 'customer', isTyping);
    }
  }
}
