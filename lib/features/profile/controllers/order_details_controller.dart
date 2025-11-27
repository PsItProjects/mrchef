import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/profile/models/order_details_model.dart';
import 'package:mrsheaf/features/profile/services/order_service.dart';

class OrderDetailsController extends GetxController {
  late final OrderService _orderService;
  late int _currentOrderId;

  // Observables
  final Rx<OrderDetailsModel?> orderDetails = Rx<OrderDetailsModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize OrderService with ApiClient
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

  /// Navigate to chat with restaurant
  void openChat() {
    if (orderDetails.value?.restaurantId != null) {
      // TODO: Navigate to chat screen
      if (kDebugMode) {
        print('💬 Opening chat with restaurant #${orderDetails.value?.restaurantId}');
      }
    }
  }

  /// Call restaurant
  void callRestaurant() {
    if (orderDetails.value?.restaurantPhone != null) {
      // TODO: Implement phone call
      if (kDebugMode) {
        print('📞 Calling restaurant: ${orderDetails.value?.restaurantPhone}');
      }
    }
  }
}

