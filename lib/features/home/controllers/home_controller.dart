import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import '../models/restaurant_model.dart';
import '../models/banner_model.dart';
import '../services/restaurant_service.dart';
import '../services/banner_service.dart';
import '../pages/webview_screen.dart';

class HomeController extends GetxController {
  // Observable variables for home screen state
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt currentBannerIndex = 0.obs;
  final ApiClient _apiClient = ApiClient.instance;
  final RestaurantService _restaurantService = RestaurantService();
  final BannerService _bannerService = BannerService();

  // Banners
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxBool isLoadingBanners = false.obs;

  // Loading states
  final RxBool isLoadingRestaurants = false.obs;
  final RxBool isLoadingFeatured = false.obs;

  // Categories for the filter section - now loaded from backend
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxInt selectedCategoryId = 0.obs; // 0 means "Popular" (no filter)
  final RxBool isLoadingCategories = false.obs;

  // Restaurants data
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxList<RestaurantModel> featuredRestaurants = <RestaurantModel>[].obs;
  final RxList<Map<String, dynamic>> restaurantsRawData =
      <Map<String, dynamic>>[].obs;

  // Home screen data from API
  final RxList<Map<String, dynamic>> homeRestaurants =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> homeProducts =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingHomeData = false.obs;

  // Kitchen data from backend
  final RxList<Map<String, dynamic>> kitchens = <Map<String, dynamic>>[].obs;

  // Best seller products from backend
  final RxList<Map<String, dynamic>> bestSellerProducts =
      <Map<String, dynamic>>[].obs;

  // Back again products from backend
  final RxList<Map<String, dynamic>> backAgainProducts =
      <Map<String, dynamic>>[].obs;

  // Filtered data based on selected category
  final RxList<Map<String, dynamic>> filteredRestaurants =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredProducts =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredProductsByRating =
      <Map<String, dynamic>>[].obs;

  // Loading states
  final RxBool isLoadingProducts = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategoriesFromBackend();
    _loadProductsFromBackend();
    _setupLanguageListener();
    // Load restaurants data
    loadRestaurants();
    loadFeaturedRestaurants();
    // Load home screen data from new API
    loadHomeScreenData();
    // Load banners
    loadBanners();
  }

  /// Setup language change listener
  void _setupLanguageListener() {
    final languageService = LanguageService.instance;
    // Listen to language changes and reload data
    ever(languageService.currentLanguageRx, (String language) {
      print('🌐 HOME: Language changed to $language, reloading data...');
      _loadCategoriesFromBackend();
      _loadProductsFromBackend();
      _applyCurrentFilter();
    });
  }

  /// Load categories from backend API
  Future<void> _loadCategoriesFromBackend() async {
    try {
      isLoadingCategories.value = true;
      print('🏠 HOME: Loading categories from backend...');

      // Get categories from backend using categories-with-products endpoint
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.categoriesWithProducts}',
      );

      print('🏠 HOME: Categories API response: ${response.statusCode}');

      if (response.data['success'] == true) {
        final Map<String, dynamic> responseData = response.data['data'] ?? {};
        final List<dynamic> categoriesData = responseData['categories'] ?? [];
        print('🏠 HOME: Found ${categoriesData.length} categories');

        // Clear existing categories
        categories.clear();

        // Convert backend data to CategoryModel
        for (var categoryData in categoriesData) {
          final category = CategoryModel.fromJson(categoryData);
          categories.add(category);
          print('🏠 HOME: Added category: ${category.name}');
        }

        // Force UI update
        categories.refresh();
        update();
      } else {
        print('🏠 HOME: Categories API returned success=false');
      }
    } catch (e) {
      print('🏠 HOME: Error loading categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
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
          print(
              '🏠 HOME: Converted product: ${product['name']} - ${product['price']} ر.س');

          // Add to both lists for now (you can implement logic to separate them)
          if (bestSellerProducts.length < 4) {
            bestSellerProducts.add(product);
          } else {
            backAgainProducts.add(product);
          }
        }

        print(
            '🏠 HOME: Best sellers: ${bestSellerProducts.length}, Back again: ${backAgainProducts.length}');

        // Apply current filter after loading products
        _applyCurrentFilter();

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
  Map<String, dynamic> _convertBackendProduct(
      Map<String, dynamic> backendData) {
    // Use LanguageService to get localized text
    final languageService = LanguageService.instance;

    print('🔄 CONVERTING PRODUCT:');
    print('   Backend ID: ${backendData['id']}');
    print('   Backend Name: ${backendData['name']}');

    String getName(dynamic nameField) {
      return languageService.getLocalizedText(nameField);
    }

    // Handle image URL properly
    String getImageUrl(dynamic imageField) {
      if (imageField != null &&
          imageField.toString().isNotEmpty &&
          imageField != 'null') {
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

    final converted = {
      'id': backendData['id'],
      'name': getName(backendData['name']),
      'description': backendData['description'] ?? '',
      'price': double.tryParse(backendData['price']?.toString() ?? '0') ?? 0.0,
      'originalPrice':
          double.tryParse(backendData['originalPrice']?.toString() ?? '0'),
      'primary_image': getImageUrl(backendData['primary_image']),
      'images':
          backendData['images'] ?? [getImageUrl(backendData['primary_image'])],
      'rating': backendData['rating'] is Map
          ? double.tryParse(
                  backendData['rating']['average']?.toString() ?? '4.5') ??
              4.5
          : double.tryParse(backendData['rating']?.toString() ?? '4.5') ?? 4.5,
      'reviewCount': backendData['reviewCount'] ?? 0,
      'productCode': backendData['productCode'] ?? 'PRD-${backendData['id']}',
      'categoryId': backendData['category_id'], // إضافة categoryId للفلترة
      'isFavorite': false,
    };
    
    print('   ✅ Converted Product ID: ${converted['id']}');
    print('   ✅ Converted Product Name: ${converted['name']}');
    
    return converted;
  }

  // Methods
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  /// Select category by ID and apply filter
  void selectCategoryById(int categoryId) {
    selectedCategoryId.value = categoryId;
    _applyCurrentFilter();
    print('🏠 HOME: Selected category ID: $categoryId');
  }

  /// Apply current filter to restaurants and products
  void _applyCurrentFilter() {
    if (selectedCategoryId.value == 0) {
      // "Popular" - show all data sorted by rating
      _showPopularData();
    } else {
      // Filter by selected category
      _filterByCategory(selectedCategoryId.value);
    }
  }

  /// Show popular data (latest added products and all restaurants)
  void _showPopularData() {
    print('🏠 HOME: Showing popular data (no category filter)');

    // For restaurants, show all restaurants (no filter)
    filteredRestaurants.clear();
    if (restaurantsRawData.isNotEmpty) {
      filteredRestaurants.addAll(restaurantsRawData);
    }

    // For products, clear filtered products so UI uses original bestSeller and backAgain lists
    filteredProducts.clear();
    filteredProductsByRating.clear();

    print(
        '🏠 HOME: Popular data - ${filteredRestaurants.length} restaurants, using original product lists');
  }

  /// Filter restaurants and products by category
  void _filterByCategory(int categoryId) {
    print('🏠 HOME: Filtering by category ID: $categoryId');

    // Filter restaurants by category - use restaurantsRawData which has categories
    filteredRestaurants.clear();
    for (var restaurant in restaurantsRawData) {
      final restaurantCategories = restaurant['categories'] as List<dynamic>?;
      print(
          '🏪 RESTAURANT: ${restaurant['name']} - Categories: $restaurantCategories');
      if (restaurantCategories != null) {
        final hasCategory =
            restaurantCategories.any((cat) => cat['id'] == categoryId);
        if (hasCategory) {
          filteredRestaurants.add(restaurant);
          print('✅ RESTAURANT MATCHED: ${restaurant['name']}');
        }
      }
    }

    // Filter products by category
    filteredProducts.clear();
    filteredProductsByRating.clear();
    final allProducts = [...bestSellerProducts, ...backAgainProducts];
    final categoryProducts = <Map<String, dynamic>>[];

    for (var product in allProducts) {
      final productCategoryId = product['categoryId'] ?? product['category_id'];
      if (productCategoryId == categoryId) {
        categoryProducts.add(product);
      }
    }

    // For "مؤخراً" section: Sort by ID descending (newest first)
    final latestProducts = List<Map<String, dynamic>>.from(categoryProducts);
    latestProducts.sort((a, b) {
      final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      return idB.compareTo(idA); // Descending order (newest first)
    });
    filteredProducts.addAll(latestProducts);

    // For "الأكثر مبيعاً" section: Sort by rating descending (best rated first)
    final bestRatedProducts = List<Map<String, dynamic>>.from(categoryProducts);
    bestRatedProducts.sort((a, b) {
      final ratingA = double.tryParse(a['rating']?.toString() ?? '0') ?? 0.0;
      final ratingB = double.tryParse(b['rating']?.toString() ?? '0') ?? 0.0;
      return ratingB
          .compareTo(ratingA); // Descending order (highest rating first)
    });
    filteredProductsByRating.addAll(bestRatedProducts);

    print(
        '🏠 HOME: Filtered data - ${filteredRestaurants.length} restaurants, ${filteredProducts.length} products');
  }

  void updateBannerIndex(int index) {
    currentBannerIndex.value = index;
  }

  void toggleFavorite(int productId, String section) {
    if (section == 'bestSeller') {
      final index = bestSellerProducts
          .indexWhere((product) => product['id'] == productId);
      if (index != -1) {
        bestSellerProducts[index]['isFavorite'] =
            !bestSellerProducts[index]['isFavorite'];
        bestSellerProducts.refresh();
      }
    } else if (section == 'backAgain') {
      final index =
          backAgainProducts.indexWhere((product) => product['id'] == productId);
      if (index != -1) {
        backAgainProducts[index]['isFavorite'] =
            !backAgainProducts[index]['isFavorite'];
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
    Get.toNamed(AppRoutes.SEARCH);
  }

  void onNotificationTap() {
    // Navigate to notifications screen
    Get.toNamed('/notifications');
  }

  void onChatTap() {
    Get.toNamed('/conversations');
  }

  void onSeeAllTap(String section) {
    if (section == 'restaurants') {
      // Navigate to All Restaurants screen
      Get.toNamed('/all-restaurants');
    } else {
      // TODO: Navigate to other sections
      Get.snackbar(
        'See All',
        '$section - See all functionality coming soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void navigateToProductDetails({int? productId}) {
    if (productId == null) {
      Get.snackbar(
        'خطأ',
        'معرف المنتج غير صحيح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    Get.toNamed(
      AppRoutes.PRODUCT_DETAILS,
      arguments: {'productId': productId},
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
          homeRestaurants.addAll(
              List<Map<String, dynamic>>.from(data['featured_restaurants']));
        }
        if (data['nearby_restaurants'] != null) {
          homeRestaurants.addAll(
              List<Map<String, dynamic>>.from(data['nearby_restaurants']));
        }

        // Update home products (popular + trending)
        homeProducts.clear();
        if (data['popular_products'] != null) {
          homeProducts.addAll(
              List<Map<String, dynamic>>.from(data['popular_products']));
        }
        if (data['trending_products'] != null) {
          homeProducts.addAll(
              List<Map<String, dynamic>>.from(data['trending_products']));
        }

        // Apply current filter after loading home data
        _applyCurrentFilter();

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
      loadBanners(),
    ]);
  }

  /// Load banners from backend
  Future<void> loadBanners() async {
    try {
      isLoadingBanners.value = true;

      if (kDebugMode) {
        print('🎨 HOME: Loading banners...');
      }

      final loadedBanners = await _bannerService.getBanners();
      banners.value = loadedBanners;

      if (kDebugMode) {
        print('✅ HOME: Loaded ${banners.length} banners');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HOME: Failed to load banners: $e');
      }
    } finally {
      isLoadingBanners.value = false;
    }
  }

  /// Handle banner tap based on banner type
  void handleBannerTap(BannerModel banner) {
    if (kDebugMode) {
      print('🎨 Banner tapped: ${banner.type}');
    }

    switch (banner.type) {
      case 'image_only':
        // No action for image only
        break;

      case 'image_text':
        // No action for image text (just display)
        break;

      case 'external_link':
        if (banner.externalUrl != null) {
          // Open URL in WebView
          Get.to(() => WebViewScreen(
                url: banner.externalUrl!,
                title: banner.getTitle(Get.locale?.languageCode ?? 'en'),
              ));
        }
        break;

      case 'store_link':
        if (banner.restaurant != null) {
          // Navigate to restaurant/store details
          Get.toNamed(
            '${AppRoutes.STORE_DETAILS}?id=${banner.restaurant!.id}',
          );
        }
        break;

      case 'product_link':
        if (banner.product != null) {
          // Navigate to product details
          Get.toNamed(
            '${AppRoutes.PRODUCT_DETAILS}?id=${banner.product!.id}',
          );
        }
        break;

      default:
        if (kDebugMode) {
          print('⚠️ Unknown banner type: ${banner.type}');
        }
    }
  }
}
