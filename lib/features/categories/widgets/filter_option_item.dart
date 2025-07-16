import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';

class FilterOptionItem extends GetView<CategoriesController> {
  final FilterOption option;
  final int filterIndex;
  final int optionIndex;

  const FilterOptionItem({
    super.key,
    required this.option,
    required this.filterIndex,
    required this.optionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.toggleFilterOption(filterIndex, optionIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Option name and rating (if applicable)
            Expanded(
              child: Row(
                children: [
                  // Rating stars (for rating filter)
                  if (option.rating != null) ...[
                    Row(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SvgPicture.asset(
                            'assets/icons/star_icon.svg',
                            width: 18,
                            height: 17,
                            colorFilter: ColorFilter.mode(
                              index < option.rating! 
                                ? AppColors.primaryColor 
                                : const Color(0xFFFEF0B4),
                              BlendMode.srcIn,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Option text
                  Text(
                    '${option.name} ( ${option.count} )',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: option.isSelected 
                          ? const Color(0xFF4B4B4B) 
                          : const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            
            // Checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF4B4B4B),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: option.isSelected
                  ? Center(
                      child: SvgPicture.asset(
                        'assets/icons/check_icon.svg',
                        width: 15.42,
                        height: 15.42,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF4B4B4B),
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
