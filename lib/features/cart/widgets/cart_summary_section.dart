import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class CartSummarySection extends GetView<CartController> {
  const CartSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2), // Background color from Figma
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Promo code section - exactly as in Figma
              Container(
                width: 380,
                height: 52,
                padding: const EdgeInsets.only(left: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAE6), // Light yellow background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Promo code text
                    const Expanded(
                      child: Text(
                        'Promo Code',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF5E5E5E),
                        ),
                      ),
                    ),
                    
                    // Yellow circle with icon - positioned at the right edge
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor, // Yellow
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Icon(
                        Icons.local_offer_outlined,
                        color: Color(0xFF592E2C),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Order summary section
              Container(
                width: 380,
                child: Obx(() => Column(
                  children: [
                    // Subtotal
                    _buildSummaryRow(
                      'Subtotal',
                      '\$ ${controller.subtotal.toStringAsFixed(2)}',
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Delivery fee
                    _buildSummaryRow(
                      'Delivery fee',
                      '\$ ${controller.deliveryFee.toStringAsFixed(2)}',
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tax
                    _buildSummaryRow(
                      'Tax',
                      '\$ ${controller.taxAmount.toStringAsFixed(2)}',
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Divider
                    Container(
                      height: 1,
                      color: const Color(0xFFB0B0B0),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Total - with bold styling as per Figma
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF262626),
                            letterSpacing: -0.005,
                          ),
                        ),
                        Text(
                          '\$ ${controller.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF262626),
                            letterSpacing: -0.005,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
              ),
              
              const SizedBox(height: 16),
              
              // Checkout button - Yellow with brown text as per Figma
              Container(
                // width: 380,
                // height: 50,
                child: ElevatedButton(
                  onPressed: controller.proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor, // Yellow background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF592E2C), // Brown text
                      letterSpacing: -0.005,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF4B4B4B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF4B4B4B),
          ),
        ),
      ],
    );
  }
}
