import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/features/merchant/models/merchant_product_model.dart';
import '../../../core/services/toast_service.dart';

/// Service for managing merchant products
class MerchantProductsService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get all products for the merchant
  Future<List<MerchantProductModel>> getProducts({
    int? categoryId,
    bool? isAvailable,
    bool? isFeatured,
    String? search,
    bool paginated = false,
    int perPage = 15,
  }) async {
    try {
      if (kDebugMode) {
        print('📦 PRODUCTS SERVICE: Getting products...');
      }

      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (isAvailable != null) queryParams['is_available'] = isAvailable;
      if (isFeatured != null) queryParams['is_featured'] = isFeatured;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (paginated) {
        queryParams['paginated'] = true;
        queryParams['per_page'] = perPage;
      }

      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/merchant/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (kDebugMode) {
          print('✅ Products loaded successfully');
          print('📊 Response data type: ${data.runtimeType}');
          print('📊 Response data keys: ${data is Map ? data.keys.toList() : 'not a map'}');
        }

        // Handle paginated response with 'items' key
        if (data is Map && data.containsKey('items')) {
          final items = data['items'] as List;
          if (kDebugMode) {
            print('📦 Parsing ${items.length} products from paginated response...');
          }

          final products = <MerchantProductModel>[];
          for (var i = 0; i < items.length; i++) {
            try {
              final product = MerchantProductModel.fromJson(items[i]);
              products.add(product);
              if (kDebugMode) {
                print('✅ Product ${i + 1}/${items.length} parsed: ${product.nameEn}');
              }
            } catch (e, stackTrace) {
              if (kDebugMode) {
                print('❌ Error parsing product ${i + 1}/${items.length}: $e');
                print('📄 Product JSON: ${items[i]}');
                print('📄 Stack trace: $stackTrace');
              }
            }
          }

          if (kDebugMode) {
            print('✅ Successfully parsed ${products.length}/${items.length} products');
          }
          return products;
        }

        // Handle paginated response with 'data' key
        if (data is Map && data.containsKey('data')) {
          final items = data['data'] as List;
          if (kDebugMode) {
            print('📦 Parsing ${items.length} products from data key...');
          }

          final products = <MerchantProductModel>[];
          for (var i = 0; i < items.length; i++) {
            try {
              final product = MerchantProductModel.fromJson(items[i]);
              products.add(product);
            } catch (e) {
              if (kDebugMode) {
                print('❌ Error parsing product ${i + 1}: $e');
              }
            }
          }
          return products;
        }

        // Handle non-paginated response (direct array)
        if (data is List) {
          if (kDebugMode) {
            print('📦 Parsing ${data.length} products from direct array...');
          }

          final products = <MerchantProductModel>[];
          for (var i = 0; i < data.length; i++) {
            try {
              final product = MerchantProductModel.fromJson(data[i]);
              products.add(product);
            } catch (e) {
              if (kDebugMode) {
                print('❌ Error parsing product ${i + 1}: $e');
              }
            }
          }
          return products;
        }

        if (kDebugMode) {
          print('⚠️ Unknown response structure');
        }
        return [];
      }

      if (kDebugMode) {
        print('❌ Failed to load products: ${response.statusCode}');
      }
      return [];
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error loading products: ${e.message}');
        print('📄 Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error loading products: $e');
      }
      rethrow;
    }
  }

  /// Get single product details
  Future<MerchantProductModel?> getProduct(int productId) async {
    try {
      if (kDebugMode) {
        print('📦 PRODUCTS SERVICE: Getting product $productId...');
      }

      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/merchant/products/$productId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        
        if (kDebugMode) {
          print('✅ Product loaded successfully');
        }

        return MerchantProductModel.fromJson(data);
      }

      if (kDebugMode) {
        print('❌ Failed to load product: ${response.statusCode}');
      }
      return null;
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error loading product: ${e.message}');
        print('📄 Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error loading product: $e');
      }
      rethrow;
    }
  }

  /// Create new product
  Future<MerchantProductModel?> createProduct(Map<String, dynamic> productData) async {
    try {
      if (kDebugMode) {
        print('📦 PRODUCTS SERVICE: Creating product...');
        print('📄 Data: $productData');
      }

      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/merchant/products',
        data: productData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'];
        
        if (kDebugMode) {
          print('✅ Product created successfully');
        }

        ToastService.showSuccess('product_created_successfully'.tr);

        return MerchantProductModel.fromJson(data);
      }

      if (kDebugMode) {
        print('❌ Failed to create product: ${response.statusCode}');
      }
      return null;
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error creating product: ${e.message}');
        print('📄 Response: ${e.response?.data}');
      }

      // Show error message
      final errorMessage = e.response?.data['message'] ?? 'failed_to_create_product'.tr;
      ToastService.showError(errorMessage);

      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error creating product: $e');
      }

      ToastService.showError('unexpected_error'.tr);

      rethrow;
    }
  }

  /// Update existing product
  Future<MerchantProductModel?> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      if (kDebugMode) {
        print('📦 PRODUCTS SERVICE: Updating product $productId...');
        print('📄 Data: $productData');
      }

      final response = await _apiClient.put(
        '${ApiConstants.baseUrl}/merchant/products/$productId',
        data: productData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        
        if (kDebugMode) {
          print('✅ Product updated successfully');
        }

        ToastService.showSuccess('product_updated_successfully'.tr);

        return MerchantProductModel.fromJson(data);
      }

      if (kDebugMode) {
        print('❌ Failed to update product: ${response.statusCode}');
      }
      return null;
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error updating product: ${e.message}');
        print('📄 Response: ${e.response?.data}');
      }

      // Show error message
      final errorMessage = e.response?.data['message'] ?? 'failed_to_update_product'.tr;
      ToastService.showError(errorMessage);

      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error updating product: $e');
      }

      ToastService.showError('unexpected_error'.tr);

      rethrow;
    }
  }

  /// Delete product
  Future<bool> deleteProduct(int productId) async {
    try {
      if (kDebugMode) {
        print('📦 PRODUCTS SERVICE: Deleting product $productId...');
      }

      final response = await _apiClient.delete(
        '${ApiConstants.baseUrl}/merchant/products/$productId',
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Product deleted successfully');
        }

        ToastService.showSuccess('product_deleted_successfully'.tr);

        return true;
      }

      if (kDebugMode) {
        print('❌ Failed to delete product: ${response.statusCode}');
      }
      return false;
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting product: ${e.message}');
        print('📄 Response: ${e.response?.data}');
      }

      // Show error message
      final errorMessage = e.response?.data['message'] ?? 'failed_to_delete_product'.tr;
      ToastService.showError(errorMessage);

      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error deleting product: $e');
      }

      ToastService.showError('unexpected_error'.tr);

      rethrow;
    }
  }

  /// Toggle product availability
  Future<bool> toggleAvailability(int productId, bool isAvailable) async {
    try {
      if (kDebugMode) {
        print('📦 PRODUCTS SERVICE: Toggling availability for product $productId...');
      }

      final response = await _apiClient.patch(
        '${ApiConstants.baseUrl}/merchant/products/$productId/toggle-availability',
        data: {'is_available': isAvailable},
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Product availability toggled successfully');
        }

        ToastService.showSuccess(isAvailable ? 'product_now_available'.tr : 'product_now_unavailable'.tr);

        return true;
      }

      if (kDebugMode) {
        print('❌ Failed to toggle availability: ${response.statusCode}');
      }
      return false;
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling availability: ${e.message}');
        print('📄 Response: ${e.response?.data}');
      }

      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error toggling availability: $e');
      }

      rethrow;
    }
  }

  /// Upload product image
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      if (kDebugMode) {
        print('📤 PRODUCTS SERVICE: Uploading product image...');
      }

      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'directory': 'product_images',
      });

      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/images/upload-product',
        data: formData,
      );

      if (response.statusCode == 200) {
        final imagePath = response.data['data']?['path'];

        if (kDebugMode) {
          print('✅ Image uploaded successfully: $imagePath');
        }

        return imagePath;
      }

      if (kDebugMode) {
        print('❌ Failed to upload image: ${response.statusCode}');
      }
      return null;
    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading image: ${e.message}');
        print('📄 Response: ${e.response?.data}');
      }

      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error uploading image: $e');
      }

      rethrow;
    }
  }

  /// Get food nationalities for lookup
  Future<List<Map<String, dynamic>>> getFoodNationalities({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/lookups/food-nationalities',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading food nationalities: $e');
      }
      return [];
    }
  }

  /// Get governorates for lookup
  Future<List<Map<String, dynamic>>> getGovernorates({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/lookups/governorates',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading governorates: $e');
      }
      return [];
    }
  }
}

