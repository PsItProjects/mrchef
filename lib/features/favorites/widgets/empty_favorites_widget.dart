import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';
import 'package:mrsheaf/features/home/controllers/main_controller.dart';

class EmptyFavoritesWidget extends GetView<FavoritesController> {
  const EmptyFavoritesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 20),

            Text(
              'start_favorite'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: AppColors.textDarkColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'save_store_and_product_message'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Get.find<MainController>().changeTab(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'home'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textDarkColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
