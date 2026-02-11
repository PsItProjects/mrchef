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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Promo code section
              Obx(() {
                final hasCoupon = controller.appliedCouponCode.isNotEmpty;
                final isBusy = controller.isCouponUpdating.value;

                return Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFE88D), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_offer_rounded,
                        size: 18,
                        color: hasCoupon
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFBBA850),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controller.promoCodeController,
                          enabled: !hasCoupon && !isBusy,
                          decoration: InputDecoration(
                            hintText: TranslationHelper.tr('promo_code'),
                            hintStyle: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xFFBBA850),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: isBusy
                            ? null
                            : (hasCoupon
                                ? controller.removePromoCode
                                : controller.applyPromoCode),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: hasCoupon
                                ? const Color(0xFFE53935)
                                : AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isBusy
                              ? const Padding(
                                  padding: EdgeInsets.all(11.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                )
                              : Icon(
                                  hasCoupon
                                      ? Icons.close_rounded
                                      : Icons.arrow_forward_rounded,
                                  color: hasCoupon
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Order summary section
              Obx(() => Column(
                children: [
                  _buildSummaryRow(
                    _getLabel('subtotal'),
                    _getFormattedPrice('subtotal'),
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    _getLabel('delivery_fee'),
                    _getFormattedPrice('delivery_fee'),
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    _getLabel('service_fee'),
                    _getFormattedPrice('service_fee'),
                  ),
                  if (controller.discountAmount > 0) ...[
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      _getLabel('discount_amount'),
                      '- ${_getFormattedPrice('discount_amount')}',
                      isDiscount: true,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getLabel('total'),
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        _getFormattedPrice('total'),
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              )),

              const SizedBox(height: 18),

              // Checkout button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: const Color(0xFF1A1A2E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    TranslationHelper.tr('checkout'),
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF1A1A2E),
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

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF6B6B80),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isDiscount ? const Color(0xFF4CAF50) : const Color(0xFF1A1A2E),
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

    switch (key) {
      case 'subtotal':
        return TranslationHelper.tr('subtotal');
      case 'delivery_fee':
        return TranslationHelper.tr('delivery_fee');
      case 'service_fee':
        return TranslationHelper.tr('tax');
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
