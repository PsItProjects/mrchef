import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';
import 'package:mrsheaf/features/home/widgets/product_card.dart';

class StoreProductsSection extends GetView<StoreDetailsController> {
  const StoreProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey.shade200, height: 1),

          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Row(
              children: [
                Text(
                  'all_product'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppColors.textDarkColor,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => Text(
                  '(${controller.storeProducts.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                )),
              ],
            ),
          ),

          // Products grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() {
              if (controller.storeProducts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'no_products'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: controller.storeProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.storeProducts[index];
                  return ProductCard(
                    product: product,
                    section: 'store',
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
