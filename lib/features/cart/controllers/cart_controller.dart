import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/services/guest_service.dart';
import 'package:mrsheaf/features/cart/models/cart_item_model.dart';
import 'package:mrsheaf/features/cart/services/cart_service.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();

  // Promo code controller
  final TextEditingController promoCodeController = TextEditingController();
  final RxBool isCouponUpdating = false.obs;

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
    // Only load cart if not in guest mode
    if (!_isGuestMode) {
      loadCartItems();
    }
  }

  /// Check if user is in guest mode
  bool get _isGuestMode {
    try {
      final guestService = Get.find<GuestService>();
      return guestService.isGuestMode;
    } catch (e) {
      return false;
    }
  }

  /// Show guest mode modal and return true if user is guest
  bool _checkGuestAndShowModal({String? message}) {
    try {
      final guestService = Get.find<GuestService>();
      return guestService.checkGuestAndShowModal(
        message: message ?? 'guest_cart_message'.tr,
      );
    } catch (e) {
      return false;
    }
  }

  /// Load cart items from server
  Future<void> loadCartItems() async {
    if (_isGuestMode) {
      cartItems.clear();
      cartSummary.clear();
      return;
    }
    try {
      isLoading.value = true;

      final cartData = await _cartService.getCartItems();
      cartItems.value = cartData['items'] as List<CartItemModel>;

      final summaryData = cartData['summary'] as Map<String, dynamic>;
      cartSummary.value = summaryData;

      final appliedCode = (summaryData['coupon_code'] ?? '').toString();
      if (appliedCode.isNotEmpty) {
        promoCodeController.text = appliedCode;
      } else {
        promoCodeController.clear();
      }

      // Debug logging
      if (kDebugMode) {
        print('🛒 CART CONTROLLER: Cart summary updated: $summaryData');
        print('🛒 CART CONTROLLER: Has formatted data: ${summaryData.containsKey('formatted')}');
        print('🛒 CART CONTROLLER: Has labels data: ${summaryData.containsKey('labels')}');
      }

    } catch (e) {
      ToastService.showError('فشل في تحميل السلة: $e');
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
    // Check guest mode first
    if (_checkGuestAndShowModal()) {
      return;
    }
    
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

      // Reload cart items to get updated data with real product names
      await loadCartItems();

      // Get the actual product name from the cart items (last added item)
      String productName = product.name;
      if (cartItems.isNotEmpty) {
        // Find the product that was just added by matching ID
        final addedItem = cartItems.firstWhere(
          (item) => item.productId == product.id,
          orElse: () => cartItems.last,
        );
        productName = addedItem.name; // اسم المنتج الحقيقي من السلة
      }

      // Show success message with actual product name
      ToastService.showSuccess(
        'تمت إضافة "$productName" إلى السلة بنجاح',
      );

    } catch (e) {
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      // Check if it's an authentication error
      if (errorMessage.contains('يجب تسجيل الدخول')) {
        ToastService.showWarning('يجب تسجيل الدخول أولاً لإضافة المنتجات للسلة');
        Get.toNamed('/login');
      } else {
        ToastService.showError(errorMessage);
      }
    } finally {
      isUpdating.value = false;
    }
  }

  /// Remove item from cart via server
  Future<void> removeFromCart(int cartItemId) async {
    if (_checkGuestAndShowModal()) {
      return;
    }
    try {
      // Set loading for this specific item only
      setItemLoading(cartItemId, true);

      await _cartService.removeCartItem(cartItemId);

      // Remove the item from local list immediately
      cartItems.removeWhere((item) => item.id == cartItemId);

      // Update cart summary
      await _updateCartSummaryOnly();

      ToastService.showSuccess(TranslationHelper.tr('item_removed_from_cart'));

    } catch (e) {
      String errorMessage = e.toString();

      // Check if it's an authentication error
      if (errorMessage.contains('يجب تسجيل الدخول')) {
        ToastService.showWarning('يجب تسجيل الدخول أولاً لحذف العناصر من السلة');
        Get.toNamed('/login');
      } else {
        ToastService.showError('فشل في حذف العنصر: $e');
      }
    } finally {
      // Clear loading for this specific item
      setItemLoading(cartItemId, false);
    }
  }

  /// Update quantity of cart item via server
  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    if (_checkGuestAndShowModal()) {
      return;
    }
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
        ToastService.showWarning('يجب تسجيل الدخول أولاً لتحديث السلة');
        Get.toNamed('/login');
      } else {
        ToastService.showError('فشل في تحديث الكمية: $e');
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
      final summaryData = cartData['summary'] as Map<String, dynamic>;
      cartSummary.value = summaryData;

      final appliedCode = (summaryData['coupon_code'] ?? '').toString();
      if (appliedCode.isNotEmpty) {
        promoCodeController.text = appliedCode;
      }

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
    if (_checkGuestAndShowModal()) {
      return;
    }
    try {
      isUpdating.value = true;

      await _cartService.clearCart();

      // Clear local data
      cartItems.clear();
      cartSummary.clear();

      // Only show notification if explicitly requested
      if (showNotification) {
        ToastService.showSuccess('تم مسح جميع العناصر من السلة');
      }

    } catch (e) {
      String errorMessage = e.toString();

      // Check if it's an authentication error
      if (errorMessage.contains('يجب تسجيل الدخول')) {
        ToastService.showWarning('يجب تسجيل الدخول أولاً لمسح السلة');
        Get.toNamed('/login');
      } else {
        ToastService.showError('فشل في مسح السلة: $e');
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

  // Proceed to checkout - navigate to checkout screen
  void proceedToCheckout() {
    if (cartItems.isEmpty) return;
    if (_checkGuestAndShowModal(message: 'guest_checkout_message'.tr)) {
      return;
    }
    Get.toNamed(AppRoutes.CHECKOUT);
  }

  String get appliedCouponCode {
    return (cartSummary['coupon_code'] ?? '').toString();
  }

  double get discountAmount {
    if (cartSummary.isNotEmpty && cartSummary['discount_amount'] != null) {
      return (cartSummary['discount_amount'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> applyPromoCode() async {
    if (_checkGuestAndShowModal()) {
      return;
    }
    final code = promoCodeController.text.trim();
    if (code.isEmpty) {
      ToastService.showWarning(TranslationHelper.tr('please_enter_promo_code'));
      return;
    }

    try {
      isCouponUpdating.value = true;

      final result = await _cartService.applyCoupon(code);
      cartItems.value = result['items'] as List<CartItemModel>;
      cartSummary.value = result['summary'] as Map<String, dynamic>;
      promoCodeController.text = appliedCouponCode;

      final message = (result['message'] ?? TranslationHelper.tr('success')).toString();
      ToastService.showSuccess(message);
    } catch (e) {
      ToastService.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isCouponUpdating.value = false;
    }
  }

  Future<void> removePromoCode() async {
    if (_checkGuestAndShowModal()) {
      return;
    }
    try {
      isCouponUpdating.value = true;

      final result = await _cartService.removeCoupon();
      cartItems.value = result['items'] as List<CartItemModel>;
      cartSummary.value = result['summary'] as Map<String, dynamic>;
      promoCodeController.clear();

      final message = (result['message'] ?? TranslationHelper.tr('success')).toString();
      ToastService.showSuccess(message);
    } catch (e) {
      ToastService.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isCouponUpdating.value = false;
    }
  }

  @override
  void onClose() {
    promoCodeController.dispose();
    super.onClose();
  }
}
