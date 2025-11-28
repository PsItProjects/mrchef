import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/merchant/services/merchant_chat_service.dart';

class MerchantChatController extends GetxController {
  final MerchantChatService _chatService = MerchantChatService();
  final ApiClient _apiClient = ApiClient.instance;

  // Observable state
  final Rx<ConversationModel?> conversation = Rx<ConversationModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxInt highlightedMessageId = 0.obs;

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

  late int conversationId;

  // Customer info from order
  String? customerName;
  String? customerPhone;

  @override
  void onInit() {
    super.onInit();

    // Get conversation ID from route parameters
    conversationId = int.parse(Get.parameters['id'] ?? '0');

    // Get conversation from arguments if passed
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;

      if (args.containsKey('conversation')) {
        final convData = args['conversation'];
        if (convData is ConversationModel) {
          conversation.value = convData;
        } else if (convData is Map<String, dynamic>) {
          conversation.value = ConversationModel.fromJson(convData);
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
                customerName = nameData;
              } else if (nameData is Map) {
                customerName = nameData['current']?.toString() ??
                    nameData['en']?.toString();
              } else {
                customerName = customerData['full_name']?.toString() ??
                    '${customerData['first_name'] ?? ''} ${customerData['last_name'] ?? ''}'
                        .trim();
              }
              // Handle phone - could be 'phone' or 'phone_number'
              customerPhone = customerData['phone']?.toString() ??
                  customerData['phone_number']?.toString();
            }
          }
        }
      }
    }

    loadMessages();
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
      {double? agreedPrice}) async {
    try {
      updatingOrders[orderId] = true;

      final data = <String, dynamic>{'status': newStatus};
      if (agreedPrice != null) {
        data['agreed_price'] = agreedPrice;
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

        Get.snackbar(
          'success'.tr,
          'order_status_updated'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating order status: $e');
      }
      Get.snackbar(
        'error'.tr,
        'error_updating_status'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      updatingOrders[orderId] = false;
    }
  }

  /// Fetch order details by ID and store them
  Future<Map<String, dynamic>?> fetchOrderDetails(int orderId) async {
    if (ordersData.containsKey(orderId)) {
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
      {double? agreedPrice, int? orderId}) async {
    final targetOrderId = orderId ?? orderData.value?['id'];
    if (targetOrderId == null) return false;
    return updateOrderStatusById(targetOrderId, newStatus,
        agreedPrice: agreedPrice);
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Load messages for this conversation
  Future<void> loadMessages() async {
    try {
      isLoading.value = true;

      final fetchedMessages = await _chatService.getMessages(conversationId);
      messages.value = fetchedMessages;

      // Create GlobalKeys for each message
      messageKeys.clear();
      for (var message in messages) {
        messageKeys[message.id] = GlobalKey();
      }

      // Fetch order details for product_attachment messages
      _fetchOrdersFromMessages();

      // Scroll to bottom after loading messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      Get.snackbar(
        'error'.tr,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  /// Send a message
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      isSending.value = true;
      messageController.clear();

      final newMessage =
          await _chatService.sendMessage(conversationId, messageText);
      messages.add(newMessage);
      messageKeys[newMessage.id] = GlobalKey();
      _scrollToBottom();
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      Get.snackbar(
        'error'.tr,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      messageController.text = messageText;
    } finally {
      isSending.value = false;
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
}
