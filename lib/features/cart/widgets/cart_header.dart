import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (chat icon as per Figma)
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 24,
              height: 24,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: const Color(0xFF262626),
              ),
            ),
          ),
          
          // Title
          Text(
            'cart'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),
          
          // Delete/Clear cart button
          GestureDetector(
            onTap: () {
              // Show confirmation dialog
              _showClearCartDialog();
            },
            child: Container(
              width: 24,
              height: 24,
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: const Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Clear Cart',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF5E5E5E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              final cartController = Get.find<CartController>();
              cartController.clearCart();
              Get.snackbar(
                'Cart Cleared',
                'All items have been removed from your cart',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFFFF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
