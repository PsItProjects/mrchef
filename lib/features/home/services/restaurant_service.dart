import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get list of restaurants/merchants
  Future<List<RestaurantModel>> getRestaurants({
    String? search,
    String? businessType,
    bool? isFeatured,
    double? deliveryFeeMax,
    double? minimumOrderMax,
    double? userLat,
    double? userLng,
    double? radius,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      if (kDebugMode) {
        print('🏪 RESTAURANT SERVICE: Getting restaurants...');
        print('🔍 Search: $search');
        print('📍 Location: $userLat, $userLng');
        print('📄 Page: $page, Per Page: $perPage');
      }

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      // Add optional filters
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (businessType != null) {
        queryParams['business_type'] = businessType;
      }
      if (isFeatured != null) {
        queryParams['is_featured'] = isFeatured;
      }
      if (deliveryFeeMax != null) {
        queryParams['delivery_fee_max'] = deliveryFeeMax;
      }
      if (minimumOrderMax != null) {
        queryParams['minimum_order_max'] = minimumOrderMax;
      }
      if (userLat != null && userLng != null) {
        queryParams['user_lat'] = userLat;
        queryParams['user_lng'] = userLng;
        if (radius != null) {
          queryParams['radius'] = radius;
        }
      }

      final response = await _apiClient.get(
        '/customer/shopping/kitchens',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        // Handle both array and object response formats
        List<dynamic> restaurantsData;

        if (response.data['data'] is List) {
          // Direct array format
          restaurantsData = response.data['data'];
        } else if (response.data['data'] is Map && response.data['data']['restaurants'] != null) {
          // Object with restaurants key
          restaurantsData = response.data['data']['restaurants'];
        } else {
          // Fallback to empty list
          restaurantsData = [];
        }

        // Create simplified restaurant objects
        final restaurants = <RestaurantModel>[];

        for (var restaurantData in restaurantsData) {
          try {
            // Create a simplified restaurant model
            final restaurant = RestaurantModel(
              id: restaurantData['id'] ?? 0,
              name: _parseTranslatableString(restaurantData['name']),
              businessName: _parseTranslatableString(restaurantData['business_name']),
              description: _parseTranslatableString(restaurantData['description']) ?? '',
              businessType: restaurantData['business_type']?.toString() ?? 'مطعم',
              logo: restaurantData['logo']?.toString() ?? 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
              coverImage: restaurantData['cover_image']?.toString() ?? 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
              location: LocationInfo(
                address: '',
                city: '',
                area: '',
                latitude: 0.0,
                longitude: 0.0,
              ),
              delivery: DeliveryInfo(
                radius: 10.0,
                fee: 5.0,
                minimumOrder: 20.0,
                estimatedTime: '25-35 دقيقة',
              ),
              businessHours: null,
              isOpenNow: true,
              nextOpeningTime: null,
              rating: RatingInfo(
                average: 4.5,
                count: 100,
                stars: {5: 80, 4: 15, 3: 3, 2: 1, 1: 1},
              ),
              status: 'active',
              isFeatured: restaurantData['is_featured'] ?? false,
              isVerified: restaurantData['is_verified'] ?? false,
              hasDiscount: restaurantData['has_discount'] ?? false,
              discountPercentage: 0.0,
              contact: ContactInfo(
                phone: '',
                email: '',
              ),
              cuisineTypes: [restaurantData['business_type']?.toString() ?? 'مطعم'],
              popularDishes: [],
              distance: null,
              stats: RestaurantStats(
                totalProducts: 0,
                categoriesCount: 0,
                ordersCount: 0,
              ),
            );

            restaurants.add(restaurant);
          } catch (e) {
            if (kDebugMode) {
              print('❌ Error parsing restaurant: $e');
              print('📦 Restaurant data: $restaurantData');
            }
          }
        }

        if (kDebugMode) {
          print('✅ RESTAURANT SERVICE: Restaurants loaded successfully');
          print('🏪 COUNT: ${restaurants.length}');
        }

        return restaurants;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load restaurants');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ RESTAURANT SERVICE ERROR: $e');
      }
      return []; // Return empty list on error
    }
  }

  static String _parseTranslatableString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['current'] ?? value['ar'] ?? value['en'] ?? '';
    }
    return value.toString();
  }

  /// Get featured restaurants
  Future<List<RestaurantModel>> getFeaturedRestaurants({
    int limit = 10,
  }) async {
    return getRestaurants(
      page: 1,
      perPage: limit,
      isFeatured: true,
    );
  }

  /// Get restaurants with filters
  Future<List<RestaurantModel>> getRestaurantsWithFilters({
    double? userLat,
    double? userLng,
    int limit = 10,
  }) async {
    return getRestaurants(
      isFeatured: true,
      userLat: userLat,
      userLng: userLng,
      perPage: limit,
      sortBy: 'rating',
      sortOrder: 'desc',
    );
  }

  /// Get nearby restaurants
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double userLat,
    required double userLng,
    double radius = 10.0, // 10km radius
    int limit = 20,
  }) async {
    return getRestaurants(
      userLat: userLat,
      userLng: userLng,
      radius: radius,
      perPage: limit,
      sortBy: 'distance',
      sortOrder: 'asc',
    );
  }

  /// Search restaurants
  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    double? userLat,
    double? userLng,
    int page = 1,
    int perPage = 20,
  }) async {
    return getRestaurants(
      search: query,
      userLat: userLat,
      userLng: userLng,
      page: page,
      perPage: perPage,
      sortBy: 'rating',
      sortOrder: 'desc',
    );
  }

  /// Get restaurants by business type
  Future<List<RestaurantModel>> getRestaurantsByType({
    required String businessType,
    double? userLat,
    double? userLng,
    int page = 1,
    int perPage = 20,
  }) async {
    return getRestaurants(
      businessType: businessType,
      userLat: userLat,
      userLng: userLng,
      page: page,
      perPage: perPage,
    );
  }

  /// Get restaurant details
  Future<RestaurantModel> getRestaurantDetails(int restaurantId) async {
    try {
      if (kDebugMode) {
        print('🏪 RESTAURANT SERVICE: Getting restaurant details...');
        print('🆔 ID: $restaurantId');
      }

      final response = await _apiClient.get(
        '/customer/shopping/kitchens/$restaurantId',
      );

      if (response.data['success'] == true) {
        // Handle both direct object and wrapped object formats
        Map<String, dynamic> restaurantData;

        if (response.data['data'] is Map) {
          restaurantData = response.data['data'];
        } else {
          throw Exception('Invalid restaurant data format');
        }

        final restaurant = RestaurantModel.fromJson(restaurantData);

        if (kDebugMode) {
          print('✅ RESTAURANT SERVICE: Restaurant details loaded');
          print('🏪 NAME: ${restaurant.businessName}');
        }

        return restaurant;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load restaurant details');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ RESTAURANT SERVICE ERROR: $e');
      }
      rethrow;
    }
  }
}
