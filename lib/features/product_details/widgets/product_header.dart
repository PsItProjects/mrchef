import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/widgets/circular_icon_button.dart';
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
          CircularIconButton(
            iconPath: 'assets/icons/arrow_left_icon.svg',
            onTap: controller.goBack,
            backgroundColor: AppColors.favoriteButtonColor,
            iconColor: AppColors.darkTextColor,
          ),

          // Favorite button
          Obx(() => CircularIconButton(
            iconPath: 'assets/icons/heart_icon.svg',
            onTap: controller.toggleFavorite,
            backgroundColor: AppColors.favoriteButtonColor,
            iconColor: controller.isFavorite.value
                ? AppColors.errorColor
                : AppColors.darkTextColor,
          )),
        ],
      ),
    );
  }
}
