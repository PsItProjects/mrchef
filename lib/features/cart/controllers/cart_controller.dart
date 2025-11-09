import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/features/cart/models/cart_item_model.dart';
import 'package:mrsheaf/features/cart/services/cart_service.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();

  // Observable cart items
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  // Individual item loading states
  final RxMap<int, bool> itemLoadingStates = <int, bool>{}.obs;

  // Cart summary
  final RxMap<String, dynamic> cartSummary = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  /// Load cart items from server
  Future<void> loadCartItems() async {
    try {
      isLoading.value = true;

      final cartData = await _cartService.getCartItems();
      cartItems.value = cartData['items'] as List<CartItemModel>;

      final summaryData = cartData['summary'] as Map<String, dynamic>;
      cartSummary.value = summaryData;

      // Debug logging
      if (kDebugMode) {
        print('🛒 CART CONTROLLER: Cart summary updated: $summaryData');
        print('🛒 CART CONTROLLER: Has formatted data: ${summaryData.containsKey('formatted')}');
        print('🛒 CART CONTROLLER: Has labels data: ${summaryData.containsKey('labels')}');
      }

    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل السلة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Add item to cart via server
  Future<void> addToCart({
    required ProductModel product,
    required String size,
    required int quantity,
    List<AdditionalOption> additionalOptions = const [],
    String? specialInstructions,
  }) async {
    try {
      isUpdating.value = true;

      // Extract selected option IDs
      final selectedOptionIds = additionalOptions
          .where((option) => option.isSelected)
          .map((option) => option.id)
          .toList();

      await _cartService.addToCart(
        productId: product.id,
        quantity: quantity,
        size: size.isNotEmpty ? size : null,
        selectedOptions: selectedOptionIds.isNotEmpty ? selectedOptionIds : null,
        specialInstructions: specialInstructions,
      );

      // Reload cart items to get updated data
      await loadCartItems();

      // Show success message
      Get.snackbar(
        'تم بنجاح',
        'تم إضافة ${product.name} إلى السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      // Check if it's an authentication error
      if (errorMessage.contains('يجب تسجيل الدخول')) {
        Get.snackbar(
          'تسجيل الدخول مطلوب',
          'يجب تسجيل الدخول أولاً لإضافة المنتجات للسلة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => Get.toNamed('/login'),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'خطأ',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isUpdating.value = false;
    }
  }

  /// Remove item from cart via server
  Future<void> removeFromCart(int cartItemId) async {
    try {
      // Set loading for this specific item only
      setItemLoading(cartItemId, true);

      await _cartService.removeCartItem(cartItemId);

      // Remove the item from local list immediately
      cartItems.removeWhere((item) => item.id == cartItemId);

      // Update cart summary
      await _updateCartSummaryOnly();

      Get.snackbar(
        'تم الحذف',
        'تم حذف العنصر من السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );

    } catch (e) {
      String errorMessage = e.toString();

      // Check if it's an authentication error
      if (errorMessage.contains('يجب تسجيل الدخول')) {
        Get.snackbar(
          'تسجيل الدخول مطلوب',
          'يجب تسجيل الدخول أولاً لحذف العناصر من السلة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => Get.toNamed('/login'),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في حذف العنصر: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      // Clear loading for this specific item
      setItemLoading(cartItemId, false);
    }
  }

  /// Update quantity of cart item via server
  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    try {
      // Set loading for this specific item only
      setItemLoading(cartItemId, true);

      final updatedItem = await _cartService.updateCartItem(
        cartItemId: cartItemId,
        quantity: newQuantity,
      );

      // Update the specific item in the list without full reload
      final itemIndex = cartItems.indexWhere((item) => item.id == cartItemId);
      if (itemIndex != -1) {
        cartItems[itemIndex] = updatedItem;
      }

      // Update cart summary by reloading (but without showing page loading)
      await _updateCartSummaryOnly();

    } catch (e) {
      String errorMessage = e.toString();

      // Check if it's an authentication error
      if (errorMessage.contains('يجب تسجيل الدخول')) {
        Get.snackbar(
          'تسجيل الدخول مطلوب',
          'يجب تسجيل الدخول أولاً لتحديث السلة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => Get.toNamed('/login'),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تحديث الكمية: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      // Clear loading for this specific item
      setItemLoading(cartItemId, false);
    }
  }

  /// Update cart summary without showing page loading
  Future<void> _updateCartSummaryOnly() async {
    try {
      final cartData = await _cartService.getCartItems();
      cartSummary.value = cartData['summary'] as Map<String, dynamic>;

      if (kDebugMode) {
        print('🛒 CART CONTROLLER: Summary updated silently');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CART CONTROLLER: Failed to update summary: $e');
      }
    }
  }

  /// Increase quantity
  Future<void> increaseQuantity(int cartItemId) async {
    final index = cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      final currentQuantity = cartItems[index].quantity;
      await updateQuantity(cartItemId, currentQuantity + 1);
    }
  }

  /// Decrease quantity
  Future<void> decreaseQuantity(int cartItemId) async {
    final index = cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      final currentQuantity = cartItems[index].quantity;
      await updateQuantity(cartItemId, currentQuantity - 1);
    }
  }

  /// Clear all items from cart via server
  Future<void> clearCart({bool showNotification = true}) async {
    try {
      isUpdating.value = true;

      await _cartService.clearCart();

      // Clear local data
      cartItems.clear();
      cartSummary.clear();

      // Only show notification if explicitly requested
      if (showNotification) {
        Get.snackbar(
          'تم المسح',
          'تم مسح جميع العناصر من السلة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      String errorMessage = e.toString();

      // Check if it's an authentication error
      if (errorMessage.contains('يجب تسجيل الدخول')) {
        Get.snackbar(
          'تسجيل الدخول مطلوب',
          'يجب تسجيل الدخول أولاً لمسح السلة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => Get.toNamed('/login'),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في مسح السلة: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isUpdating.value = false;
    }
  }



  // Get total items count from server data or local fallback
  int get totalItemsCount {
    if (cartSummary.isNotEmpty && cartSummary['total_items'] != null) {
      return cartSummary['total_items'] as int;
    }
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get subtotal from server data or local fallback
  double get subtotal {
    if (cartSummary.isNotEmpty && cartSummary['subtotal'] != null) {
      return (cartSummary['subtotal'] as num).toDouble();
    }
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get delivery fee from server data or fallback
  double get deliveryFee {
    if (cartSummary.isNotEmpty && cartSummary['delivery_fee'] != null) {
      return (cartSummary['delivery_fee'] as num).toDouble();
    }
    return 5.00; // Fallback
  }

  // Get service fee from server data or fallback
  double get serviceFee {
    if (cartSummary.isNotEmpty && cartSummary['service_fee'] != null) {
      return (cartSummary['service_fee'] as num).toDouble();
    }
    return 0.0; // Fallback
  }

  // Get tax amount (calculated as service fee for now)
  double get taxAmount => serviceFee;

  // Get total amount from server data or local calculation
  double get totalAmount {
    if (cartSummary.isNotEmpty && cartSummary['total'] != null) {
      return (cartSummary['total'] as num).toDouble();
    }
    return subtotal + deliveryFee + serviceFee;
  }

  // Individual item loading management
  bool isItemLoading(int cartItemId) {
    return itemLoadingStates[cartItemId] ?? false;
  }

  void setItemLoading(int cartItemId, bool loading) {
    itemLoadingStates[cartItemId] = loading;
  }

  // Navigate to home page
  void goToHomePage() {
    Get.offAllNamed(AppRoutes.HOME);
  }

  // Proceed to checkout - now initiates chat with restaurant
  Future<void> proceedToCheckout() async {
    if (cartItems.isEmpty) return;

    try {
      isUpdating.value = true;

      // Initiate order chat with restaurant
      final chatData = await _cartService.initiateOrderChat();

      // Get conversation ID and data
      final conversationId = chatData['conversation']['id'];

      // Clear cart silently after successful chat initiation
      await clearCart(showNotification: false);

      // Navigate to chat screen with conversation data
      // Navigation itself is sufficient feedback for the user
      Get.toNamed('/chat/$conversationId', arguments: chatData['conversation']);

    } catch (e) {
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
