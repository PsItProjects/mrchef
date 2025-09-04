import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/features/favorites/models/favorite_product_model.dart';
import 'package:mrsheaf/features/favorites/models/favorite_store_model.dart';

class FavoritesService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all favorites (products and merchants)
  Future<Map<String, dynamic>> getFavorites({String? type}) async {
    try {
      if (kDebugMode) {
        print('🤍 FAVORITES SERVICE: Getting favorites...');
        print('🤍 TYPE: $type');
      }

      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/customer/shopping/favorites',
        queryParameters: type != null ? {'type': type} : null,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        if (kDebugMode) {
          print('✅ FAVORITES SERVICE: Favorites retrieved successfully');
          print('🤍 PRODUCTS COUNT: ${data['products']?.length ?? 0}');
          print('🤍 MERCHANTS COUNT: ${data['merchants']?.length ?? 0}');
        }

        return {
          'products': data['products'] ?? [],
          'merchants': data['merchants'] ?? [],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get favorites');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Add product to favorites
  Future<Map<String, dynamic>> addProductToFavorites(int productId) async {
    try {
      if (kDebugMode) {
        print('🤍 FAVORITES SERVICE: Adding product to favorites...');
        print('🤍 PRODUCT ID: $productId');
      }

      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/favorites/products/$productId',
      );

      if (response.data['success'] == true) {
        if (kDebugMode) {
          print('✅ FAVORITES SERVICE: Product added to favorites successfully');
        }
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add product to favorites');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Remove product from favorites
  Future<bool> removeProductFromFavorites(int productId) async {
    try {
      if (kDebugMode) {
        print('💔 FAVORITES SERVICE: Removing product from favorites...');
        print('💔 PRODUCT ID: $productId');
      }

      final response = await _apiClient.delete(
        '${ApiConstants.baseUrl}/customer/shopping/favorites/products/$productId',
      );

      if (response.data['success'] == true) {
        final wasRemoved = response.data['data']['was_removed'] ?? false;
        if (kDebugMode) {
          print('✅ FAVORITES SERVICE: Product removed from favorites');
          print('💔 WAS REMOVED: $wasRemoved');
        }
        return wasRemoved;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to remove product from favorites');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Add merchant to favorites
  Future<Map<String, dynamic>> addMerchantToFavorites(int merchantId) async {
    try {
      if (kDebugMode) {
        print('🤍 FAVORITES SERVICE: Adding merchant to favorites...');
        print('🤍 MERCHANT ID: $merchantId');
      }

      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/favorites/merchants/$merchantId',
      );

      if (response.data['success'] == true) {
        if (kDebugMode) {
          print('✅ FAVORITES SERVICE: Merchant added to favorites successfully');
        }
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add merchant to favorites');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Remove merchant from favorites
  Future<bool> removeMerchantFromFavorites(int merchantId) async {
    try {
      if (kDebugMode) {
        print('💔 FAVORITES SERVICE: Removing merchant from favorites...');
        print('💔 MERCHANT ID: $merchantId');
      }

      final response = await _apiClient.delete(
        '${ApiConstants.baseUrl}/customer/shopping/favorites/merchants/$merchantId',
      );

      if (response.data['success'] == true) {
        final wasRemoved = response.data['data']['was_removed'] ?? false;
        if (kDebugMode) {
          print('✅ FAVORITES SERVICE: Merchant removed from favorites');
          print('💔 WAS REMOVED: $wasRemoved');
        }
        return wasRemoved;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to remove merchant from favorites');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Check if item is favorited
  Future<bool> isFavorited(String type, int id) async {
    try {
      if (kDebugMode) {
        print('🔍 FAVORITES SERVICE: Checking if item is favorited...');
        print('🔍 TYPE: $type, ID: $id');
      }

      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/favorites/check',
        data: {
          'type': type,
          'id': id,
        },
      );

      if (response.data['success'] == true) {
        final isFavorited = response.data['data']['is_favorited'] ?? false;
        if (kDebugMode) {
          print('✅ FAVORITES SERVICE: Favorite status checked');
          print('🔍 IS FAVORITED: $isFavorited');
        }
        return isFavorited;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to check favorite status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES SERVICE ERROR: $e');
      }
      return false; // Return false on error to avoid breaking UI
    }
  }

  /// Clear all favorites
  Future<int> clearAllFavorites() async {
    try {
      if (kDebugMode) {
        print('🗑️ FAVORITES SERVICE: Clearing all favorites...');
      }

      final response = await _apiClient.delete(
        '${ApiConstants.baseUrl}/customer/shopping/favorites',
      );

      if (response.data['success'] == true) {
        final deletedCount = response.data['data']['deleted_count'] ?? 0;
        if (kDebugMode) {
          print('✅ FAVORITES SERVICE: All favorites cleared');
          print('🗑️ DELETED COUNT: $deletedCount');
        }
        return deletedCount;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to clear favorites');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Convert API product data to FavoriteProductModel
  List<FavoriteProductModel> _parseProducts(List<dynamic> productsData) {
    return productsData.map((productData) {
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
  }

  /// Convert API merchant data to FavoriteStoreModel
  List<FavoriteStoreModel> _parseMerchants(List<dynamic> merchantsData) {
    return merchantsData.map((merchantData) {
      return FavoriteStoreModel.fromJson({
        'id': merchantData['id'],
        'name': merchantData['business_name'] ?? merchantData['name'],
        'image': merchantData['logo'] ?? '',
        'rating': merchantData['average_rating'] ?? 4.5,
        'backgroundImage': merchantData['cover_image'] ?? '',
      });
    }).toList();
  }

  /// Get favorite products
  Future<List<FavoriteProductModel>> getFavoriteProducts() async {
    final favorites = await getFavorites(type: 'products');
    return _parseProducts(favorites['products']);
  }

  /// Get favorite merchants
  Future<List<FavoriteStoreModel>> getFavoriteMerchants() async {
    final favorites = await getFavorites(type: 'merchants');
    return _parseMerchants(favorites['merchants']);
  }
}
