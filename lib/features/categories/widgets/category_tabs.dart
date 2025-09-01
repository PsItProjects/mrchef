import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';

class CategoryTabs extends GetView<CategoriesController> {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Meals tab
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () => controller.changeTab(0),
              child: Column(
                children: [
                  Text(
                    'Meals',
                    style: AppTheme.tabTextStyle.copyWith(
                      fontWeight: controller.currentTabIndex.value == 0
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: controller.currentTabIndex.value == 0
                          ? AppColors.lightGreyTextColor
                          : AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (controller.currentTabIndex.value == 0)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            )),
          ),
          
          const SizedBox(width: 40),
          
          // Kitchens tab
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () => controller.changeTab(1),
              child: Column(
                children: [
                  Text(
                    'Kitchens',
                    style: AppTheme.tabTextStyle.copyWith(
                      fontWeight: controller.currentTabIndex.value == 1
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: controller.currentTabIndex.value == 1
                          ? AppColors.lightGreyTextColor
                          : AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (controller.currentTabIndex.value == 1)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
