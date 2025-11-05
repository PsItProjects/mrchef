import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/merchant/models/merchant_product_model.dart';
import 'package:mrsheaf/features/merchant/services/merchant_products_service.dart';

/// Controller for managing merchant products
class MerchantProductsController extends GetxController {
  final MerchantProductsService _productsService = Get.find<MerchantProductsService>();

  // Observable lists
  final RxList<MerchantProductModel> products = <MerchantProductModel>[].obs;
  final RxList<MerchantProductModel> filteredProducts = <MerchantProductModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Selected product
  final Rx<MerchantProductModel?> selectedProduct = Rx<MerchantProductModel?>(null);

  // Filters
  final RxInt selectedCategoryId = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterType = 'all'.obs; // all, available, unavailable, featured

  // Statistics
  final RxInt totalProducts = 0.obs;
  final RxInt availableProducts = 0.obs;
  final RxInt unavailableProducts = 0.obs;
  final RxInt featuredProducts = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();

    // Listen to search query changes
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 500));
  }

  /// Load all products
  Future<void> loadProducts({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      if (kDebugMode) {
        print('📦 PRODUCTS CONTROLLER: Loading products...');
      }

      final loadedProducts = await _productsService.getProducts();

      products.value = loadedProducts;
      _applyFilters();
      _updateStatistics();

      if (kDebugMode) {
        print('✅ Products loaded: ${products.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading products: $e');
      }

      Get.snackbar(
        'error'.tr,
        'failed_to_load_products'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Refresh products
  Future<void> refreshProducts() async {
    isRefreshing.value = true;
    await loadProducts(showLoading: false);
  }

  /// Load single product
  Future<void> loadProduct(int productId) async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        print('📦 PRODUCTS CONTROLLER: Loading product $productId...');
      }

      final product = await _productsService.getProduct(productId);

      if (product != null) {
        selectedProduct.value = product;

        if (kDebugMode) {
          print('✅ Product loaded: ${product.name}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading product: $e');
      }

      Get.snackbar(
        'error'.tr,
        'failed_to_load_product'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new product
  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        print('📦 PRODUCTS CONTROLLER: Creating product...');
      }

      final product = await _productsService.createProduct(productData);

      if (product != null) {
        products.add(product);
        _applyFilters();
        _updateStatistics();

        if (kDebugMode) {
          print('✅ Product created: ${product.name}');
        }

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating product: $e');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update existing product
  Future<bool> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        print('📦 PRODUCTS CONTROLLER: Updating product $productId...');
      }

      final product = await _productsService.updateProduct(productId, productData);

      if (product != null) {
        final index = products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          products[index] = product;
          _applyFilters();
          _updateStatistics();
        }

        if (kDebugMode) {
          print('✅ Product updated: ${product.name}');
        }

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating product: $e');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete product
  Future<bool> deleteProduct(int productId) async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        print('📦 PRODUCTS CONTROLLER: Deleting product $productId...');
      }

      final success = await _productsService.deleteProduct(productId);

      if (success) {
        products.removeWhere((p) => p.id == productId);
        _applyFilters();
        _updateStatistics();

        if (kDebugMode) {
          print('✅ Product deleted');
        }

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting product: $e');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle product availability
  Future<void> toggleAvailability(int productId, bool isAvailable) async {
    try {
      final success = await _productsService.toggleAvailability(productId, isAvailable);

      if (success) {
        final index = products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          products[index] = products[index].copyWith(isAvailable: isAvailable);
          _applyFilters();
          _updateStatistics();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling availability: $e');
      }
    }
  }

  /// Apply filters to products
  void _applyFilters() {
    var filtered = products.toList();

    // Apply category filter
    if (selectedCategoryId.value > 0) {
      filtered = filtered.where((p) => p.categoryId == selectedCategoryId.value).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((p) {
        return p.nameEn.toLowerCase().contains(query) ||
            p.nameAr.toLowerCase().contains(query) ||
            (p.descriptionEn?.toLowerCase().contains(query) ?? false) ||
            (p.descriptionAr?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply type filter
    switch (filterType.value) {
      case 'available':
        filtered = filtered.where((p) => p.isAvailable).toList();
        break;
      case 'unavailable':
        filtered = filtered.where((p) => !p.isAvailable).toList();
        break;
      case 'featured':
        filtered = filtered.where((p) => p.isFeatured).toList();
        break;
      default:
        break;
    }

    filteredProducts.value = filtered;
  }

  /// Update statistics
  void _updateStatistics() {
    totalProducts.value = products.length;
    availableProducts.value = products.where((p) => p.isAvailable).length;
    unavailableProducts.value = products.where((p) => !p.isAvailable).length;
    featuredProducts.value = products.where((p) => p.isFeatured).length;
  }

  /// Set filter type
  void setFilterType(String type) {
    filterType.value = type;
    _applyFilters();
  }

  /// Set category filter
  void setCategoryFilter(int categoryId) {
    selectedCategoryId.value = categoryId;
    _applyFilters();
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Clear filters
  void clearFilters() {
    selectedCategoryId.value = 0;
    searchQuery.value = '';
    filterType.value = 'all';
    _applyFilters();
  }
}

