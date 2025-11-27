import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/profile/models/order_details_model.dart';
import 'package:mrsheaf/features/profile/services/order_service.dart';
import 'package:mrsheaf/features/chat/services/chat_service.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';

class OrderDetailsController extends GetxController {
  late final OrderService _orderService;
  final ChatService _chatService = ChatService();
  late int _currentOrderId;

  // Observables
  final Rx<OrderDetailsModel?> orderDetails = Rx<OrderDetailsModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Constructor - Initialize services
  OrderDetailsController() {
    _orderService = OrderService(Get.find<ApiClient>());
  }

  /// Load order details from API
  Future<void> loadOrderDetails(int orderId) async {
    try {
      _currentOrderId = orderId;
      isLoading.value = true;
      errorMessage.value = '';

      if (kDebugMode) {
        print('📦 ORDER DETAILS: Loading order #$orderId...');
      }

      final data = await _orderService.getOrderDetails(orderId);
      orderDetails.value = OrderDetailsModel.fromJson(data);

      if (kDebugMode) {
        print('✅ ORDER DETAILS: Loaded successfully');
        print('📦 ORDER: ${orderDetails.value?.orderNumber}');
        print('🍽️ ITEMS: ${orderDetails.value?.items.length}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load order details';
      if (kDebugMode) {
        print('❌ ORDER DETAILS: Error loading - $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh order details
  Future<void> refreshOrderDetails() async {
    await loadOrderDetails(_currentOrderId);
  }

  /// Cancel order
  Future<void> cancelOrder({String? reason}) async {
    try {
      if (kDebugMode) {
        print('🚫 ORDER DETAILS: Cancelling order #$_currentOrderId...');
      }

      final success = await _orderService.cancelOrder(_currentOrderId, reason: reason);

      if (success) {
        if (kDebugMode) {
          print('✅ ORDER DETAILS: Order cancelled successfully');
        }

        // Reload order details to get updated status
        await loadOrderDetails(_currentOrderId);

        Get.snackbar(
          'Success',
          'Order cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ORDER DETAILS: Error cancelling order - $e');
      }

      Get.snackbar(
        'Error',
        'Failed to cancel order',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate to chat with restaurant for this order
  Future<void> openChat() async {
    try {
      if (kDebugMode) {
        print('💬 Opening chat for order #$_currentOrderId...');
      }

      final order = orderDetails.value;
      if (order == null) {
        if (kDebugMode) {
          print('❌ No order details available');
        }
        return;
      }

      // Check if order has conversation_id
      final conversationId = order.conversationId;

      if (conversationId == null) {
        if (kDebugMode) {
          print('⚠️ Order has no conversation_id, creating new conversation...');
        }

        // Show loading indicator
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFACD02),
            ),
          ),
          barrierDismissible: false,
        );

        // Get or create conversation for this order
        final result = await _chatService.getOrCreateOrderConversation(_currentOrderId);
        final conversation = result['conversation'] as ConversationModel;
        final orderMessageId = result['orderMessageId'] as int?;

        // Close loading dialog
        Get.back();

        // Close order details bottom sheet
        Get.back();

        // Navigate to chat screen with arguments
        Get.toNamed(
          AppRoutes.CHAT.replaceAll(':id', conversation.id.toString()),
          arguments: {
            'orderMessageId': orderMessageId,
          },
        );

        if (kDebugMode) {
          print('✅ Navigated to new conversation #${conversation.id}');
          print('✅ Order message ID: $orderMessageId');
        }
      } else {
        // Order has conversation_id, navigate directly to it
        if (kDebugMode) {
          print('✅ Order has conversation_id: $conversationId, navigating...');
        }

        // Close order details bottom sheet
        Get.back();

        // Navigate to chat screen with the original conversation
        // We need to get the order message ID from the backend
        Get.toNamed(
          AppRoutes.CHAT.replaceAll(':id', conversationId.toString()),
          arguments: {
            'fromOrder': true,
          },
        );

        if (kDebugMode) {
          print('✅ Navigated to original conversation #$conversationId');
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (kDebugMode) {
        print('❌ Error opening chat: $e');
      }

      Get.snackbar(
        'Error',
        'Failed to open chat. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

