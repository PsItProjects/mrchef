import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';

class HomeController extends GetxController {
  // Observable variables for home screen state
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt currentBannerIndex = 0.obs;
  final ApiClient _apiClient = ApiClient.instance;
  
  // Categories for the filter section
  final List<String> categories = [
    'Popular',
    'Vegan',
    'Natural',
    'Dermatologically'
  ];
  
  // Kitchen data
  final RxList<Map<String, dynamic>> kitchens = <Map<String, dynamic>>[
    {
      'id': 1,
      'name': 'Master chef',
      'image': 'assets/kitchen_1.png',
      'isActive': true,
    },
    {
      'id': 2,
      'name': 'Master chef',
      'image': 'assets/kitchen_2.png',
      'isActive': true,
    },
    {
      'id': 3,
      'name': 'Master chef',
      'image': 'assets/kitchen_3.png',
      'isActive': true,
    },
  ].obs;
  
  // Best seller products
  final RxList<Map<String, dynamic>> bestSellerProducts = <Map<String, dynamic>>[
    {
      'id': 1,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
    {
      'id': 2,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
    {
      'id': 3,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
  ].obs;
  
  // Back again products (same structure as best seller for now)
  final RxList<Map<String, dynamic>> backAgainProducts = <Map<String, dynamic>>[
    {
      'id': 4,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
    {
      'id': 5,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
    {
      'id': 6,
      'name': 'Special beef burger',
      'price': 16,
      'image': 'assets/burger.png',
      'isFavorite': false,
    },
  ].obs;

  // Loading states
  final RxBool isLoadingProducts = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProductsFromBackend();
    _setupLanguageListener();
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

        // Clear existing mock data
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
      // Keep mock data if API fails
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
      return 'assets/burger.png'; // fallback to local asset
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
}
