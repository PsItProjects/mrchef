import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:dio/dio.dart' as dio;
import '../../../core/services/toast_service.dart';

/// Statistics filter type enum
enum StatisticsFilterType { daily, weekly, monthly, yearly, custom, all }

class MerchantDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable variables
  var isLoading = false.obs;
  var isStatsLoading = false.obs;
  var merchantName = ''.obs;
  var merchantEmail = ''.obs;

  // Filter state
  var currentFilter = StatisticsFilterType.weekly.obs;
  var customStartDate = Rxn<DateTime>();
  var customEndDate = Rxn<DateTime>();

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

  // Statistics data with filters
  var statisticsData = Rxn<Map<String, dynamic>>();
  var totalOrders = 0.obs;
  var totalRevenue = 0.0.obs;
  var completedOrders = 0.obs;
  var pendingOrders = 0.obs;
  var cancelledOrders = 0.obs;
  var previousPeriodOrders = 0.obs;
  var previousPeriodRevenue = 0.0.obs;
  var topProducts = <Map<String, dynamic>>[].obs;
  var filterLabel = ''.obs;

  // Notifications
  var unreadNotificationsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMerchantData();
    loadDashboardData();
    loadStatistics(); // Load initial statistics
    loadUnreadNotificationsCount(); // Load unread notifications count
  }

  /// Get filter type as string for API
  String get filterTypeString {
    switch (currentFilter.value) {
      case StatisticsFilterType.daily:
        return 'daily';
      case StatisticsFilterType.weekly:
        return 'weekly';
      case StatisticsFilterType.monthly:
        return 'monthly';
      case StatisticsFilterType.yearly:
        return 'yearly';
      case StatisticsFilterType.custom:
        return 'custom';
      case StatisticsFilterType.all:
        return 'all';
    }
  }

  /// Get filter label for display
  String getFilterLabel() {
    switch (currentFilter.value) {
      case StatisticsFilterType.daily:
        return 'daily'.tr;
      case StatisticsFilterType.weekly:
        return 'weekly'.tr;
      case StatisticsFilterType.monthly:
        return 'monthly'.tr;
      case StatisticsFilterType.yearly:
        return 'yearly'.tr;
      case StatisticsFilterType.custom:
        return 'custom_range'.tr;
      case StatisticsFilterType.all:
        return 'all_time'.tr;
    }
  }

  /// Apply filter and reload statistics
  void applyFilter(StatisticsFilterType type,
      {DateTime? startDate, DateTime? endDate}) {
    currentFilter.value = type;
    if (type == StatisticsFilterType.custom) {
      customStartDate.value = startDate;
      customEndDate.value = endDate;
    }
    loadStatistics();
  }

  /// Reset filter to weekly
  void resetFilter() {
    currentFilter.value = StatisticsFilterType.weekly;
    customStartDate.value = null;
    customEndDate.value = null;
    loadStatistics();
  }

  /// Load statistics with current filter
  Future<void> loadStatistics() async {
    try {
      isStatsLoading.value = true;

      final queryParams = <String, dynamic>{
        'filter_type': filterTypeString,
      };

      if (currentFilter.value == StatisticsFilterType.custom) {
        if (customStartDate.value != null) {
          queryParams['start_date'] =
              customStartDate.value!.toIso8601String().split('T')[0];
        }
        if (customEndDate.value != null) {
          queryParams['end_date'] =
              customEndDate.value!.toIso8601String().split('T')[0];
        }
      }

      final response = await _apiClient.get(
        '/merchant/profile/statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        statisticsData.value = data;

        // Update stats - API returns nested structure
        // orders: { total, completed, pending, cancelled }
        // revenue: { total, average_order_value }
        final orders = data['orders'] ?? {};
        final revenue = data['revenue'] ?? {};

        totalOrders.value = orders['total'] ?? 0;
        completedOrders.value = orders['completed'] ?? 0;
        pendingOrders.value = orders['pending'] ?? 0;
        cancelledOrders.value = orders['cancelled'] ?? 0;
        totalRevenue.value = (revenue['total'] ?? 0).toDouble();

        // Get filter label from API response
        final filter = data['filter'] ?? {};
        filterLabel.value = filter['label'] ?? getFilterLabel();

        // Update comparison - API returns:
        // comparison: { orders_change, revenue_change, previous_orders, previous_revenue }
        final comparison = data['comparison'] ?? {};
        previousPeriodOrders.value = comparison['previous_orders'] ?? 0;
        previousPeriodRevenue.value = (comparison['previous_revenue'] ?? 0).toDouble();

        // Update top products
        if (data['top_products'] != null) {
          topProducts.value = List<Map<String, dynamic>>.from(
              data['top_products'].map((p) => Map<String, dynamic>.from(p)));
        }
      }
    } on dio.DioException catch (e) {
      print('Error loading statistics: ${e.message}');
    } finally {
      isStatsLoading.value = false;
    }
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
      ToastService.showSuccess('تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('Logout error: $e');
      ToastService.showError('حدث خطأ أثناء تسجيل الخروج');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToProducts() {
    ToastService.showInfo('صفحة إدارة المنتجات قيد التطوير');
  }

  void navigateToOrders() {
    ToastService.showInfo('صفحة الطلبات قيد التطوير');
  }

  void navigateToReports() {
    ToastService.showInfo('صفحة التقارير قيد التطوير');
  }

  void navigateToSettings() {
    ToastService.showInfo('صفحة الإعدادات قيد التطوير');
  }

  /// Load unread notifications count
  Future<void> loadUnreadNotificationsCount() async {
    try {
      final response =
          await _apiClient.get('/merchant/profile/notifications/unread-count');
      if (response.statusCode == 200 && response.data['success'] == true) {
        unreadNotificationsCount.value =
            response.data['data']['unread_count'] ?? 0;
      }
    } on dio.DioException catch (e) {
      print('Error loading unread notifications count: ${e.message}');
    }
  }
}
