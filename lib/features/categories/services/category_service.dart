import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/category_model.dart';
import '../../product_details/models/product_model.dart';

class CategoryService extends GetxService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get categories from backend API
  /// Returns list of CategoryModel that matches Flutter's current structure
  Future<List<CategoryModel>> getCategories() async {
    try {
      print('🔄 FETCHING CATEGORIES: /customer/shopping/categories');
      print('🌐 API BASE URL: ${ApiConstants.baseUrl}');
      print('🎯 FULL URL: ${ApiConstants.baseUrl}/customer/shopping/categories');

      final response = await _apiClient.get('/customer/shopping/categories');

      print('📡 RESPONSE STATUS: ${response.statusCode}');
      print('📦 RESPONSE DATA: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final List<dynamic> data = response.data['data'];
          print('📋 RAW CATEGORIES DATA: $data');

          final categories = data.map((json) => CategoryModel.fromJson(json)).toList();

          print('✅ CATEGORIES LOADED: ${categories.length} categories');
          for (var category in categories) {
            print('   - ${category.name} (ID: ${category.id}, Items: ${category.itemCount})');
          }
          return categories;
        } else {
          print('❌ API SUCCESS FALSE: ${response.data['message']}');
          throw Exception('API returned success: false - ${response.data['message']}');
        }
      } else {
        print('❌ CATEGORIES API ERROR: ${response.statusCode}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ CATEGORIES EXCEPTION: $e');
      throw Exception('Error loading categories: $e');
    }
  }



  /// Get categories page data (categories + kitchens)
  Future<Map<String, dynamic>> getCategoriesPageData() async {
    try {
      if (kDebugMode) {
        print('📡 ${ApiConstants.currentServerInfo}');
        print('🔄 FETCHING CATEGORIES PAGE DATA: ${ApiConstants.baseUrl}${ApiConstants.categoriesPageData}');
      }

      final response = await _apiClient.get(ApiConstants.categoriesPageData);

      if (kDebugMode) {
        print('📡 CATEGORIES PAGE RESPONSE STATUS: ${response.statusCode}');
        print('📦 CATEGORIES PAGE RESPONSE DATA: ${response.data}');
      }

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final pageData = response.data['data'];
          if (kDebugMode) {
            print('📦 CATEGORIES PAGE DATA: $pageData');
            print('📋 CATEGORIES COUNT: ${pageData['categories']?.length ?? 0}');
            print('🏪 KITCHENS COUNT: ${pageData['kitchens']?.length ?? 0}');
          }
          return pageData;
        } else {
          throw Exception('Failed to load categories page data: ${response.data['message']}');
        }
      } else {
        throw Exception('Failed to load categories page data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading categories page data: $e');
      }
      throw Exception('Error loading categories page data: $e');
    }
  }

  /// Get categories with products (combined endpoint)
  /// Returns both categories and products with filtering support
  Future<Map<String, dynamic>> getCategoriesWithProducts({
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? isFeatured,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      print('🔄 FETCHING CATEGORIES WITH PRODUCTS');

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'per_page': perPage,
        'page': page,
      };

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (isFeatured != null) queryParams['is_featured'] = isFeatured;

      final response = await _apiClient.get(
        ApiConstants.categoriesWithProducts,
        queryParameters: queryParams,
      );

      print('📡 RESPONSE STATUS: ${response.statusCode}');
      print('📦 RESPONSE DATA: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final data = response.data['data'];

          // Parse categories
          final List<dynamic> categoriesData = data['categories'];
          final categories = categoriesData.map((json) => CategoryModel.fromJson(json)).toList();

          // Parse products
          final productsData = data['products'];
          final List<dynamic> productsList = productsData['data'];
          final products = productsList.map((json) => ProductModel.fromJson(json)).toList();

          print('✅ LOADED: ${categories.length} categories, ${products.length} products');

          return {
            'categories': categories,
            'products': products,
            'pagination': productsData['pagination'],
            'filters_applied': data['filters_applied'],
          };
        } else {
          throw Exception('API returned success: false - ${response.data['message']}');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ CATEGORIES WITH PRODUCTS EXCEPTION: $e');
      throw Exception('Error loading categories with products: $e');
    }
  }

  /// Refresh categories cache
  Future<void> refreshCategories() async {
    // This will force a fresh API call
    await getCategories();
  }
}
