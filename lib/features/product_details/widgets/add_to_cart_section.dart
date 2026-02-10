import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';

class AddToCartSection extends GetView<ProductDetailsController> {
  const AddToCartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFF5F5F5), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              // Quantity selector — pill style
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minus button
                    _buildQuantityButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.decreaseQuantity();
                      },
                    ),
                    // Quantity display
                    Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: SizedBox(
                        key: ValueKey<int>(controller.quantity.value),
                        width: 32,
                        child: Text(
                          controller.quantity.value.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    )),
                    // Plus button
                    _buildQuantityButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.increaseQuantity();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Add to Cart button with price
              Expanded(
                child: Obx(() => GestureDetector(
                  onTap: controller.isAddingToCart.value
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          controller.addToCart();
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: controller.isAddingToCart.value
                          ? null
                          : const LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                Color(0xFFFFD83D),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      color: controller.isAddingToCart.value
                          ? AppColors.primaryColor.withAlpha(150)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: controller.isAddingToCart.value
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.primaryColor.withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: controller.isAddingToCart.value
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF1A1A2E)),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: Color(0xFF1A1A2E),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'add_to_cart'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              // Vertical separator
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                width: 1,
                                height: 20,
                                color: const Color(0xFF1A1A2E).withAlpha(50),
                              ),
                              // Price
                              Obx(() => controller.isCalculatingPrice.value
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFF1A1A2E)),
                                      ),
                                    )
                                  : Text(
                                      CurrencyHelper.formatPrice(
                                          controller.totalPrice),
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    )),
                            ],
                          ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1A1A2E),
          size: 20,
        ),
      ),
    );
  }
}
