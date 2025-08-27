import 'package:get/get.dart';
import '../../../core/services/api_client.dart';
import '../models/category_model.dart';

class CategoryService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get categories from backend API
  /// Returns list of CategoryModel that matches Flutter's current structure
  Future<List<CategoryModel>> getCategories() async {
    try {
      print('🔄 FETCHING CATEGORIES: /customer/categories');
      
      final response = await _apiClient.get('/customer/categories');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        
        print('✅ CATEGORIES LOADED: ${categories.length} categories');
        return categories;
      } else {
        print('❌ CATEGORIES API ERROR: ${response.statusCode}');
        return _getFallbackCategories();
      }
      
    } catch (e) {
      print('❌ CATEGORIES EXCEPTION: $e');
      return _getFallbackCategories();
    }
  }

  /// Get products for a specific category
  Future<Map<String, dynamic>> getCategoryProducts(int categoryId, {
    int page = 1,
    int perPage = 20,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      print('🔄 FETCHING CATEGORY PRODUCTS: /customer/categories/$categoryId/products');
      
      final response = await _apiClient.get(
        '/customer/categories/$categoryId/products',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'sort_by': sortBy,
          'sort_order': sortOrder,
        },
      );
      
      if (response.statusCode == 200) {
        print('✅ CATEGORY PRODUCTS LOADED');
        return response.data['data'];
      } else {
        print('❌ CATEGORY PRODUCTS API ERROR: ${response.statusCode}');
        return {};
      }
      
    } catch (e) {
      print('❌ CATEGORY PRODUCTS EXCEPTION: $e');
      return {};
    }
  }

  /// Fallback categories when API fails
  /// These are the same categories currently hardcoded in CategoriesController
  List<CategoryModel> _getFallbackCategories() {
    print('📦 USING FALLBACK CATEGORIES');
    
    return [
      CategoryModel(
        id: 1, 
        name: 'Popular', 
        icon: 'popular', 
        itemCount: 29, 
        isSelected: true
      ),
      CategoryModel(
        id: 2, 
        name: 'Dessert', 
        icon: 'dessert', 
        itemCount: 9
      ),
      CategoryModel(
        id: 3, 
        name: 'Pastries', 
        icon: 'pastries', 
        itemCount: 11
      ),
      CategoryModel(
        id: 4, 
        name: 'Drink', 
        icon: 'drink', 
        itemCount: 5
      ),
      CategoryModel(
        id: 5, 
        name: 'Pickles', 
        icon: 'pickles', 
        itemCount: 12
      ),
      CategoryModel(
        id: 6, 
        name: 'Pizza', 
        icon: 'pizza', 
        itemCount: 8
      ),
    ];
  }

  /// Refresh categories cache
  Future<void> refreshCategories() async {
    // This will force a fresh API call
    await getCategories();
  }
}
