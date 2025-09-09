import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import '../models/restaurant_model.dart';
import '../services/restaurant_service.dart';

class HomeController extends GetxController {
  // Observable variables for home screen state
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt currentBannerIndex = 0.obs;
  final ApiClient _apiClient = ApiClient.instance;
  final RestaurantService _restaurantService = RestaurantService();

  // Loading states
  final RxBool isLoadingRestaurants = false.obs;
  final RxBool isLoadingFeatured = false.obs;

  // Categories for the filter section
  final List<String> categories = [
    'الكل',
    'مطاعم',
    'حلويات',
    'مشروبات'
  ];

  // Restaurants data
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxList<RestaurantModel> featuredRestaurants = <RestaurantModel>[].obs;
  final RxList<Map<String, dynamic>> restaurantsRawData = <Map<String, dynamic>>[].obs;

  // Home screen data from API
  final RxList<Map<String, dynamic>> homeRestaurants = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> homeProducts = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingHomeData = false.obs;
  
  // Kitchen data from backend
  final RxList<Map<String, dynamic>> kitchens = <Map<String, dynamic>>[].obs;
  
  // Best seller products from backend
  final RxList<Map<String, dynamic>> bestSellerProducts = <Map<String, dynamic>>[].obs;
  
  // Back again products from backend
  final RxList<Map<String, dynamic>> backAgainProducts = <Map<String, dynamic>>[].obs;

  // Loading states
  final RxBool isLoadingProducts = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProductsFromBackend();
    _setupLanguageListener();
    // Load restaurants data
    loadRestaurants();
    loadFeaturedRestaurants();
    // Load home screen data from new API
    loadHomeScreenData();
  }

  /// Setup language change listener
  void _setupLanguageListener() {
    final languageService = LanguageService.instance;
    // Listen to language changes and reload products
    ever(languageService.currentLanguageRx, (String language) {
      print('🌐 HOME: Language changed to $language, reloading products...');
      _loadProductsFromBackend();
    });
  }

  /// Load products from backend API
  Future<void> _loadProductsFromBackend() async {
    try {
      isLoadingProducts.value = true;
      print('🏠 HOME: Loading products from backend...');

      // Get products from backend
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.products}',
      );

      print('🏠 HOME: Products API response: ${response.statusCode}');

      if (response.data['success'] == true) {
        // Handle nested products structure
        final responseData = response.data['data'];
        final List<dynamic> productsData = responseData is Map<String, dynamic>
            ? (responseData['products'] ?? [])
            : (responseData ?? []);
        print('🏠 HOME: Found ${productsData.length} products');

        // Clear existing data
        bestSellerProducts.clear();
        backAgainProducts.clear();

        // Convert backend data to our format
        for (var productData in productsData) {
          final product = _convertBackendProduct(productData);
          print('🏠 HOME: Converted product: ${product['name']} - ${product['price']} ر.س');

          // Add to both lists for now (you can implement logic to separate them)
          if (bestSellerProducts.length < 4) {
            bestSellerProducts.add(product);
          } else {
            backAgainProducts.add(product);
          }
        }

        print('🏠 HOME: Best sellers: ${bestSellerProducts.length}, Back again: ${backAgainProducts.length}');

        // Force UI update
        bestSellerProducts.refresh();
        backAgainProducts.refresh();
        update();
      } else {
        print('🏠 HOME: API returned success=false');
      }
    } catch (e) {
      print('🏠 HOME: Error loading products: $e');
      // Handle API failure
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Convert backend product data to our format
  Map<String, dynamic> _convertBackendProduct(Map<String, dynamic> backendData) {
    // Use LanguageService to get localized text
    final languageService = LanguageService.instance;

    String getName(dynamic nameField) {
      return languageService.getLocalizedText(nameField);
    }

    // Handle image URL properly
    String getImageUrl(dynamic imageField) {
      if (imageField != null && imageField.toString().isNotEmpty && imageField != 'null') {
        String imageUrl = imageField.toString();
        // If it's already a full URL, return it
        if (imageUrl.startsWith('http')) {
          return imageUrl;
        }
        // If it's a relative path, construct full URL
        String baseUrl = ApiConstants.useProductionServer
            ? 'https://mr-shife-backend-main-ygodva.laravel.cloud'
            : 'http://127.0.0.1:8000';
        return '$baseUrl/storage/$imageUrl';
      }
      return 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop'; // fallback image
    }

    return {
      'id': backendData['id'],
      'name': getName(backendData['name']),
      'description': backendData['description'] ?? '',
      'price': (backendData['price'] ?? 0).toDouble(),
      'originalPrice': backendData['originalPrice']?.toDouble(),
      'primary_image': getImageUrl(backendData['primary_image']),
      'images': backendData['images'] ?? [getImageUrl(backendData['primary_image'])],
      'rating': backendData['rating'] is Map
          ? (backendData['rating']['average'] ?? 4.5).toDouble()
          : (backendData['rating'] ?? 4.5).toDouble(),
      'reviewCount': backendData['reviewCount'] ?? 0,
      'productCode': backendData['productCode'] ?? 'PRD-${backendData['id']}',
      'isFavorite': false,
    };
  }

  // Methods
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }
  
  void updateBannerIndex(int index) {
    currentBannerIndex.value = index;
  }
  
  void toggleFavorite(int productId, String section) {
    if (section == 'bestSeller') {
      final index = bestSellerProducts.indexWhere((product) => product['id'] == productId);
      if (index != -1) {
        bestSellerProducts[index]['isFavorite'] = !bestSellerProducts[index]['isFavorite'];
        bestSellerProducts.refresh();
      }
    } else if (section == 'backAgain') {
      final index = backAgainProducts.indexWhere((product) => product['id'] == productId);
      if (index != -1) {
        backAgainProducts[index]['isFavorite'] = !backAgainProducts[index]['isFavorite'];
        backAgainProducts.refresh();
      }
    }
  }
  
  /// Add product to cart with minimum required options (handled by backend)
  Future<void> addToCart(int productId) async {
    try {
      // Create a minimal ProductModel for the cart controller
      final product = ProductModel(
        id: productId,
        name: 'Product $productId',
        description: '',
        price: 0.0,
        image: '',
        rating: 0.0,
        reviewCount: 0,
        productCode: '',
        sizes: [],
        rawSizes: [],
        additionalOptions: [],
        images: [],
      );

      final cartController = Get.find<CartController>();

      // Use existing addToCart method with empty options
      // Backend will automatically select minimum required options
      await cartController.addToCart(
        product: product,
        size: '', // Empty - backend will choose minimum
        quantity: 1,
        additionalOptions: [], // Empty - backend will choose minimum required
      );

    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة المنتج إلى السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      if (kDebugMode) {
        print('❌ ADD TO CART ERROR: $e');
      }
    }
  }
  
  void onSearchTap() {
    // TODO: Navigate to search screen
    Get.snackbar(
      'Search',
      'Search functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void onNotificationTap() {
    // TODO: Navigate to notifications screen
    Get.snackbar(
      'Notifications',
      'Notifications screen coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void onChatTap() {
    // TODO: Navigate to chat screen
    Get.snackbar(
      'Chat',
      'Chat functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void onSeeAllTap(String section) {
    // TODO: Navigate to respective section screen
    Get.snackbar(
      'See All',
      '$section - See all functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToProductDetails({int? productId}) {
    Get.toNamed(
      AppRoutes.PRODUCT_DETAILS,
      arguments: {'productId': productId ?? 1},
    );
  }

  /// Load restaurants from API
  Future<void> loadRestaurants() async {
    try {
      isLoadingRestaurants.value = true;

      // Load raw data directly from API
      await loadRestaurantsRawData();

      final loadedRestaurants = await _restaurantService.getRestaurants(
        perPage: 20,
        sortBy: 'rating',
        sortOrder: 'desc',
      );

      restaurants.value = loadedRestaurants;

      if (kDebugMode) {
        print('✅ HOME CONTROLLER: Restaurants loaded successfully');
        print('🏪 COUNT: ${restaurants.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HOME CONTROLLER ERROR: $e');
      }
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المطاعم',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingRestaurants.value = false;
    }
  }

  /// Load restaurants raw data directly from API
  Future<void> loadRestaurantsRawData() async {
    try {
      final response = await ApiClient.instance.get(
        '/customer/shopping/kitchens',
        queryParameters: {
          'page': 1,
          'per_page': 20,
          'sort_by': 'rating',
          'sort_order': 'desc',
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> rawData = response.data['data'];
        restaurantsRawData.value = rawData.cast<Map<String, dynamic>>();

        if (kDebugMode) {
          print('✅ HOME CONTROLLER: Raw restaurants data loaded');
          print('🏪 RAW COUNT: ${restaurantsRawData.length}');
          if (restaurantsRawData.isNotEmpty) {
            print('📦 SAMPLE DATA: ${restaurantsRawData.first}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HOME CONTROLLER: Failed to load raw restaurants data: $e');
      }
    }
  }

  /// Load featured restaurants
  Future<void> loadFeaturedRestaurants() async {
    try {
      isLoadingFeatured.value = true;

      final featured = await _restaurantService.getFeaturedRestaurants(
        limit: 10,
      );

      featuredRestaurants.value = featured;

      if (kDebugMode) {
        print('✅ HOME CONTROLLER: Featured restaurants loaded');
        print('⭐ COUNT: ${featuredRestaurants.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HOME CONTROLLER ERROR: $e');
      }
    } finally {
      isLoadingFeatured.value = false;
    }
  }

  /// Load home screen data from new API
  Future<void> loadHomeScreenData() async {
    try {
      isLoadingHomeData.value = true;

      final response = await _apiClient.get(
        '/customer/shopping/home',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        // Update home restaurants (featured + nearby)
        homeRestaurants.clear();
        if (data['featured_restaurants'] != null) {
          homeRestaurants.addAll(List<Map<String, dynamic>>.from(data['featured_restaurants']));
        }
        if (data['nearby_restaurants'] != null) {
          homeRestaurants.addAll(List<Map<String, dynamic>>.from(data['nearby_restaurants']));
        }

        // Update home products (popular + trending)
        homeProducts.clear();
        if (data['popular_products'] != null) {
          homeProducts.addAll(List<Map<String, dynamic>>.from(data['popular_products']));
        }
        if (data['trending_products'] != null) {
          homeProducts.addAll(List<Map<String, dynamic>>.from(data['trending_products']));
        }

        if (kDebugMode) {
          print('✅ HOME CONTROLLER: Home screen data loaded');
          print('🏪 HOME RESTAURANTS: ${homeRestaurants.length}');
          print('🍽️ HOME PRODUCTS: ${homeProducts.length}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HOME CONTROLLER: Failed to load home screen data: $e');
      }
    } finally {
      isLoadingHomeData.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadRestaurants(),
      loadFeaturedRestaurants(),
      loadHomeScreenData(),
    ]);
  }

}
