import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';

class ProductInfoSection extends GetView<ProductDetailsController> {
  const ProductInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name + price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name
              Expanded(
                child: Obx(() => Text(
                  controller.product.value?.name ?? 'Loading...',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                )),
              ),
              const SizedBox(width: 12),
              // Price
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (controller.product.value?.originalPrice != null) ...[
                    Text(
                      CurrencyHelper.formatPrice(controller.product.value!.originalPrice!),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Color(0xFFAAAAAA),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Color(0xFFEB5757),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    CurrencyHelper.formatPrice(controller.product.value?.price ?? 0),
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              )),
            ],
          ),

          const SizedBox(height: 12),

          // Rating + Reviews + Go to store row
          Row(
            children: [
              // Rating chip — shows "New" when no reviews
              GestureDetector(
                onTap: controller.hasReviews ? controller.showReviews : null,
                child: Obx(() {
                  final hasReviews = controller.hasReviews;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasReviews
                          ? const Color(0xFFFFF8E1)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasReviews
                              ? Icons.star_rounded
                              : Icons.fiber_new_rounded,
                          color: hasReviews
                              ? const Color(0xFFFFB800)
                              : const Color(0xFF43A047),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.formattedRating,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: hasReviews
                                ? const Color(0xFF1A1A2E)
                                : const Color(0xFF43A047),
                          ),
                        ),
                        if (controller.formattedReviewCount.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            controller.formattedReviewCount,
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(width: 10),

              // Go to store chip
              GestureDetector(
                onTap: controller.goToStore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'go_to_store'.tr,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Get.locale == const Locale('ar')
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          Obx(() {
            final description = controller.product.value?.description ?? '';
            if (description.isEmpty) return const SizedBox.shrink();
            return Text(
              description,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF6B6B80),
                height: 1.6,
              ),
            );
          }),

          const SizedBox(height: 8),

          // Product code - subtle
          Obx(() {
            final code = controller.product.value?.productCode;
            if (code == null || code == 'N/A' || code.isEmpty) {
              return const SizedBox.shrink();
            }
            return Text(
              '${'product_code'.tr}: $code',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 11,
                color: Colors.grey[400],
              ),
            );
          }),
        ],
      ),
    );
  }
}
