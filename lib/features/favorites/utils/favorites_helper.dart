import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';

class FavoritesHelper {
  static FavoritesController? get _controller => _controllerSafe;

  /// Toggle product favorite status
  static Future<bool> toggleProductFavorite(int productId) async {
    try {
      final controller = _controller;
      if (controller == null) {
        ensureInitialized();
        return false;
      }

      if (kDebugMode) {
        print('🔄 FAVORITES HELPER: Toggling product $productId');
      }

      // Check current status from server first
      final isCurrentlyFavorite = await controller.checkProductFavoriteStatus(productId);

      if (kDebugMode) {
        print('🔍 FAVORITES HELPER: Current status for product $productId: ${isCurrentlyFavorite ? 'FAVORITED' : 'NOT FAVORITED'}');
      }

      if (isCurrentlyFavorite) {
        // Remove from favorites
        if (kDebugMode) {
          print('➖ FAVORITES HELPER: Removing product $productId from favorites');
        }
        await controller.removeProductFromFavorites(productId);
        return false; // Now not favorited
      } else {
        // Add to favorites
        if (kDebugMode) {
          print('➕ FAVORITES HELPER: Adding product $productId to favorites');
        }
        await controller.addProductToFavorites(productId);
        return true; // Now favorited
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES HELPER: Toggle product favorite error: $e');
      }
      return false;
    }
  }

  /// Toggle merchant favorite status
  static Future<void> toggleMerchantFavorite(int merchantId) async {
    try {
      final controller = _controller;
      if (controller == null) {
        ensureInitialized();
        return;
      }

      final isCurrentlyFavorite = controller.isStoreFavorite(merchantId);

      if (isCurrentlyFavorite) {
        await controller.removeStoreFromFavorites(merchantId);
      } else {
        await controller.addStoreToFavorites(merchantId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES HELPER: Toggle merchant favorite error: $e');
      }
    }
  }

  /// Check if product is favorite
  static bool isProductFavorite(int productId) {
    try {
      final controller = _controller;
      if (controller == null) return false;
      return controller.isProductFavorite(productId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES HELPER: Check product favorite error: $e');
      }
      return false;
    }
  }

  /// Check if merchant is favorite
  static bool isMerchantFavorite(int merchantId) {
    try {
      final controller = _controller;
      if (controller == null) return false;
      return controller.isStoreFavorite(merchantId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES HELPER: Check merchant favorite error: $e');
      }
      return false;
    }
  }

  /// Check product favorite status from server
  static Future<bool> checkProductFavoriteFromServer(int productId) async {
    try {
      final controller = _controller;
      if (controller == null) return false;
      return await controller.checkProductFavoriteStatus(productId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES HELPER: Check product favorite from server error: $e');
      }
      return false;
    }
  }

  /// Check merchant favorite status from server
  static Future<bool> checkMerchantFavoriteFromServer(int merchantId) async {
    try {
      final controller = _controller;
      if (controller == null) return false;
      return await controller.checkMerchantFavoriteStatus(merchantId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES HELPER: Check merchant favorite from server error: $e');
      }
      return false;
    }
  }

  /// Ensure favorites controller is initialized
  static void ensureInitialized() {
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController(), permanent: true);
    }
  }

  /// Get controller safely
  static FavoritesController? get _controllerSafe {
    try {
      if (Get.isRegistered<FavoritesController>()) {
        return Get.find<FavoritesController>();
      } else {
        ensureInitialized();
        return Get.find<FavoritesController>();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FAVORITES HELPER: Controller not found: $e');
      }
      return null;
    }
  }
}
