import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import '../../../core/services/toast_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';

class AllProductsController extends GetxController {
  // Product type: 'best_seller' or 'recently_added'
  final String productType;
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  // All products
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  
  // Filtered products (for search)
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  
  // Search query
  final RxString searchQuery = ''.obs;

  // API Client
  final ApiClient _apiClient = ApiClient.instance;

  AllProductsController({required this.productType});

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  /// Fetch products based on type
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'per_page': 100,
      };

      if (productType == 'best_seller') {
        // Fetch best seller products (sorted by total_orders)
        queryParams['sort_by'] = 'total_orders';
        queryParams['sort_order'] = 'desc';
      } else {
        // Fetch recently added products (sorted by created_at)
        queryParams['sort_by'] = 'created_at';
        queryParams['sort_order'] = 'desc';
      }

      if (kDebugMode) {
        print('🔍 ALL PRODUCTS: Fetching $productType products...');
        print('📊 Query params: $queryParams');
      }

      // Use the filtered-products endpoint
      final response = await _apiClient.get(
        ApiConstants.filteredProducts,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> productsData = data['data'] ?? data['products'] ?? [];

        final products = productsData.map((json) => ProductModel.fromJson(json)).toList();

        allProducts.value = products;
        filteredProducts.value = products;

        if (kDebugMode) {
          print('✅ ALL PRODUCTS ($productType): Fetched ${allProducts.length} products');
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ALL PRODUCTS ERROR: $e');
      }
      ToastService.showError('failed_to_load_products'.tr);
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      filteredProducts.value = allProducts;
      return;
    }
    
    filteredProducts.value = allProducts.where((product) {
      final name = product.name.toLowerCase();
      final description = product.description.toLowerCase();
      final searchLower = query.toLowerCase();
      
      return name.contains(searchLower) || description.contains(searchLower);
    }).toList();
    
    if (kDebugMode) {
      print('🔍 SEARCH: "$query" - Found ${filteredProducts.length} products');
    }
  }
  
  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    filteredProducts.value = allProducts;
  }
  
  /// Refresh products
  Future<void> refreshProducts() async {
    await fetchProducts();
  }
  
  /// Navigate to product details
  void navigateToProductDetails(ProductModel product) {
    Get.toNamed('/product-details', arguments: {'productId': product.id});
  }
  
  /// Go back
  void goBack() {
    Get.back();
  }
  
  /// Get screen title
  String get screenTitle {
    return productType == 'best_seller' ? 'best_seller'.tr : 'recently'.tr;
  }
}

