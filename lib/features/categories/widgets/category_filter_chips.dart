import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';

class CategoryFilterChips extends GetView<CategoriesController> {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Height from Figma
      // padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        print('🔍 CategoryFilterChips: Building with ${controller.categoryChips.length} categories');
        print('🔍 CategoryFilterChips: isLoadingCategories = ${controller.isLoadingCategories.value}');

        if (controller.isLoadingCategories.value) {
          print('⏳ CategoryFilterChips: Still loading categories...');
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.categoryChips.isEmpty) {
          print('⚠️ CategoryFilterChips: No categories to display');
          return Center(
            child: Text(
              'لا توجد تصنيفات متاحة',
              style: AppTheme.bodyStyle.copyWith(
                color: AppColors.darkTextColor,
              ),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categoryChips.length,
          // physics: ,
          itemBuilder: (context, index) {
          final chip = controller.categoryChips[index];
          return Container(
            margin: const EdgeInsets.only(right: 16),

            child: GestureDetector(
              onTap: () => controller.selectCategoryChip(index),
              child: Container(
                // width: 80, // Width from Figma
                // height: 100, // Height from Figma
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: chip.isSelected
                      ? AppColors.primaryColor
                      : AppColors.lightGreyColor,
                  borderRadius: BorderRadius.circular(87),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackShadowColor.withOpacity(0.2),
                      blurRadius: 2.45,
                    ),
                    BoxShadow(
                      color: AppColors.blackShadowColor.withOpacity(0.1),
                      blurRadius: 4.91,
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category icon/image
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.greyColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blackShadowColor.withOpacity(0.25),
                              blurRadius: 0.49,
                              offset: const Offset(0, 0.61),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/pizza_main.png', // Using existing pizza image
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // const SizedBox(height: 8),

                      // Category name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:  8.0),
                        child: Text(
                          chip.displayName,
                          style: AppTheme.tabTextStyle.copyWith(
                            fontWeight: chip.isSelected ? FontWeight.w400 : FontWeight.w300,
                            color: chip.isSelected
                                ? AppColors.searchIconColor
                                : AppColors.darkTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      }),
    );
  }
}
