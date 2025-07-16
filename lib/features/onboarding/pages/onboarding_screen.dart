import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/onboarding/controllers/onboarding_controller.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/onboarding/widgets/onboarding_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(OnboardingController());

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Stack(
          children: [
            // Language selector at top right
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.secondaryColor
                          .withAlpha(51)), // 0.2 opacity
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language,
                        size: 16, color: AppColors.secondaryColor),
                    SizedBox(width: 4),
                    Text(
                      'English',
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: AppColors.secondaryColor),
                  ],
                ),
              ),
            ),

            // Skip button at top left
            Positioned(
              top: 20,
              left: 20,
              child: TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.FINAL_ONBOARDING),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.pages.length,
                    onPageChanged: controller.updateCurrentPage,
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      return OnboardingPage(
                        image: page.image,
                        title: page.title,
                        description: page.description,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SmoothPageIndicator(
                        controller: controller.pageController,
                        count: controller.pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: AppColors.primaryColor,
                          dotColor: Colors.grey.shade300,
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          expansionFactor: 4,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      SizedBox(
                        width: double.infinity,
                        height: 56, // Increased height for better text visibility
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: AppColors.secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    controller.currentPage.value <
                                            controller.pages.length - 1
                                        ? 'Next'
                                        : 'Get Started',
                                    style: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: AppColors.secondaryColor,
                                      letterSpacing: -0.005,
                                      height: 1.2, // Reduced line height for better fit
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.secondaryColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )));
  }
}
