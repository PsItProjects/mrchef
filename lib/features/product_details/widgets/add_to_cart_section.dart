import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class AddToCartSection extends GetView<ProductDetailsController> {
  const AddToCartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Divider line
              Container(
                height: 1,
                color: const Color(0xFFE3E3E3),
                margin: const EdgeInsets.only(bottom: 8),
              ),

              // Price section with toppings
              Obx(() => _buildPriceSection()),

              const SizedBox(height: 12),

              // Two buttons: Store name and Add to Cart
              Row(
                children: [
                  // Store name button
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.goToStore,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'go_to_store'.tr,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF592E2C),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Add to Cart button
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.addToCart,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'add_to_cart'.tr,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF592E2C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    if (controller.product.value == null) {
      return const SizedBox.shrink();
    }

    // Remove unused variable

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main price label - simplified like the design
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'meal_price_with_toppings'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF000000),
                ),
              ),
              Obx(() => controller.isCalculatingPrice.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  )
                : Text(
                    '${controller.totalPrice.toStringAsFixed(1)} ${'currency'.tr}',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Color(0xFFEB5757),
                    ),
                  ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Selected size clarification line
          Obx(() {
            final hasSize = controller.selectedSizeDetail.isNotEmpty;
            if (!hasSize && (controller.selectedSize.value.isEmpty)) {
              return const SizedBox.shrink();
            }

            final sizeName = controller.selectedSizeDetail['name']?.toString()
                ?? controller.selectedSize.value;
            final totalSizePrice = (controller.selectedSizeDetail['total_price'] is num)
                ? (controller.selectedSizeDetail['total_price'] as num).toDouble()
                : 0.0;
            final priceText = totalSizePrice > 0
                ? '+${totalSizePrice.toStringAsFixed(1)} ${'currency'.tr}'
                : '0 ${'currency'.tr}';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'selected_size_label'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                Flexible(
                  child: Text(
                    '$sizeName  •  $priceText',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF262626),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }


}
