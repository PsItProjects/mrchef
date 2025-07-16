import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';

class FavoritesTabs extends GetView<FavoritesController> {
  const FavoritesTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stores tab
          Obx(() => GestureDetector(
            onTap: () => controller.switchTab(0),
            child: Column(
              children: [
                Container(
                  width: 190,
                  child: Text(
                    'Stores',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: controller.isStoresTabSelected 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                      fontSize: 16,
                      color: controller.isStoresTabSelected 
                          ? AppColors.primaryColor 
                          : const Color(0xFF999999),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isStoresTabSelected 
                        ? AppColors.primaryColor 
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          )),
          
          // Products tab
          Obx(() => GestureDetector(
            onTap: () => controller.switchTab(1),
            child: Column(
              children: [
                Container(
                  width: 190,
                  child: Text(
                    'Product',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: controller.isProductsTabSelected 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                      fontSize: 16,
                      color: controller.isProductsTabSelected 
                          ? AppColors.primaryColor 
                          : const Color(0xFF999999),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isProductsTabSelected 
                        ? AppColors.primaryColor 
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
