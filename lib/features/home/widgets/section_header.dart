import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';

class SectionHeader extends GetView<HomeController> {
  final String title;
  final String section;

  const SectionHeader({
    super.key,
    required this.title,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textDarkColor,
              letterSpacing: -0.005,
            ),
          ),
          GestureDetector(
            onTap: () => controller.onSeeAllTap(section),
            child: const Text(
              'See All',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.lightGreyTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
