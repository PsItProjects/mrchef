import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class ProductHeader extends GetView<ProductDetailsController> {
  const ProductHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE167), // Yellow background from Figma
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow_left_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF262626), // Dark color for yellow background
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          
          // Favorite button
          GestureDetector(
            onTap: controller.toggleFavorite,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE167), // Yellow background from Figma
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Obx(() => SvgPicture.asset(
                  'assets/icons/heart_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.isFavorite.value
                      ? const Color(0xFFEB5757) // Red for favorited
                      : const Color(0xFF262626), // Dark for unfavorited
                    BlendMode.srcIn,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
