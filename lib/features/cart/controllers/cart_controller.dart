import 'package:get/get.dart';
import 'package:mrsheaf/features/cart/models/cart_item_model.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

class CartController extends GetxController {
  // Observable cart items
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  // Cart item counter for unique IDs
  int _cartItemIdCounter = 1;

  @override
  void onInit() {
    super.onInit();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Add some sample cart items for testing
    cartItems.addAll([
      CartItemModel(
        id: _cartItemIdCounter++,
        productId: 1,
        name: 'Caesar salad',
        description: 'Fresh romaine lettuce with caesar dressing',
        price: 25.00,
        image: 'assets/images/pizza_main.png',
        size: 'M',
        quantity: 1,
        additionalOptions: [],
      ),
      CartItemModel(
        id: _cartItemIdCounter++,
        productId: 2,
        name: 'Caesar salad',
        description: 'Fresh romaine lettuce with caesar dressing',
        price: 25.00,
        image: 'assets/images/pizza_main.png',
        size: 'L',
        quantity: 1,
        additionalOptions: [],
      ),
      CartItemModel(
        id: _cartItemIdCounter++,
        productId: 3,
        name: 'Caesar salad',
        description: 'Fresh romaine lettuce with caesar dressing',
        price: 25.00,
        image: 'assets/images/pizza_main.png',
        size: 'S',
        quantity: 1,
        additionalOptions: [],
      ),
    ]);
  }

  // Add item to cart
  void addToCart({
    required ProductModel product,
    required String size,
    required int quantity,
    List<AdditionalOption> additionalOptions = const [],
  }) {
    // Check if item with same product, size, and options already exists
    final existingItemIndex = cartItems.indexWhere((item) => 
      item.productId == product.id &&
      item.size == size &&
      _areAdditionalOptionsEqual(item.additionalOptions, additionalOptions)
    );

    if (existingItemIndex != -1) {
      // Update quantity of existing item
      final existingItem = cartItems[existingItemIndex];
      cartItems[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item to cart
      final cartItem = CartItemModel(
        id: _cartItemIdCounter++,
        productId: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        image: product.image,
        size: size,
        quantity: quantity,
        additionalOptions: additionalOptions.map((option) => 
          CartAdditionalOption(
            id: option.id,
            name: option.name,
            price: option.price ?? 0.0,
            isSelected: option.isSelected,
          )
        ).toList(),
      );
      
      cartItems.add(cartItem);
    }

    Get.snackbar(
      'Added to Cart',
      '${product.name} (${size}) x${quantity} added to cart',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Remove item from cart
  void removeFromCart(int cartItemId) {
    cartItems.removeWhere((item) => item.id == cartItemId);
  }

  // Update item quantity
  void updateQuantity(int cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }

    final index = cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
    }
  }

  // Increase quantity
  void increaseQuantity(int cartItemId) {
    final index = cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      final currentQuantity = cartItems[index].quantity;
      updateQuantity(cartItemId, currentQuantity + 1);
    }
  }

  // Decrease quantity
  void decreaseQuantity(int cartItemId) {
    final index = cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      final currentQuantity = cartItems[index].quantity;
      updateQuantity(cartItemId, currentQuantity - 1);
    }
  }

  // Clear all items from cart
  void clearCart() {
    cartItems.clear();
  }

  // Add sample data for testing
  void addSampleData() {
    cartItems.addAll([
      CartItemModel(
        id: _cartItemIdCounter++,
        productId: 1,
        name: 'Caesar salad',
        description: 'Fresh romaine lettuce with caesar dressing',
        price: 25.00,
        image: 'assets/images/pizza_main.png',
        size: 'M',
        quantity: 1,
        additionalOptions: [],
      ),
      CartItemModel(
        id: _cartItemIdCounter++,
        productId: 2,
        name: 'Caesar salad',
        description: 'Fresh romaine lettuce with caesar dressing',
        price: 25.00,
        image: 'assets/images/pizza_main.png',
        size: 'L',
        quantity: 1,
        additionalOptions: [],
      ),
      CartItemModel(
        id: _cartItemIdCounter++,
        productId: 3,
        name: 'Caesar salad',
        description: 'Fresh romaine lettuce with caesar dressing',
        price: 25.00,
        image: 'assets/images/pizza_main.png',
        size: 'S',
        quantity: 1,
        additionalOptions: [],
      ),
    ]);
  }

  // Get total items count
  int get totalItemsCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get subtotal (before tax and delivery)
  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get delivery fee (fixed for now)
  double get deliveryFee => 5.00;

  // Get tax amount (10% of subtotal)
  double get taxAmount => subtotal * 0.10;

  // Get total amount
  double get totalAmount => subtotal + deliveryFee + taxAmount;

  // Navigate to home page
  void goToHomePage() {
    Get.offAllNamed(AppRoutes.HOME);
  }

  // Proceed to checkout
  void proceedToCheckout() {
    if (cartItems.isEmpty) return;
    
    Get.snackbar(
      'Checkout',
      'Proceeding to checkout with ${totalItemsCount} items',
      snackPosition: SnackPosition.BOTTOM,
    );
    
    // TODO: Navigate to checkout screen when implemented
  }

  // Helper method to compare additional options
  bool _areAdditionalOptionsEqual(
    List<CartAdditionalOption> cartOptions,
    List<AdditionalOption> productOptions,
  ) {
    if (cartOptions.length != productOptions.length) return false;
    
    for (int i = 0; i < cartOptions.length; i++) {
      final cartOption = cartOptions[i];
      final productOption = productOptions[i];
      
      if (cartOption.id != productOption.id ||
          cartOption.isSelected != productOption.isSelected) {
        return false;
      }
    }
    
    return true;
  }
}
