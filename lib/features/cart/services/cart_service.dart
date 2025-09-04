import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/cart/models/cart_item_model.dart';

class CartService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Check if user is authenticated
  Future<bool> _isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE: Error checking authentication: $e');
      }
      return false;
    }
  }

  /// Get all cart items from server
  Future<Map<String, dynamic>> getCartItems() async {
    try {
      if (kDebugMode) {
        print('🛒 CART SERVICE: Getting cart items from server...');
      }

      // Check if user is authenticated first
      final isAuth = await _isAuthenticated();
      if (!isAuth) {
        if (kDebugMode) {
          print('🔒 CART SERVICE: User not authenticated, returning empty cart');
        }
        return {
          'items': <CartItemModel>[],
          'summary': {
            'total_items': 0,
            'subtotal': 0.0,
            'delivery_fee': 0.0,
            'service_fee': 0.0,
            'total': 0.0,
          }
        };
      }

      final response = await _apiClient.get('/customer/shopping/cart');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        if (kDebugMode) {
          print('🛒 CART SERVICE: Cart items retrieved successfully');
          print('🛒 CART ITEMS COUNT: ${data['items']?.length ?? 0}');
        }

        // Extract summary data from the correct location
        final summary = data['summary'] as Map<String, dynamic>? ?? {};

        if (kDebugMode) {
          print('🛒 CART SERVICE: Summary data received: $summary');
          print('🛒 CART SERVICE: Summary has formatted: ${summary.containsKey('formatted')}');
          print('🛒 CART SERVICE: Summary has labels: ${summary.containsKey('labels')}');
        }

        return {
          'items': (data['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ?? [],
          'summary': summary.isNotEmpty ? summary : {
            'total_items': 0,
            'subtotal': 0.0,
            'delivery_fee': 0.0,
            'service_fee': 0.0,
            'total': 0.0,
          }
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get cart items');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
      }
      
      if (e.response?.statusCode == 401) {
        // User not authenticated - return empty cart instead of throwing error
        if (kDebugMode) {
          print('🔒 CART SERVICE: User not authenticated, returning empty cart');
        }
        return {
          'items': <CartItemModel>[],
          'summary': {
            'total_items': 0,
            'subtotal': 0.0,
            'delivery_fee': 0.0,
            'service_fee': 0.0,
            'total': 0.0,
          }
        };
      } else if (e.response?.statusCode == 404) {
        // Cart is empty or not found
        return {
          'items': <CartItemModel>[],
          'summary': {
            'total_items': 0,
            'subtotal': 0.0,
            'delivery_fee': 0.0,
            'service_fee': 0.0,
            'total': 0.0,
          }
        };
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: $e');
      }
      throw Exception('Failed to get cart items: $e');
    }
  }

  /// Add item to cart
  Future<CartItemModel> addToCart({
    required int productId,
    required int quantity,
    String? size,
    List<int>? selectedOptions,
    String? specialInstructions,
  }) async {
    try {
      if (kDebugMode) {
        print('🛒 CART SERVICE: Adding item to cart...');
        print('🛒 PRODUCT ID: $productId');
        print('🛒 QUANTITY: $quantity');
        print('🛒 SIZE: $size');
        print('🛒 SELECTED OPTIONS: $selectedOptions');
        print('🛒 SPECIAL INSTRUCTIONS: $specialInstructions');
      }

      // Check if user is authenticated first
      final isAuth = await _isAuthenticated();
      if (!isAuth) {
        if (kDebugMode) {
          print('🔒 CART SERVICE: User not authenticated, cannot add to cart');
        }
        throw Exception('يجب تسجيل الدخول أولاً لإضافة المنتجات للسلة');
      }

      final response = await _apiClient.post(
        '/customer/shopping/cart/add',
        data: {
          'product_id': productId,
          'quantity': quantity,
          if (size != null) 'size': size,
          if (selectedOptions != null && selectedOptions.isNotEmpty) 
            'selected_options': selectedOptions,
          if (specialInstructions != null && specialInstructions.isNotEmpty)
            'special_instructions': specialInstructions,
        },
      );

      if (response.data['success'] == true) {
        final cartItemData = response.data['data'];
        
        if (kDebugMode) {
          print('✅ CART SERVICE: Item added successfully');
        }

        return CartItemModel.fromJson(cartItemData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add item to cart');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
        print('❌ RESPONSE DATA: ${e.response?.data}');
      }
      
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Product is not available';
        throw Exception(message);
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          final firstError = errors.values.first;
          throw Exception(firstError is List ? firstError.first : firstError);
        }
        throw Exception('Invalid data provided');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: $e');
      }
      throw Exception('Failed to add item to cart: $e');
    }
  }

  /// Update cart item quantity
  Future<CartItemModel> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      if (kDebugMode) {
        print('🛒 CART SERVICE: Updating cart item...');
        print('🛒 CART ITEM ID: $cartItemId');
        print('🛒 NEW QUANTITY: $quantity');
      }

      // Check if user is authenticated first
      final isAuth = await _isAuthenticated();
      if (!isAuth) {
        if (kDebugMode) {
          print('🔒 CART SERVICE: User not authenticated, cannot update cart');
        }
        throw Exception('يجب تسجيل الدخول أولاً لتحديث السلة');
      }

      final response = await _apiClient.put(
        '/customer/shopping/cart/$cartItemId',
        data: {
          'quantity': quantity,
        },
      );

      if (response.data['success'] == true) {
        final cartItemData = response.data['data'];
        
        if (kDebugMode) {
          print('✅ CART SERVICE: Item updated successfully');
        }

        return CartItemModel.fromJson(cartItemData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update cart item');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
      }
      
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Cart item not found');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          final firstError = errors.values.first;
          throw Exception(firstError is List ? firstError.first : firstError);
        }
        throw Exception('Invalid quantity provided');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: $e');
      }
      throw Exception('Failed to update cart item: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeCartItem(int cartItemId) async {
    try {
      if (kDebugMode) {
        print('🛒 CART SERVICE: Removing cart item...');
        print('🛒 CART ITEM ID: $cartItemId');
      }

      // Check if user is authenticated first
      final isAuth = await _isAuthenticated();
      if (!isAuth) {
        if (kDebugMode) {
          print('🔒 CART SERVICE: User not authenticated, cannot remove from cart');
        }
        throw Exception('يجب تسجيل الدخول أولاً لحذف العناصر من السلة');
      }

      final response = await _apiClient.delete('/customer/shopping/cart/$cartItemId');

      if (response.data['success'] == true) {
        if (kDebugMode) {
          print('✅ CART SERVICE: Item removed successfully');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to remove cart item');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
      }
      
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Cart item not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: $e');
      }
      throw Exception('Failed to remove cart item: $e');
    }
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    try {
      if (kDebugMode) {
        print('🛒 CART SERVICE: Clearing cart...');
      }

      // Check if user is authenticated first
      final isAuth = await _isAuthenticated();
      if (!isAuth) {
        if (kDebugMode) {
          print('🔒 CART SERVICE: User not authenticated, cannot clear cart');
        }
        throw Exception('يجب تسجيل الدخول أولاً لمسح السلة');
      }

      final response = await _apiClient.delete('/customer/shopping/cart');

      if (response.data['success'] == true) {
        if (kDebugMode) {
          print('✅ CART SERVICE: Cart cleared successfully');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to clear cart');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
      }
      
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CART SERVICE ERROR: $e');
      }
      throw Exception('Failed to clear cart: $e');
    }
  }
}
