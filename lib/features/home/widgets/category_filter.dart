import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';

class CategoryFilter extends GetView<HomeController> {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Popular category with indicator
            Obx(() => GestureDetector(
              onTap: () => controller.selectCategory(0),
              child: Column(
                children: [
                  Text(
                    'Popular',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: controller.selectedCategoryIndex.value == 0
                          ? AppColors.primaryColor
                          : AppColors.lightGreyTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (controller.selectedCategoryIndex.value == 0)
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

            const SizedBox(width: 40),

            // Other categories
            ...List.generate(
              controller.categories.length - 1,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Obx(() => GestureDetector(
                  onTap: () => controller.selectCategory(index + 1),
                  child: Text(
                    controller.categories[index + 1],
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: controller.selectedCategoryIndex.value == index + 1
                          ? AppColors.primaryColor
                          : AppColors.lightGreyTextColor,
                    ),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
