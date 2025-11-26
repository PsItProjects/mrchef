import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';

class SearchBarWithFilter extends GetView<CategoriesController> {
  const SearchBarWithFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: controller.onSearchTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAE6), // Light yellow background from Figma
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
                  Color(0xFF592E2C), // Brown color from Figma
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 16),
              // Search hint text
              Expanded(
                child: Text(
                  'search_food'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF5E5E5E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
