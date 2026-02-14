import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/merchant/services/order_sync_service.dart';
import 'package:dio/dio.dart' as dio;
import '../../../core/services/toast_service.dart';

class MerchantOrdersController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable state
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedFilterIndex = 0.obs;
  final RxInt pendingOrdersCount = 0.obs;

  // Pagination
  int currentPage = 1;
  bool hasMorePages = true;

  // Filter statuses
  final List<String?> filterStatuses = [
    null, // All
    'pending',
    'awaiting_customer_approval',
    'confirmed',
    'preparing',
    'ready',
    'out_for_delivery',
    'delivered',
    'completed',
    'cancelled',
  ];

  // Filter labels (keys for translation)
  final List<String> filterLabels = [
    'all',
    'pending',
    'awaiting_customer_approval',
    'confirmed',
    'preparing',
    'ready',
    'out_for_delivery',
    'delivered',
    'completed',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  /// Get current filter status
  String? get currentStatus => filterStatuses[selectedFilterIndex.value];

  /// Load orders from API
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      hasMorePages = true;
    }

    if (!hasMorePages && !refresh) return;

    try {
      if (currentPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      errorMessage.value = '';

      final queryParams = <String, dynamic>{
        'page': currentPage,
      };

      if (currentStatus != null) {
        queryParams['status'] = currentStatus;
      }

      final response = await _apiClient.get(
        '/merchant/orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final ordersData = response.data['data']['orders'];
        final List<Map<String, dynamic>> newOrders = [];

        if (ordersData is Map && ordersData['data'] != null) {
          // Paginated response
          for (var order in ordersData['data']) {
            newOrders.add(Map<String, dynamic>.from(order));
          }
          hasMorePages = ordersData['next_page_url'] != null;
        } else if (ordersData is List) {
          for (var order in ordersData) {
            newOrders.add(Map<String, dynamic>.from(order));
          }
          hasMorePages = false;
        }

        if (currentPage == 1) {
          orders.value = newOrders;
        } else {
          orders.addAll(newOrders);
        }

        currentPage++;

        // Count pending orders
        _countPendingOrders();
      } else {
        errorMessage.value = response.data['message'] ?? 'error'.tr;
      }
    } on dio.DioException catch (e) {
      debugPrint('Error loading orders: ${e.message}');
      errorMessage.value = 'error_loading_orders'.tr;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      errorMessage.value = 'unexpected_error'.tr;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Count pending orders
  void _countPendingOrders() {
    pendingOrdersCount.value =
        orders.where((o) => o['status'] == 'pending').length;
  }

  /// Change filter
  void changeFilter(int index) {
    if (selectedFilterIndex.value != index) {
      selectedFilterIndex.value = index;
      loadOrders(refresh: true);
    }
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
  }

  /// Load more orders
  Future<void> loadMoreOrders() async {
    if (!isLoadingMore.value && hasMorePages) {
      await loadOrders();
    }
  }

  /// Get translated status text
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TranslationHelper.isArabic ? 'معلق' : 'Pending';
      case 'awaiting_customer_approval':
        return TranslationHelper.isArabic ? 'بانتظار موافقة العميل' : 'Awaiting Approval';
      case 'confirmed':
        return TranslationHelper.isArabic ? 'مؤكد' : 'Confirmed';
      case 'preparing':
        return TranslationHelper.isArabic ? 'قيد التحضير' : 'Preparing';
      case 'ready':
        return TranslationHelper.isArabic ? 'جاهز' : 'Ready';
      case 'out_for_delivery':
        return TranslationHelper.isArabic ? 'في الطريق' : 'Out for Delivery';
      case 'delivered':
        return TranslationHelper.isArabic ? 'بانتظار تأكيد الاستلام' : 'Awaiting Confirmation';
      case 'completed':
        return TranslationHelper.isArabic ? 'تم التوصيل' : 'Delivered';
      case 'cancelled':
        return TranslationHelper.isArabic ? 'ملغي' : 'Cancelled';
      case 'rejected':
        return TranslationHelper.isArabic ? 'مرفوض' : 'Rejected';
      default:
        return status;
    }
  }

  /// Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'awaiting_customer_approval':
        return const Color(0xFFFACD02);
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'out_for_delivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.amber; // Awaiting customer confirmation
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get filter label
  String getFilterLabel(int index) {
    final label = filterLabels[index];
    switch (label) {
      case 'all':
        return TranslationHelper.isArabic ? 'الكل' : 'All';
      case 'pending':
        return TranslationHelper.isArabic ? 'جديد' : 'New';
      case 'awaiting_customer_approval':
        return TranslationHelper.isArabic ? 'بانتظار الموافقة' : 'Awaiting Approval';
      case 'confirmed':
        return TranslationHelper.isArabic ? 'مؤكد' : 'Confirmed';
      case 'preparing':
        return TranslationHelper.isArabic ? 'قيد التحضير' : 'Preparing';
      case 'ready':
        return TranslationHelper.isArabic ? 'جاهز' : 'Ready';
      case 'out_for_delivery':
        return TranslationHelper.isArabic ? 'في الطريق' : 'On the way';
      case 'delivered':
        return TranslationHelper.isArabic ? 'بانتظار التأكيد' : 'Awaiting Confirmation';
      case 'completed':
        return TranslationHelper.isArabic ? 'مكتمل' : 'Completed';
      case 'cancelled':
        return TranslationHelper.isArabic ? 'ملغي' : 'Cancelled';
      default:
        return label;
    }
  }

  /// Navigate to order details
  void openOrderDetails(int orderId) {
    Get.toNamed('/merchant/order-details', arguments: {'orderId': orderId});
  }

  /// Update order status with optional agreed price
  Future<bool> updateOrderStatus(int orderId, String newStatus,
      {double? agreedPrice, double? agreedDeliveryFee}) async {
    try {
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

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update local order
        final updatedOrder =
            Map<String, dynamic>.from(response.data['data']['order']);
        final index = orders.indexWhere((o) => o['id'] == orderId);
        if (index != -1) {
          orders[index] = updatedOrder;
          orders.refresh();
        }
        _countPendingOrders();

        // Broadcast to all other controllers for instant cross-page sync
        OrderSyncService.instance.broadcastOrderUpdate(
            orderId, updatedOrder,
            fromController: 'ordersList');

        ToastService.showSuccess('order_status_updated'.tr);
        return true;
      } else {
        ToastService.showError(response.data['message'] ?? 'error_updating_status'.tr);
        return false;
      }
    } on dio.DioException catch (e) {
      debugPrint('Error updating status: ${e.message}');
      ToastService.showError('error_updating_status'.tr);
      return false;
    }
  }
}
