import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/order_model.dart';
import 'package:mrsheaf/features/profile/services/order_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/profile/widgets/order_details_bottom_sheet.dart';

class MyOrdersController extends GetxController {
  // Selected tab index (0: All, 1: Pending, 2: Confirmed, 3: Preparing, 4: Out for Delivery, 5: Delivered, 6: Completed, 7: Cancelled)
  final RxInt selectedTabIndex = 0.obs;

  // All orders
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Error state
  final RxString errorMessage = ''.obs;

  // Search query
  final RxString searchQuery = ''.obs;

  // Search mode
  final RxBool isSearching = false.obs;

  // Tab labels - computed to support language switching
  List<String> get tabLabels => [
    'all'.tr,
    'pending'.tr,
    'confirmed'.tr,
    'preparing'.tr,
    'out_for_delivery'.tr,
    'awaiting_confirmation'.tr,
    'completed'.tr,
    'cancelled'.tr,
  ];

  // Service
  late final OrderService _orderService;

  @override
  void onInit() {
    super.onInit();
    _orderService = OrderService(Get.find<ApiClient>());
    fetchOrders();
  }

  /// Fetch orders from API
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _orderService.getOrders();
      final ordersData = response['orders'] as List;

      allOrders.value = ordersData
          .map((json) => OrderModel.fromJson(json))
          .toList();

      print('✅ ORDERS CONTROLLER: Fetched ${allOrders.length} orders');
    } catch (e) {
      print('❌ ORDERS CONTROLLER: Error fetching orders - $e');
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load orders: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Tab switching
  void switchTab(int index) {
    selectedTabIndex.value = index;
  }

  // Get filtered orders based on selected tab and search query
  List<OrderModel> get filteredOrders {
    // Access observables to trigger reactivity
    final currentTab = selectedTabIndex.value;
    final searching = isSearching.value;
    final query = searchQuery.value;
    final orders = allOrders;

    // First filter by tab
    List<OrderModel> tabFiltered;
    switch (currentTab) {
      case 0: // All
        tabFiltered = orders.toList();
        break;
      case 1: // Pending
        tabFiltered = orders.where((order) => order.status == OrderStatus.pending).toList();
        break;
      case 2: // Confirmed
        tabFiltered = orders.where((order) => order.status == OrderStatus.confirmed).toList();
        break;
      case 3: // Preparing
        tabFiltered = orders.where((order) => order.status == OrderStatus.preparing).toList();
        break;
      case 4: // Out for Delivery
        tabFiltered = orders.where((order) => order.status == OrderStatus.outForDelivery).toList();
        break;
      case 5: // Awaiting Confirmation (delivered)
        tabFiltered = orders.where((order) => order.status == OrderStatus.delivered).toList();
        break;
      case 6: // Completed
        tabFiltered = orders.where((order) => order.status == OrderStatus.completed).toList();
        break;
      case 7: // Cancelled
        tabFiltered = orders.where((order) => order.status == OrderStatus.cancelled || order.status == OrderStatus.rejected).toList();
        break;
      default:
        tabFiltered = orders.toList();
    }

    // Then filter by search query if searching
    if (searching && query.isNotEmpty) {
      final searchQuery = query.toLowerCase();
      return tabFiltered.where((order) {
        // Search in order code
        if (order.orderCode.toLowerCase().contains(searchQuery)) return true;

        // Search in restaurant name
        if (order.restaurantName?.toLowerCase().contains(searchQuery) ?? false) return true;

        // Search in status text
        if (order.statusText.toLowerCase().contains(searchQuery)) return true;

        return false;
      }).toList();
    }

    return tabFiltered;
  }

  // Search methods
  void startSearch() {
    isSearching.value = true;
  }

  void stopSearch() {
    isSearching.value = false;
    searchQuery.value = '';
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Check if current tab has orders
  bool get hasOrdersInCurrentTab {
    // Access observables to trigger reactivity
    final currentTab = selectedTabIndex.value;
    final searching = isSearching.value;
    final query = searchQuery.value;
    final orders = allOrders;

    return filteredOrders.isNotEmpty;
  }

  // Get current tab title
  String get currentTabTitle => tabLabels[selectedTabIndex.value];

  // Order actions
  void viewOrderDetails(OrderModel order) {
    Get.bottomSheet(
      OrderDetailsBottomSheet(orderId: order.id),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void reorderItems(OrderModel order) {
    Get.snackbar(
      'Reorder',
      'Reordering items from ${order.orderCode}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Add items to cart and navigate to cart
  }

  /// Confirm delivery of an order
  Future<void> confirmDelivery(OrderModel order) async {
    try {
      isLoading.value = true;

      await _orderService.confirmDelivery(order.id);

      Get.snackbar(
        'delivery_confirmed'.tr,
        'order_confirmed_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
      );

      // Refresh orders to update the list
      await fetchOrders();
    } catch (e) {
      print('❌ ORDERS CONTROLLER: Error confirming delivery - $e');
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigation
  void goToHomePage() {
    Get.offAllNamed('/home');
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
