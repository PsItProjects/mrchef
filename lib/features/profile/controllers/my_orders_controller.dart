import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/order_model.dart';

class MyOrdersController extends GetxController {
  // Selected tab index (0: Delivered, 1: Processing, 2: Canceled)
  final RxInt selectedTabIndex = 0.obs;
  
  // All orders
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // _initializeSampleData(); // Temporarily disabled to test empty state
  }

  void _initializeSampleData() {
    // Add sample orders
    allOrders.addAll([
      OrderModel(
        orderCode: '#75653448',
        orderDate: DateTime(2022, 3, 20),
        quantity: 3,
        totalAmount: 150.0,
        status: OrderStatus.delivered,
      ),
      OrderModel(
        orderCode: '#75653449',
        orderDate: DateTime(2022, 3, 18),
        quantity: 2,
        totalAmount: 85.0,
        status: OrderStatus.delivered,
      ),
      OrderModel(
        orderCode: '#75653450',
        orderDate: DateTime(2022, 3, 15),
        quantity: 1,
        totalAmount: 45.0,
        status: OrderStatus.processing,
      ),
      OrderModel(
        orderCode: '#75653451',
        orderDate: DateTime(2022, 3, 12),
        quantity: 4,
        totalAmount: 200.0,
        status: OrderStatus.canceled,
      ),
    ]);
  }

  // Tab switching
  void switchTab(int index) {
    selectedTabIndex.value = index;
  }

  // Get filtered orders based on selected tab
  List<OrderModel> get filteredOrders {
    switch (selectedTabIndex.value) {
      case 0: // Delivered
        return allOrders.where((order) => order.status == OrderStatus.delivered).toList();
      case 1: // Processing
        return allOrders.where((order) => order.status == OrderStatus.processing).toList();
      case 2: // Canceled
        return allOrders.where((order) => order.status == OrderStatus.canceled).toList();
      default:
        return allOrders.toList();
    }
  }

  // Check if current tab has orders
  bool get hasOrdersInCurrentTab => filteredOrders.isNotEmpty;

  // Get tab titles
  List<String> get tabTitles => ['Delivered', 'Processing', 'Canceled'];

  // Get current tab title
  String get currentTabTitle => tabTitles[selectedTabIndex.value];

  // Order actions
  void viewOrderDetails(OrderModel order) {
    Get.snackbar(
      'Order Details',
      'Viewing details for order ${order.orderCode}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to order details screen
  }

  void reorderItems(OrderModel order) {
    Get.snackbar(
      'Reorder',
      'Reordering items from ${order.orderCode}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Add items to cart and navigate to cart
  }

  // Navigation
  void goToHomePage() {
    Get.offAllNamed('/home');
  }

  // Add sample data for testing
  void addSampleData() {
    _initializeSampleData();
  }

  // Clear all orders for testing empty state
  void clearAllOrders() {
    allOrders.clear();
  }

  // Getters for UI
  bool get isDeliveredTabSelected => selectedTabIndex.value == 0;
  bool get isProcessingTabSelected => selectedTabIndex.value == 1;
  bool get isCanceledTabSelected => selectedTabIndex.value == 2;

  // Get count for each status
  int get deliveredCount => allOrders.where((order) => order.status == OrderStatus.delivered).length;
  int get processingCount => allOrders.where((order) => order.status == OrderStatus.processing).length;
  int get canceledCount => allOrders.where((order) => order.status == OrderStatus.canceled).length;
}
