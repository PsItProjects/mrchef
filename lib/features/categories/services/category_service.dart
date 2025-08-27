import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/api_response.dart';
import '../models/category_model.dart';

class CategoryService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Get all categories from backend
  Future<ApiResponse<List<BackendCategoryModel>>> getCategories() async {
    try {
      print('📋 GET CATEGORIES REQUEST: /customer/categories');

      final response = await _apiClient.get('/customer/categories');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) {
            if (data is List) {
              return data
                  .map((categoryJson) => BackendCategoryModel.fromJson(categoryJson))
                  .toList();
            } else if (data is Map && data['data'] is List) {
              return (data['data'] as List)
                  .map((categoryJson) => BackendCategoryModel.fromJson(categoryJson))
                  .toList();
            }
            return <BackendCategoryModel>[];
          },
        );

        return apiResponse;
      } else {
        return ApiResponse<List<BackendCategoryModel>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get categories',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<List<BackendCategoryModel>>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<BackendCategoryModel>>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // Get home categories (for home screen filter)
  Future<ApiResponse<List<BackendCategoryModel>>> getHomeCategories() async {
    try {
      print('🏠 GET HOME CATEGORIES REQUEST: /customer/home-categories');

      final response = await _apiClient.get('/customer/home-categories');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) {
            if (data is List) {
              return data
                  .map((categoryJson) => BackendCategoryModel.fromJson(categoryJson))
                  .toList();
            } else if (data is Map && data['data'] is List) {
              return (data['data'] as List)
                  .map((categoryJson) => BackendCategoryModel.fromJson(categoryJson))
                  .toList();
            }
            return <BackendCategoryModel>[];
          },
        );

        return apiResponse;
      } else {
        return ApiResponse<List<BackendCategoryModel>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get home categories',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<List<BackendCategoryModel>>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<BackendCategoryModel>>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // Get products by category
  Future<ApiResponse<Map<String, dynamic>>> getCategoryProducts(
    int categoryId, {
    int page = 1,
    int perPage = 20,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      print('🍽️ GET CATEGORY PRODUCTS REQUEST: /customer/categories/$categoryId/products');

      final queryParams = {
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      final response = await _apiClient.get(
        '/customer/categories/$categoryId/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Products retrieved successfully',
          data: response.data,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get category products',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
        errors: e.response?.data['errors'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // Convert backend categories to legacy format for UI compatibility
  List<CategoryModel> convertToLegacyCategories(List<BackendCategoryModel> backendCategories) {
    return backendCategories
        .where((category) => category.isActive)
        .map((category) => category.toLegacyModel())
        .toList();
  }

  // Get category icon based on name or ID
  String getCategoryIcon(String categoryName, int categoryId) {
    // Map category names to icons
    final iconMap = {
      'popular': 'popular',
      'dessert': 'dessert',
      'pastries': 'pastries',
      'drink': 'drink',
      'pickles': 'pickles',
      'pizza': 'pizza',
      'burger': 'burger',
      'salad': 'salad',
      'soup': 'soup',
      'meat': 'meat',
      'chicken': 'chicken',
      'seafood': 'seafood',
      'vegetarian': 'vegetarian',
      'breakfast': 'breakfast',
      'lunch': 'lunch',
      'dinner': 'dinner',
    };

    final lowerName = categoryName.toLowerCase();
    
    // Try to find exact match
    for (final entry in iconMap.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default icon based on category ID
    return 'category_${categoryId % 10}';
  }
}
