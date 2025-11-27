import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/restaurants/controllers/all_restaurants_controller.dart';

class AllRestaurantsHeader extends GetView<AllRestaurantsController> {
  const AllRestaurantsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Get.locale?.languageCode == 'ar'
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textDarkColor,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              'all_restaurants'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textDarkColor,
              ),
            ),
          ),
          
          // Restaurant count
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.filteredRestaurants.length}',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

