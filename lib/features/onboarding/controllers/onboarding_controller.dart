import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/onboarding/models/onboarding_page_model.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      image: 'assets/onboarding_image_3.png',
      title: 'onboarding_page1_title',
      description: 'onboarding_page1_description',
    ),
    OnboardingPageModel(
      image: 'assets/onboarding_image_2.png',
      title: 'onboarding_page2_title',
      description: 'onboarding_page2_description',
    ),
    OnboardingPageModel(
      image: 'assets/onboarding_image_3.png',
      title: 'onboarding_page3_title',
      description: 'onboarding_page3_description',
    ),
  ];

  void updateCurrentPage(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(AppRoutes.FINAL_ONBOARDING);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
