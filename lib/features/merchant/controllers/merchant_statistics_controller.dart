import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:dio/dio.dart' as dio;

enum StatisticsFilterType { daily, weekly, monthly, yearly, custom, all }

class MerchantStatisticsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable variables
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Filter state
  final selectedFilter = StatisticsFilterType.all.obs;
  final customStartDate = Rxn<DateTime>();
  final customEndDate = Rxn<DateTime>();

  // Statistics data
  final statisticsData = Rxn<Map<String, dynamic>>();

  // Getters for specific data
  Map<String, dynamic>? get ordersData => statisticsData.value?['orders'];
  Map<String, dynamic>? get revenueData => statisticsData.value?['revenue'];
  Map<String, dynamic>? get comparisonData => statisticsData.value?['comparison'];
  Map<String, dynamic>? get productsData => statisticsData.value?['products'];
  Map<String, dynamic>? get filterData => statisticsData.value?['filter'];
  List<dynamic>? get dailyBreakdown => statisticsData.value?['daily_breakdown'];
  List<dynamic>? get topProducts => statisticsData.value?['top_products'];

  // Convenience getters
  int get totalOrders => ordersData?['total'] ?? 0;
  int get completedOrders => ordersData?['completed'] ?? 0;
  int get pendingOrders => ordersData?['pending'] ?? 0;
  int get cancelledOrders => ordersData?['cancelled'] ?? 0;
  double get totalRevenue => (revenueData?['total'] ?? 0).toDouble();
  double get averageOrderValue => (revenueData?['average_order_value'] ?? 0).toDouble();
  double get ordersChange => (comparisonData?['orders_change'] ?? 0).toDouble();
  double get revenueChange => (comparisonData?['revenue_change'] ?? 0).toDouble();
  String get filterLabel => filterData?['label'] ?? '';

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  /// Load statistics from API
  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (kDebugMode) {
        print('📊 Loading statistics with filter: ${selectedFilter.value.name}');
      }

      // Build query parameters
      final Map<String, dynamic> params = {
        'filter_type': selectedFilter.value.name,
      };

      if (selectedFilter.value == StatisticsFilterType.custom) {
        if (customStartDate.value != null) {
          params['start_date'] = _formatDate(customStartDate.value!);
        }
        if (customEndDate.value != null) {
          params['end_date'] = _formatDate(customEndDate.value!);
        }
      }

      final response = await _apiClient.get(
        '/merchant/profile/statistics',
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        statisticsData.value = response.data['data'];
        if (kDebugMode) {
          print('✅ Statistics loaded successfully');
          print('   Total Orders: $totalOrders');
          print('   Total Revenue: $totalRevenue');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load statistics');
      }
    } on dio.DioException catch (e) {
      hasError.value = true;
      errorMessage.value = e.response?.data['message'] ?? 'Network error';
      if (kDebugMode) {
        print('❌ Statistics error: ${e.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      if (kDebugMode) {
        print('❌ Statistics error: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply filter and reload statistics
  void applyFilter(StatisticsFilterType filterType, {DateTime? startDate, DateTime? endDate}) {
    selectedFilter.value = filterType;
    if (filterType == StatisticsFilterType.custom) {
      customStartDate.value = startDate;
      customEndDate.value = endDate;
    } else {
      customStartDate.value = null;
      customEndDate.value = null;
    }
    loadStatistics();
  }

  /// Reset filter to all
  void resetFilter() {
    selectedFilter.value = StatisticsFilterType.all;
    customStartDate.value = null;
    customEndDate.value = null;
    loadStatistics();
  }

  /// Format date for API
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get filter display name
  String getFilterName(StatisticsFilterType filter) {
    switch (filter) {
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
}

