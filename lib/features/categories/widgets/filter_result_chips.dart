import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';

class FilterResultChips extends GetView<CategoriesController> {
  const FilterResultChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.appliedFilters.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        width: 328, // Width from Figma
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Regular filter chips
            ...controller.appliedFilters.take(3).map((filter) => 
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter.length > 10 ? '${filter.substring(0, 10)}....' : filter,
                      style: AppTheme.smallButtonTextStyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => controller.removeFilter(filter),
                      child: Container(
                        width: 18,
                        height: 18,
                        child: SvgPicture.asset(
                          'assets/icons/close_icon.svg',
                          width: 10.5,
                          height: 10.5,
                          colorFilter: const ColorFilter.mode(
                            AppColors.searchIconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // "+X more" chip if there are more than 3 filters
            if (controller.appliedFilters.length > 3)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGreyTextColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+ ${controller.appliedFilters.length - 3} more',
                      style: AppTheme.smallButtonTextStyle.copyWith(
                        fontSize: 14,
                        color: AppColors.textLightColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 18,
                      height: 18,
                      child: SvgPicture.asset(
                        'assets/icons/close_icon.svg',
                        width: 10.5,
                        height: 10.5,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textLightColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
