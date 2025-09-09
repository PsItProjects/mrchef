import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';

class CategoryFilter extends GetView<HomeController> {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService.instance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 2,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Popular category with indicator (always first)
              GestureDetector(
                onTap: () => controller.selectCategoryById(0),
                child: Column(
                  children: [
                    Text(
                      languageService.getLocalizedText({
                        'ar': 'شائع',
                        'en': 'Popular'
                      }),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: controller.selectedCategoryId.value == 0
                            ? AppColors.primaryColor
                            : AppColors.lightGreyTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (controller.selectedCategoryId.value == 0)
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
              ),

              const SizedBox(width: 40),

              // Categories from backend
              ...controller.categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 40),
                child: GestureDetector(
                  onTap: () => controller.selectCategoryById(category.id),
                  child: Column(
                    children: [
                      Text(
                        languageService.getLocalizedText(category.name),
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: controller.selectedCategoryId.value == category.id
                              ? AppColors.primaryColor
                              : AppColors.lightGreyTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (controller.selectedCategoryId.value == category.id)
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
                ),
              )),
            ],
          ),
        );
      }),
    );
  }
}
