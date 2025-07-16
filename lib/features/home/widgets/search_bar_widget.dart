import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';

class SearchBarWidget extends GetView<HomeController> {
  const SearchBarWidget({super.key});

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
              // Search icon container with proper background
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor, // Yellow background for icon
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/search_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF592E2C), // Brown color from Figma
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Search text
              const Expanded(
                child: Text(
                  'Search products',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF5E5E5E), // Gray text color from Figma
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
