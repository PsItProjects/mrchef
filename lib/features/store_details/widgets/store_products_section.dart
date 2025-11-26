import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';
import 'package:mrsheaf/features/home/widgets/product_card.dart';

class StoreProductsSection extends GetView<StoreDetailsController> {
  const StoreProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE3E3E3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'all_product'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: 1.5,
                    color: Color(0xFF262626),
                  ),
                ),

                // Rating section - HIDDEN as per user request
                // Container(
                //   // width: 54,
                //   // height: 26,
                //   child: Row(
                //     children: [
                //       SvgPicture.asset(
                //         'assets/icons/star_icon.svg',
                //         width: 24,
                //         height: 24,
                //         colorFilter: const ColorFilter.mode(
                //           Color(0xFFFACD02),
                //           BlendMode.srcIn,
                //         ),
                //       ),
                //       const SizedBox(width: 4),
                //       Obx(() => Text(
                //         controller.storeRating.value.toString(),
                //         style: const TextStyle(
                //           fontFamily: 'Lato',
                //           fontWeight: FontWeight.w700,
                //           fontSize: 18,
                //           letterSpacing: -0.09,
                //           color: Color(0xFF262626),
                //         ),
                //       )),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          
          // Products grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 182 / 248, // Width / Height from Figma
              ),
              itemCount: controller.storeProducts.length,
              itemBuilder: (context, index) {
                final product = controller.storeProducts[index];

                return ProductCard(
                  product: product,
                  section: 'store',
                );
              },
            )),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
