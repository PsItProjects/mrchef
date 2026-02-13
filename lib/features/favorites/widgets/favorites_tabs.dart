import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';

class FavoritesTabs extends GetView<FavoritesController> {
  const FavoritesTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Stores tab
          Expanded(
            child: Obx(() => GestureDetector(
                  onTap: () => controller.switchTab(0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: controller.isStoresTabSelected
                              ? AppColors.textDarkColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'restaurants'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: controller.isStoresTabSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: controller.isStoresTabSelected
                            ? AppColors.textDarkColor
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                )),
          ),

          // Products tab
          Expanded(
            child: Obx(() => GestureDetector(
                  onTap: () => controller.switchTab(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: controller.isProductsTabSelected
                              ? AppColors.textDarkColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'products'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: controller.isProductsTabSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: controller.isProductsTabSelected
                            ? AppColors.textDarkColor
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
