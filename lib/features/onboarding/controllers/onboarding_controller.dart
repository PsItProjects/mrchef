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
      title: 'Welcome to a World of Cooking!',
      description:
          'Discover the finest flavors and connect with passionate chefs who bring culinary excellence to your doorstep.',
    ),
    OnboardingPageModel(
      image: 'assets/onboarding_image_2.png',
      title: 'Shop with Ease!',
      description:
          'Browse a wide variety of meals and choose what suits your taste. We make food ordering simple and convenient.',
    ),
    OnboardingPageModel(
      image: 'assets/onboarding_image_3.png',
      title: 'Support Local Chefs',
      description:
          'Help your local chefs by ordering their amazing food and supporting their culinary journey in your community.',
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
