import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/favorites/models/favorite_store_model.dart';
import 'package:mrsheaf/features/favorites/models/favorite_product_model.dart';
import 'package:mrsheaf/features/favorites/services/favorites_service.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';

class FavoritesController extends GetxController {
  final FavoritesService _favoritesService = FavoritesService();

  // Tab management
  final RxInt selectedTabIndex = 0.obs;

  // Favorite stores
  final RxList<FavoriteStoreModel> favoriteStores = <FavoriteStoreModel>[].obs;

  // Favorite products
  final RxList<FavoriteProductModel> favoriteProducts = <FavoriteProductModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingStores = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  /// Load favorites from server
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        print('🤍 FAVORITES CONTROLLER: Loading favorites...');
      }

      final favorites = await _favoritesService.getFavorites();

      // Parse products
      final products = favorites['products'] as List<dynamic>;
      favoriteProducts.value = products.map((productData) {
        // Convert API data to the format expected by FavoriteProductModel
        final convertedData = {
          'id': productData['id'],
          'name': productData['name'],
          'image': productData['image'],
          'price': productData['price'], // Will be parsed by _parsePrice
          'is_available': productData['is_available'] ?? true,
        };
        return FavoriteProductModel.fromJson(convertedData);
      }).toList();

      // Parse merchants/stores
      final merchants = favorites['merchants'] as List<dynamic>;
      favoriteStores.value = merchants.map((merchantData) {
        return FavoriteStoreModel.fromJson(merchantData);
      }).toList();

      if (kDebugMode) {
        print('✅ FAVORITES CONTROLLER: Favorites loaded successfully');
        print('🤍 PRODUCTS: ${favoriteProducts.length}');
        print('🤍 STORES: ${favoriteStores.length}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES CONTROLLER ERROR: $e');
      }

      Get.snackbar(
        'خطأ',
        'فشل في تحميل المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh favorites
  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  // Tab switching
  void switchTab(int index) {
    selectedTabIndex.value = index;
  }

  // Store management
  Future<void> addStoreToFavorites(int storeId) async {
    try {
      isLoadingStores.value = true;

      await _favoritesService.addMerchantToFavorites(storeId);

      // Reload favorites to get updated list
      await loadFavorites();

      Get.snackbar(
        'تمت الإضافة',
        'تم إضافة المتجر إلى المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFACD02),
        colorText: const Color(0xFF592E2C),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ADD STORE TO FAVORITES ERROR: $e');
      }

      Get.snackbar(
        'خطأ',
        'فشل في إضافة المتجر إلى المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingStores.value = false;
    }
  }

  Future<void> removeStoreFromFavorites(int storeId) async {
    try {
      isLoadingStores.value = true;

      await _favoritesService.removeMerchantFromFavorites(storeId);

      // Remove from local list immediately for better UX
      favoriteStores.removeWhere((store) => store.id == storeId);

      Get.snackbar(
        'تم الحذف',
        'تم حذف المتجر من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEB5757),
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ REMOVE STORE FROM FAVORITES ERROR: $e');
      }

      // Reload favorites in case of error
      await loadFavorites();

      Get.snackbar(
        'خطأ',
        'فشل في حذف المتجر من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingStores.value = false;
    }
  }

  bool isStoreFavorite(int storeId) {
    return favoriteStores.any((store) => store.id == storeId);
  }

  // Product management
  Future<void> addProductToFavorites(int productId) async {
    try {
      isLoadingProducts.value = true;

      await _favoritesService.addProductToFavorites(productId);

      // Reload favorites to get updated list
      await loadFavorites();

      Get.snackbar(
        'تمت الإضافة',
        'تم إضافة المنتج إلى المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFACD02),
        colorText: const Color(0xFF592E2C),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ADD PRODUCT TO FAVORITES ERROR: $e');
      }

      Get.snackbar(
        'خطأ',
        'فشل في إضافة المنتج إلى المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> removeProductFromFavorites(int productId) async {
    try {
      isLoadingProducts.value = true;

      await _favoritesService.removeProductFromFavorites(productId);

      // Remove from local list immediately for better UX
      favoriteProducts.removeWhere((product) => product.id == productId);

      Get.snackbar(
        'تم الحذف',
        'تم حذف المنتج من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEB5757),
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ REMOVE PRODUCT FROM FAVORITES ERROR: $e');
      }

      // Reload favorites in case of error
      await loadFavorites();

      Get.snackbar(
        'خطأ',
        'فشل في حذف المنتج من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  bool isProductFavorite(int productId) {
    return favoriteProducts.any((product) => product.id == productId);
  }

  /// Check if product is favorited from server
  Future<bool> checkProductFavoriteStatus(int productId) async {
    try {
      return await _favoritesService.isFavorited('product', productId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ CHECK PRODUCT FAVORITE STATUS ERROR: $e');
      }
      return false;
    }
  }

  /// Check if merchant is favorited from server
  Future<bool> checkMerchantFavoriteStatus(int merchantId) async {
    try {
      return await _favoritesService.isFavorited('merchant', merchantId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ CHECK MERCHANT FAVORITE STATUS ERROR: $e');
      }
      return false;
    }
  }

  // Add to cart functionality
  void addToCart(FavoriteProductModel favoriteProduct) {
    if (!favoriteProduct.isAvailable) {
      Get.snackbar(
        'Out of Stock',
        'This product is currently out of stock',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEB5757),
        colorText: Colors.white,
      );
      return;
    }

    final cartController = Get.find<CartController>();
    
    // Convert FavoriteProductModel to ProductModel
    final product = ProductModel(
      id: favoriteProduct.id,
      name: favoriteProduct.name,
      description: 'Fresh and delicious ${favoriteProduct.name}',
      price: favoriteProduct.price,
      image: favoriteProduct.image,
      rating: 4.5,
      reviewCount: 120,
      productCode: '#${favoriteProduct.id.toString().padLeft(8, '0')}',
      sizes: ['L', 'M', 'S'],
      rawSizes: [],
      images: [favoriteProduct.image],
      additionalOptions: [],
    );
    
    cartController.addToCart(
      product: product,
      size: 'M', // Default size
      quantity: 1, // Default quantity
      additionalOptions: [],
    );
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      isLoading.value = true;

      final deletedCount = await _favoritesService.clearAllFavorites();

      // Clear local lists
      favoriteStores.clear();
      favoriteProducts.clear();

      Get.snackbar(
        'تم المسح',
        'تم مسح جميع المفضلة ($deletedCount عنصر)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEB5757),
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ CLEAR ALL FAVORITES ERROR: $e');
      }

      Get.snackbar(
        'خطأ',
        'فشل في مسح المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Getters for UI
  bool get hasAnyFavorites => favoriteStores.isNotEmpty || favoriteProducts.isNotEmpty;
  
  bool get isStoresTabSelected => selectedTabIndex.value == 0;
  
  bool get isProductsTabSelected => selectedTabIndex.value == 1;
  
  bool get showEmptyState {
    if (isStoresTabSelected) {
      return favoriteStores.isEmpty;
    } else {
      return favoriteProducts.isEmpty;
    }
  }

  /// Navigate to store details page
  void navigateToStoreDetails(int storeId) {
    Get.toNamed('/store-details', arguments: {'restaurantId': storeId});
  }

  /// Navigate to product details page
  void navigateToProductDetails(int productId) {
    Get.toNamed('/product-details', arguments: {'productId': productId});
  }
}
