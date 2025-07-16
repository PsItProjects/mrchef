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
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF592E2C),
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
                            Color(0xFF592E2C),
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
                  color: const Color(0xFF999999),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+ ${controller.appliedFilters.length - 3} more',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
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
                          Colors.white,
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
