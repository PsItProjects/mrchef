import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/home/models/restaurant_model.dart';
import 'package:mrsheaf/features/home/services/restaurant_service.dart';

class AllRestaurantsController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;
  
  // All restaurants
  final RxList<RestaurantModel> allRestaurants = <RestaurantModel>[].obs;
  
  // Filtered restaurants
  final RxList<RestaurantModel> filteredRestaurants = <RestaurantModel>[].obs;
  
  // Selected filter index (0: All, 1: Newest, 2: Rating, 3: Delivery Fee)
  final RxInt selectedFilterIndex = 0.obs;
  
  // Filter labels
  final List<String> filterLabels = [
    'all'.tr,
    'newest'.tr,
    'highest_rated'.tr,
    'lowest_delivery_fee'.tr,
  ];
  
  // Service
  final RestaurantService _restaurantService = RestaurantService();
  
  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
  }
  
  /// Fetch all restaurants from API
  Future<void> fetchRestaurants() async {
    try {
      isLoading.value = true;
      
      // Fetch restaurants sorted by newest first (default)
      final restaurants = await _restaurantService.getRestaurants(
        perPage: 100, // Get all restaurants
        sortBy: 'created_at',
        sortOrder: 'desc',
      );
      
      allRestaurants.value = restaurants;
      filteredRestaurants.value = restaurants;

      if (kDebugMode) {
        print('✅ ALL RESTAURANTS: Fetched ${allRestaurants.length} restaurants');
        for (var restaurant in restaurants.take(3)) {
          print('⭐ ${restaurant.displayName}: Rating=${restaurant.rating.average}, Count=${restaurant.rating.count}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ALL RESTAURANTS ERROR: $e');
      }
      Get.snackbar(
        'error'.tr,
        'failed_to_load_restaurants'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Switch filter
  void switchFilter(int index) {
    selectedFilterIndex.value = index;
    _applyFilter();
  }
  
  /// Apply selected filter
  void _applyFilter() {
    List<RestaurantModel> filtered = List.from(allRestaurants);

    switch (selectedFilterIndex.value) {
      case 0: // All (newest first - default)
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 1: // Newest
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 2: // Highest rated
        filtered.sort((a, b) => b.rating.average.compareTo(a.rating.average));
        break;
      case 3: // Lowest delivery fee
        filtered.sort((a, b) {
          final aFee = a.delivery.fee ?? double.infinity;
          final bFee = b.delivery.fee ?? double.infinity;
          return aFee.compareTo(bFee);
        });
        break;
    }

    filteredRestaurants.value = filtered;

    if (kDebugMode) {
      print('🔍 FILTER APPLIED: ${filterLabels[selectedFilterIndex.value]}');
      print('📊 FILTERED COUNT: ${filteredRestaurants.length}');
    }
  }
  
  /// Refresh restaurants
  Future<void> refreshRestaurants() async {
    await fetchRestaurants();
  }
  
  /// Navigate to restaurant details
  void navigateToRestaurantDetails(RestaurantModel restaurant) {
    Get.toNamed('/store-details', arguments: {'restaurantId': restaurant.id});
  }
  
  /// Go back
  void goBack() {
    Get.back();
  }
}

