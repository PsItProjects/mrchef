import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/favorites/models/favorite_store_model.dart';
import 'package:mrsheaf/features/favorites/models/favorite_product_model.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';

class FavoritesController extends GetxController {
  // Tab management
  final RxInt selectedTabIndex = 0.obs;
  
  // Favorite stores
  final RxList<FavoriteStoreModel> favoriteStores = <FavoriteStoreModel>[].obs;
  
  // Favorite products
  final RxList<FavoriteProductModel> favoriteProducts = <FavoriteProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Add sample favorite stores
    favoriteStores.addAll([
      FavoriteStoreModel(
        id: 1,
        name: 'Al Shorouk Restaurant',
        image: 'assets/images/store_logo.png',
        rating: 4.8,
        backgroundImage: 'assets/images/store_background.png',
      ),
      FavoriteStoreModel(
        id: 2,
        name: 'Al Shorouk Restaurant',
        image: 'assets/images/store_logo.png',
        rating: 4.8,
        backgroundImage: 'assets/images/store_background.png',
      ),
    ]);

    // Add sample favorite products
    favoriteProducts.addAll([
      FavoriteProductModel(
        id: 1,
        name: 'Caesar salad',
        image: 'assets/images/pizza_main.png',
        price: 25.00,
        availability: ProductAvailability.available,
      ),
      FavoriteProductModel(
        id: 2,
        name: 'Caesar salad',
        image: 'assets/images/pizza_main.png',
        price: 25.00,
        availability: ProductAvailability.outOfStock,
      ),
    ]);
  }

  // Add sample data for testing
  void addSampleData() {
    _initializeSampleData();
  }

  // Tab switching
  void switchTab(int index) {
    selectedTabIndex.value = index;
  }

  // Store management
  void addStoreToFavorites(FavoriteStoreModel store) {
    if (!favoriteStores.any((s) => s.id == store.id)) {
      favoriteStores.add(store);
      Get.snackbar(
        'Added to Favorites',
        '${store.name} added to your favorite stores',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeStoreFromFavorites(int storeId) {
    favoriteStores.removeWhere((store) => store.id == storeId);
    Get.snackbar(
      'Removed from Favorites',
      'Store removed from your favorites',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool isStoreFavorite(int storeId) {
    return favoriteStores.any((store) => store.id == storeId);
  }

  // Product management
  void addProductToFavorites(FavoriteProductModel product) {
    if (!favoriteProducts.any((p) => p.id == product.id)) {
      favoriteProducts.add(product);
      Get.snackbar(
        'Added to Favorites',
        '${product.name} added to your favorite products',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeProductFromFavorites(int productId) {
    favoriteProducts.removeWhere((product) => product.id == productId);
    Get.snackbar(
      'Removed from Favorites',
      'Product removed from your favorites',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool isProductFavorite(int productId) {
    return favoriteProducts.any((product) => product.id == productId);
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
  void clearAllFavorites() {
    favoriteStores.clear();
    favoriteProducts.clear();
    Get.snackbar(
      'Favorites Cleared',
      'All favorites have been removed',
      snackPosition: SnackPosition.BOTTOM,
    );
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
}
