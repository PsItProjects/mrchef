import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_chat_controller.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_orders_controller.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_order_details_controller.dart';

/// Centralized service to synchronize order state across all merchant controllers.
/// Ensures that when an order status changes in one screen (chat, orders list, order details),
/// it is instantly reflected across all other active screens.
class OrderSyncService extends GetxService {
  static OrderSyncService get instance {
    if (!Get.isRegistered<OrderSyncService>()) {
      Get.put(OrderSyncService(), permanent: true);
    }
    return Get.find<OrderSyncService>();
  }

  /// Broadcast an order update to all registered controllers.
  /// Called after a successful API status-update from ANY controller.
  void broadcastOrderUpdate(int orderId, Map<String, dynamic> updatedOrder,
      {String? fromController}) {
    if (kDebugMode) {
      print(
          '🔄 OrderSync: Broadcasting update for order #$orderId (status: ${updatedOrder['status']}) from $fromController');
    }

    // ── Sync to MerchantChatController ──
    if (fromController != 'chat' &&
        Get.isRegistered<MerchantChatController>()) {
      try {
        final chatCtrl = Get.find<MerchantChatController>();
        chatCtrl.ordersData[orderId] = updatedOrder;
        // Also refresh legacy single order if it matches
        if (chatCtrl.orderData.value?['id'] == orderId) {
          chatCtrl.orderData.value = updatedOrder;
        }
        if (kDebugMode) {
          print('   ✅ Synced to MerchantChatController');
        }
      } catch (e) {
        if (kDebugMode) print('   ⚠ Error syncing to chat: $e');
      }
    }

    // ── Sync to MerchantOrdersController ──
    if (fromController != 'ordersList' &&
        Get.isRegistered<MerchantOrdersController>()) {
      try {
        final ordersCtrl = Get.find<MerchantOrdersController>();
        final idx = ordersCtrl.orders.indexWhere((o) => o['id'] == orderId);
        if (idx != -1) {
          ordersCtrl.orders[idx] = Map<String, dynamic>.from(updatedOrder);
          ordersCtrl.orders.refresh();
        }
        if (kDebugMode) {
          print('   ✅ Synced to MerchantOrdersController');
        }
      } catch (e) {
        if (kDebugMode) print('   ⚠ Error syncing to orders list: $e');
      }
    }

    // ── Sync to MerchantOrderDetailsController ──
    if (fromController != 'orderDetails' &&
        Get.isRegistered<MerchantOrderDetailsController>()) {
      try {
        final detailsCtrl = Get.find<MerchantOrderDetailsController>();
        if (detailsCtrl.orderId == orderId) {
          detailsCtrl.order.value = Map<String, dynamic>.from(updatedOrder);
          detailsCtrl.order.refresh();
        }
        if (kDebugMode) {
          print('   ✅ Synced to MerchantOrderDetailsController');
        }
      } catch (e) {
        if (kDebugMode) print('   ⚠ Error syncing to order details: $e');
      }
    }
  }

  /// Force re-fetch order data from API and broadcast to all controllers.
  /// Useful when we receive a push notification about an order change.
  Future<void> forceRefreshOrder(int orderId) async {
    if (Get.isRegistered<MerchantChatController>()) {
      try {
        final chatCtrl = Get.find<MerchantChatController>();
        // Remove from cache so fetchOrderDetails will re-fetch
        chatCtrl.ordersData.remove(orderId);
        final updated = await chatCtrl.fetchOrderDetails(orderId);
        if (updated != null) {
          broadcastOrderUpdate(orderId, updated, fromController: 'chat');
        }
      } catch (e) {
        if (kDebugMode) print('OrderSync: Error force-refreshing: $e');
      }
    }
  }
}
