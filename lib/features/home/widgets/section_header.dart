import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';
import 'package:mrsheaf/core/services/language_service.dart';

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
    final languageService = LanguageService.instance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getLocalizedTitle(languageService.currentLanguage),
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
            child: Text(
              _getLocalizedSeeAll(languageService.currentLanguage),
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.lightGreyTextColor,
              ),
            ),
          ),
        ],
      )),
    );
  }

  String _getLocalizedTitle(String language) {
    final translations = {
      'Kitchens': {
        'ar': 'المطابخ',
        'en': 'Kitchens',
      },
      'Best seller': {
        'ar': 'الأكثر مبيعاً',
        'en': 'Best seller',
      },
      'Back again': {
        'ar': 'عاد مرة أخرى',
        'en': 'Back again',
      },
    };

    return translations[title]?[language] ?? title;
  }

  String _getLocalizedSeeAll(String language) {
    return language == 'ar' ? 'عرض الكل' : 'See All';
  }
}
