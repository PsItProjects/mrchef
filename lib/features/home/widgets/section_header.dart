import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
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
    // Map English titles to translation keys
    final titleKeys = {
      'Kitchens': 'categories',
      'Best seller': 'best_seller',
      'Back again': 'recently',
      'Featured Restaurants': 'featured_restaurants',
      'Nearby Restaurants': 'nearby_restaurants',
      'Popular Categories': 'popular_categories',
      'Top Picks': 'top_picks',
      'Special Offers': 'special_offers',
    };

    final key = titleKeys[title];
    return key != null ? key.tr : title;
  }

  String _getLocalizedSeeAll(String language) {
    return 'see_all'.tr;
  }
}
