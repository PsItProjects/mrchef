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
          // ─── NAME + PRICE ROW ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Obx(() {
                final p = controller.product.value;
                if (p == null) return const SizedBox.shrink();
                final hasDiscount = p.hasDiscount && p.originalPrice != null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasDiscount) ...[
                      // Discount badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${p.discountPercentage > 0 ? p.discountPercentage.toStringAsFixed(0) : ((1 - p.price / p.originalPrice!) * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.red.shade600,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Original price
                      Text(
                        CurrencyHelper.formatPrice(p.originalPrice!),
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red.shade300,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    // Effective price
                    Text(
                      CurrencyHelper.formatPrice(p.price),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: hasDiscount ? Colors.green.shade700 : AppColors.primaryColor,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          // ─── RATING + STORE ROW ────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: controller.hasReviews ? controller.showReviews : null,
                child: Obx(() {
                  final hasReviews = controller.hasReviews;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasReviews ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasReviews ? Icons.star_rounded : Icons.fiber_new_rounded,
                          color: hasReviews ? const Color(0xFFFFB800) : const Color(0xFF43A047),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.formattedRating,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: hasReviews ? const Color(0xFF1A1A2E) : const Color(0xFF43A047),
                          ),
                        ),
                        if (controller.formattedReviewCount.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            controller.formattedReviewCount,
                            style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(width: 10),
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
                      Icon(Icons.storefront_rounded, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'go_to_store'.tr,
                        style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Get.locale == const Locale('ar') ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
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

          // ─── QUICK INFO CHIPS (calories, prep time, dietary) ───
          Obx(() {
            final p = controller.product.value;
            if (p == null) return const SizedBox.shrink();

            final List<Widget> chips = [];

            // Preparation time
            if (p.preparationTime > 0) {
              chips.add(_InfoChip(
                icon: Icons.timer_rounded,
                label: '${p.preparationTime} ${'min'.tr}',
                bgColor: Colors.blue.shade50,
                iconColor: Colors.blue.shade600,
              ));
            }

            // Calories
            if (p.calories != null && p.calories! > 0) {
              chips.add(_InfoChip(
                icon: Icons.local_fire_department_rounded,
                label: '${p.calories} ${'kcal'.tr}',
                bgColor: Colors.orange.shade50,
                iconColor: Colors.deepOrange,
              ));
            }

            // Dietary badges
            if (p.isVegetarian) {
              chips.add(_InfoChip(
                icon: Icons.eco_rounded,
                label: 'vegetarian'.tr,
                bgColor: Colors.green.shade50,
                iconColor: Colors.green.shade700,
              ));
            }
            if (p.isVegan) {
              chips.add(_InfoChip(
                icon: Icons.spa_rounded,
                label: 'vegan'.tr,
                bgColor: Colors.teal.shade50,
                iconColor: Colors.teal,
              ));
            }
            if (p.isGlutenFree) {
              chips.add(_InfoChip(
                icon: Icons.grain_rounded,
                label: 'gluten_free'.tr,
                bgColor: Colors.brown.shade50,
                iconColor: Colors.brown,
              ));
            }
            if (p.isSpicy) {
              chips.add(_InfoChip(
                icon: Icons.local_fire_department_rounded,
                label: 'spicy'.tr,
                bgColor: Colors.red.shade50,
                iconColor: Colors.red,
              ));
            }

            // Food nationality
            if (p.foodNationalityName != null && p.foodNationalityName!.isNotEmpty) {
              chips.add(_InfoChip(
                icon: Icons.public_rounded,
                label: p.foodNationalityName!,
                bgColor: Colors.purple.shade50,
                iconColor: Colors.purple.shade600,
              ));
            }

            // Governorate
            if (p.governorateName != null && p.governorateName!.isNotEmpty) {
              chips.add(_InfoChip(
                icon: Icons.location_city_rounded,
                label: p.governorateName!,
                bgColor: Colors.indigo.shade50,
                iconColor: Colors.indigo.shade600,
              ));
            }

            if (chips.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(spacing: 8, runSpacing: 8, children: chips),
            );
          }),

          // ─── DESCRIPTION ───────────────────────────
          Obx(() {
            final description = controller.product.value?.description ?? '';
            if (description.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.subject_rounded, size: 18, color: AppColors.secondaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'product_description'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF4A4A5A),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ─── INGREDIENTS ───────────────────────────
          Obx(() {
            final p = controller.product.value;
            if (p == null || p.ingredients.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.list_alt_rounded, size: 18, color: AppColors.secondaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'ingredients'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.ingredients.map((ingredient) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          ingredient,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A4A5A),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // ─── PRODUCT CODE ──────────────────────────
          Obx(() {
            final code = controller.product.value?.productCode;
            if (code == null || code == 'N/A' || code.isEmpty) return const SizedBox.shrink();
            return Text(
              '${'product_code'.tr}: $code',
              style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w400, fontSize: 11, color: Colors.grey[400]),
            );
          }),
        ],
      ),
    );
  }
}

// ─── REUSABLE INFO CHIP ────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: iconColor,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }
}
