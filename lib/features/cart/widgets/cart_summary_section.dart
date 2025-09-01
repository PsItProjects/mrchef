import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';

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
                    Expanded(
                      child: Text(
                        TranslationHelper.tr('promo_code'),
                        style: AppTheme.searchTextStyle,
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
                        color: AppColors.searchIconColor,
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
                      TranslationHelper.tr('subtotal'),
                      CurrencyHelper.formatPrice(controller.subtotal),
                    ),

                    const SizedBox(height: 8),

                    // Delivery fee
                    _buildSummaryRow(
                      TranslationHelper.tr('delivery_fee'),
                      CurrencyHelper.formatPrice(controller.deliveryFee),
                    ),

                    const SizedBox(height: 8),

                    // Tax
                    _buildSummaryRow(
                      TranslationHelper.tr('tax'),
                      CurrencyHelper.formatPrice(controller.taxAmount),
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
                        Text(
                          TranslationHelper.tr('total'),
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF262626),
                            letterSpacing: -0.005,
                          ),
                        ),
                        Text(
                          CurrencyHelper.formatPrice(controller.totalAmount),
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
              
              // Checkout button
              Container(
                child: ElevatedButton(
                  onPressed: controller.proceedToCheckout,
                  style: AppTheme.primaryButtonStyle,
                  child: Text(
                    TranslationHelper.tr('checkout'),
                    style: AppTheme.buttonTextStyle.copyWith(
                      color: AppColors.searchIconColor,
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
