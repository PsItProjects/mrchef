import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:dio/dio.dart' as dio;

class MerchantDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable variables
  var isLoading = false.obs;
  var merchantName = ''.obs;
  var merchantEmail = ''.obs;

  // Dashboard data
  var todayOrders = 0.obs;
  var todayRevenue = 0.0.obs;
  var weekOrders = 0.obs;
  var weekRevenue = 0.0.obs;
  var recentOrders = <Map<String, dynamic>>[].obs;
  var profileCompletion = 0.obs;
  var totalProducts = 0.obs;
  var activeProducts = 0.obs;
  var restaurantData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _loadMerchantData();
    loadDashboardData();
  }

  void _loadMerchantData() {
    try {
      final user = _authService.currentUser.value;
      if (user != null) {
        merchantName.value =
            user.fullName ?? user.nameAr ?? user.nameEn ?? 'التاجر';
        merchantEmail.value = user.email ?? '';
      }
    } catch (e) {
      print('❌ Error loading merchant data: $e');
    }
  }

  /// Load dashboard data from API
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      print('📊 Loading dashboard data...');

      final response = await _apiClient.get('/merchant/profile/dashboard');

      if (response.statusCode == 200) {
        final data = response.data['data'];

        // Update today's stats
        todayOrders.value = data['today']['orders'] ?? 0;
        todayRevenue.value = (data['today']['revenue'] ?? 0).toDouble();

        // Update week's stats
        weekOrders.value = data['this_week']['orders'] ?? 0;
        weekRevenue.value = (data['this_week']['revenue'] ?? 0).toDouble();

        // Update recent orders
        if (data['recent_orders'] != null) {
          recentOrders.value = List<Map<String, dynamic>>.from(
              data['recent_orders']
                  .map((order) => Map<String, dynamic>.from(order)));
        }

        // Update restaurant info
        if (data['restaurant_info'] != null) {
          profileCompletion.value =
              data['restaurant_info']['profile_completion'] ?? 0;
          totalProducts.value = data['restaurant_info']['total_products'] ?? 0;
          activeProducts.value =
              data['restaurant_info']['active_products'] ?? 0;
        }

        print('✅ Dashboard data loaded successfully');
        print('   Today Orders: ${todayOrders.value}');
        print('   Today Revenue: ${todayRevenue.value}');
        print('   Recent Orders: ${recentOrders.length}');
      }

      // Load restaurant data separately
      await _loadRestaurantData();
    } on dio.DioException catch (e) {
      print('❌ Error loading dashboard data: ${e.message}');
      // Use fallback data
      todayOrders.value = 0;
      todayRevenue.value = 0.0;
      weekOrders.value = 0;
      weekRevenue.value = 0.0;
    } catch (e) {
      print('❌ Unexpected error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load restaurant data from merchant profile
  Future<void> _loadRestaurantData() async {
    try {
      print('🏪 Loading restaurant data...');
      final response = await _apiClient.get('/merchant/profile');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final merchant = data['merchant'];

        // Get restaurant data from merchant
        if (merchant != null && merchant['restaurant'] != null) {
          restaurantData.value = merchant['restaurant'];
          print('✅ Restaurant data loaded');
          print('   Business Name: ${restaurantData.value?['business_name']}');
          print('   Logo: ${restaurantData.value?['logo']}');
        }
      }
    } catch (e) {
      print('❌ Error loading restaurant data: $e');
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
      Get.snackbar(
        'تم تسجيل الخروج',
        'تم تسجيل الخروج بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToProducts() {
    Get.snackbar(
      'قريباً',
      'صفحة إدارة المنتجات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToOrders() {
    Get.snackbar(
      'قريباً',
      'صفحة الطلبات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToReports() {
    Get.snackbar(
      'قريباً',
      'صفحة التقارير قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToSettings() {
    Get.snackbar(
      'قريباً',
      'صفحة الإعدادات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
