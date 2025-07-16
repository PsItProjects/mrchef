import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/features/categories/widgets/filter_option_item.dart';

class FilterSection extends GetView<CategoriesController> {
  final FilterModel filter;
  final int filterIndex;

  const FilterSection({
    super.key,
    required this.filter,
    required this.filterIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 339,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF2F2F2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => controller.toggleFilterExpansion(filterIndex),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE3E3E3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filter.title,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF262626),
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  Transform.rotate(
                    angle: filter.isExpanded ? 0 : 3.14159, // 180 degrees
                    child: SvgPicture.asset(
                      'assets/icons/arrow_up_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF262626),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Options (expanded)
          if (filter.isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // Options list
                  Column(
                    children: List.generate(
                      filter.options.length,
                      (optionIndex) => FilterOptionItem(
                        option: filter.options[optionIndex],
                        filterIndex: filterIndex,
                        optionIndex: optionIndex,
                      ),
                    ),
                  ),
                  
                  // Custom price range (for Price Range filter)
                  if (filter.title == 'Price Range')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'From',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF262626),
                            ),
                          ),
                          Container(
                            width: 98,
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE3E3E3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF262626),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            'To',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF262626),
                            ),
                          ),
                          Container(
                            width: 98,
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE3E3E3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                '1000',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF262626),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            '\$',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF262626),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
