import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';

class EmptyFavoritesWidget extends GetView<FavoritesController> {
  const EmptyFavoritesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty favorites illustration
          Container(
            width: 428,
            height: 337.6,
            child: Image.asset(
              'assets/images/empty_favorites_illustration.png',
              fit: BoxFit.contain,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Empty favorites text
          Column(
            children: [
              Text(
                'start_favorite'.tr,
                style: AppTheme.subheadingStyle.copyWith(
                  color: AppColors.darkTextColor,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                width: 285,
                child: Text(
                  'save_store_and_product_message'.tr,
                  textAlign: TextAlign.center,
                  style: AppTheme.searchTextStyle,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Checkout button (as per Figma design)
          Container(
            width: 380,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to home or categories to find favorites
                Get.offAllNamed('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'home'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF592E2C),
                  letterSpacing: -0.005,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
