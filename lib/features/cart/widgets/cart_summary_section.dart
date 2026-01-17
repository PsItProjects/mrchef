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
              // Promo code section
              Obx(() {
                final hasCoupon = controller.appliedCouponCode.isNotEmpty;
                final isBusy = controller.isCouponUpdating.value;

                return Container(
                  width: 380,
                  height: 52,
                  padding: const EdgeInsets.only(left: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAE6), // Light yellow background
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.promoCodeController,
                          enabled: !hasCoupon && !isBusy,
                          decoration: InputDecoration(
                            hintText: TranslationHelper.tr('promo_code'),
                            hintStyle: AppTheme.searchTextStyle,
                            border: InputBorder.none,
                          ),
                          style: AppTheme.searchTextStyle,
                        ),
                      ),

                      GestureDetector(
                        onTap: isBusy
                            ? null
                            : (hasCoupon
                                ? controller.removePromoCode
                                : controller.applyPromoCode),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: isBusy
                              ? const Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.searchIconColor,
                                    ),
                                  ),
                                )
                              : Icon(
                                  hasCoupon
                                      ? Icons.close
                                      : Icons.local_offer_outlined,
                                  color: AppColors.searchIconColor,
                                  size: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Order summary section
              Container(
                width: 380,
                child: Obx(() => Column(
                  children: [
                    // Subtotal - use backend data if available
                    _buildSummaryRow(
                      _getLabel('subtotal'),
                      _getFormattedPrice('subtotal'),
                    ),

                    const SizedBox(height: 8),

                    // Delivery fee - use backend data if available
                    _buildSummaryRow(
                      _getLabel('delivery_fee'),
                      _getFormattedPrice('delivery_fee'),
                    ),

                    const SizedBox(height: 8),

                    // Service fee - use backend data if available
                    _buildSummaryRow(
                      _getLabel('service_fee'),
                      _getFormattedPrice('service_fee'),
                    ),

                    if (controller.discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        _getLabel('discount_amount'),
                        '- ${_getFormattedPrice('discount_amount')}',
                      ),
                    ],

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
                          _getLabel('total'),
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF262626),
                            letterSpacing: -0.005,
                          ),
                        ),
                        Text(
                          _getFormattedPrice('total'),
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

  /// Get label from backend data or fallback to translation
  String _getLabel(String key) {
    if (controller.cartSummary.isNotEmpty &&
        controller.cartSummary['labels'] != null &&
        controller.cartSummary['labels'][key] != null) {
      return controller.cartSummary['labels'][key] as String;
    }

    // Fallback to local translations
    switch (key) {
      case 'subtotal':
        return TranslationHelper.tr('subtotal');
      case 'delivery_fee':
        return TranslationHelper.tr('delivery_fee');
      case 'service_fee':
        return TranslationHelper.tr('tax'); // Using tax as service fee
      case 'total':
        return TranslationHelper.tr('total');
      case 'discount_amount':
        return TranslationHelper.tr('discount_amount');
      default:
        return key;
    }
  }

  /// Get formatted price from backend data or fallback to local formatting
  String _getFormattedPrice(String key) {
    if (controller.cartSummary.isNotEmpty &&
        controller.cartSummary['formatted'] != null &&
        controller.cartSummary['formatted'][key] != null) {
      return controller.cartSummary['formatted'][key] as String;
    }

    // Fallback to local calculations and formatting
    switch (key) {
      case 'subtotal':
        return CurrencyHelper.formatPrice(controller.subtotal);
      case 'delivery_fee':
        return CurrencyHelper.formatPrice(controller.deliveryFee);
      case 'service_fee':
        return CurrencyHelper.formatPrice(controller.serviceFee);
      case 'total':
        return CurrencyHelper.formatPrice(controller.totalAmount);
      case 'discount_amount':
        return CurrencyHelper.formatPrice(controller.discountAmount);
      default:
        return '0.0 ر.س';
    }
  }
}
