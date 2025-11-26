import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/search/controllers/search_controller.dart' as search;

class SearchAppBar extends GetView<search.SearchController> {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow_left.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF262626),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Search input field
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  
                  // Search icon
                  SvgPicture.asset(
                    'assets/icons/search_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF592E2C),
                      BlendMode.srcIn,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: controller.searchTextController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'search_food'.tr,
                        hintStyle: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF5E5E5E),
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF262626),
                      ),
                      onChanged: (value) {
                        controller.updateSearchQuery(value);
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          controller.search();
                        }
                      },
                    ),
                  ),
                  
                  // Clear button
                  Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return GestureDetector(
                        onTap: controller.clearSearch,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.clear,
                            color: const Color(0xFF5E5E5E),
                            size: 20,
                          ),
                        ),
                      );
                    }
                    return const SizedBox(width: 16);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

