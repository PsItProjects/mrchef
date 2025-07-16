import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/cart/widgets/cart_item_widget.dart';

class CartItemsList extends GetView<CartController> {
  const CartItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: controller.cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = controller.cartItems[index];
          return CartItemWidget(
            cartItem: cartItem,
            onQuantityChanged: (newQuantity) {
              controller.updateQuantity(cartItem.id, newQuantity);
            },
            onRemove: () {
              controller.removeFromCart(cartItem.id);
            },
          );
        },
      )),
    );
  }
}
