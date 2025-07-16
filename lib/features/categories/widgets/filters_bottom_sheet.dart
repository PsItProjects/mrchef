import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';
import 'package:mrsheaf/features/categories/widgets/filter_section.dart';

class FiltersBottomSheet extends GetView<CategoriesController> {
  const FiltersBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 926,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: const BoxDecoration(
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
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF592E2C),
                    letterSpacing: 1.5,
                  ),
                ),
                
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/icons/close_icon.svg',
                      width: 24,
                      height: 24,
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
          
          // Filters list
          Expanded(
            child: SingleChildScrollView(
              child: Obx(() => Column(
                children: List.generate(
                  controller.filters.length,
                  (index) => FilterSection(
                    filter: controller.filters[index],
                    filterIndex: index,
                  ),
                ),
              )),
            ),
          ),
          
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE3E3E3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Clear filters button
                Expanded(
                  child: GestureDetector(
                    onTap: controller.clearFilters,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Apply filters button
                Expanded(
                  child: GestureDetector(
                    onTap: controller.applyFilters,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF592E2C),
                          ),
                        ),
                      ),
                    ),
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
