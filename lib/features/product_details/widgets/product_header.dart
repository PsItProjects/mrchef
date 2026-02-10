import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class ProductHeader extends GetView<ProductDetailsController> {
  const ProductHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button - glassmorphism style
          _buildCircleButton(
            icon: Get.locale == const Locale('ar')
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_rounded,
            onTap: controller.goBack,
          ),

          // Favorite button
          Obx(() => _buildCircleButton(
            icon: controller.isFavorite.value
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            onTap: controller.toggleFavorite,
            iconColor: controller.isFavorite.value
                ? AppColors.errorColor
                : Colors.white,
          )),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
