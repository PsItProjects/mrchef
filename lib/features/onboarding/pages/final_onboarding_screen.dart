import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class FinalOnboardingScreen extends StatelessWidget {
  const FinalOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Large yellow background circle (top-left, partially visible)
            Positioned(
              top: (-screenHeight * 0.28) - 50,
              left: -screenWidth * 0.4,
              child: Container(
                width: screenWidth * 2.03,
                height: screenWidth * 2.03,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.favoriteButtonColor,
                ),
              ),
            ),
            // White circle with border (middle area)
            Positioned(
              top: (screenHeight * 0.23),
              left: -screenWidth * 0.245,
              child: Container(
                width: screenWidth * 0.92,
                height: screenWidth * 0.92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: Color(0xFFFFFAE6), // Light cream border
                    width: 20,
                  ),
                ),
              ),
            ),
            // Cucumber image (exact position from Figma)
            Positioned(
              top: screenHeight * 0.04,
              left: screenWidth * 0.33,
              child: Image.asset(
                'assets/cucumber_image.png',
                width: screenWidth * 1.02,
                height: screenHeight * 0.47,
                fit: BoxFit.contain,
              ),
            ),
            // Large background rectangle (behind vegetables)
            Positioned(
              top: screenHeight * 0.35,
              left: -screenWidth * 0.44,
              child: Container(
                width: screenWidth * 1.79,
                height: screenHeight * 0.83,
                color: Colors.transparent, // Invisible container for layout
              ),
            ),
            // White circle with gradient border (lower area)
            Positioned(
              top: -screenHeight * 0.013,
              left: screenWidth * 0.315,
              child: Container(
                width: screenWidth * 1.02,
                height: screenWidth * 1.02,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.white,
                    width: 20,
                  ),
                ),
              ),
            ),
            // Light cream circle (background accent)
            Positioned(
              top: screenHeight * 0.245,
              left: screenWidth * 0.318,
              child: Container(
                width: screenWidth * 0.72,
                height: screenWidth * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFFAE6), // Light cream
                ),
              ),
            ),
            // Lettuce image (exact position from Figma)
            Positioned(
              top: screenHeight * 0.14,
              left: -screenWidth * 0.42,
              child: Image.asset(
                'assets/lettuce_image.png',
                width: screenWidth * 1.23,
                height: screenHeight * 0.57,
                fit: BoxFit.contain,
              ),
            ),
            // Green blur circle (accent element)

            // Status bar (top of screen)

            // Language selector at top right (exactly as in Figma)
            Positioned(
              top: 68,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  // Toggle language
                  final languageService = Get.find<LanguageService>();
                  final newLanguage =
                      languageService.currentLanguage == 'ar' ? 'en' : 'ar';
                  languageService.setLanguage(newLanguage);
                  Get.updateLocale(
                      Locale(newLanguage, newLanguage == 'ar' ? 'SA' : 'US'));
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE3E3E3), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        child:
                            Icon(Icons.language, size: 16, color: Colors.white),
                      ),
                      SizedBox(width: 4),
                      Obx(() {
                        final languageService = Get.find<LanguageService>();
                        final isArabic =
                            languageService.currentLanguageRx.value == 'ar';
                        return Text(
                          isArabic ? 'arabic'.tr : 'english'.tr,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        );
                      }),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down,
                          size: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),

            // MrSheaf logo (exact position from Figma)
            Positioned(
              top: 26,
              left: 9,
              child: Image.asset(
                'assets/mr_sheaf_logo.png',
                width: 205,
                height: 236.3,
                fit: BoxFit.contain,
              ),
            ),

            // Bottom content area (exactly as in Figma)
            Positioned(
              bottom: 0,
              left: 24,
              right: 24,
              child: Container(
                width: 380,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ready_to_start'.tr,
                          style: AppTheme.headingStyle.copyWith(
                            color: AppColors.brownTextColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ready_to_start_description'.tr,
                          style: AppTheme.subheadingStyle.copyWith(
                            color: AppColors.lightGreyTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),

                    // Buttons (exactly as in Figma)
                    Column(
                      children: [
                        // Login button
                        Container(
                          width: 380,
                          child: ElevatedButton(
                            onPressed: () => Get.toNamed(AppRoutes.LOGIN),
                            style: AppTheme.primaryButtonStyle,
                            child: Text(
                              'login'.tr,
                              style: AppTheme.buttonTextStyle.copyWith(
                                color: AppColors.searchIconColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Sign up button
                        Container(
                          width: 380,
                          child: OutlinedButton(
                            onPressed: () => Get.toNamed(AppRoutes.SIGNUP),
                            style: AppTheme.secondaryButtonStyle,
                            child: Text(
                              'sign_up'.tr,
                              style: AppTheme.buttonTextStyle.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
