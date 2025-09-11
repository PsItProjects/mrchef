import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';

class MainController extends GetxController {
  // Current selected tab index
  final RxInt currentIndex = 0.obs;

  // Auth service
  final AuthService _authService = Get.find<AuthService>();
  
  // Tab names for reference
  final List<String> tabNames = [
    'Home',
    'Categories', 
    'Cart',
    'Favorite',
    'Profile'
  ];
  
  // Method to change tab
  void changeTab(int index) {
    // Check if trying to access favorites (index 3) without authentication
    if (index == 3) { // Favorites tab
      if (!_authService.isAuthenticated) {
        Get.snackbar(
          'authentication_required'.tr,
          'please_login_to_continue'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.3),
        );
        Get.toNamed('/login');
        return;
      }

      if (!_authService.isCustomer) {
        Get.snackbar(
          'access_denied'.tr,
          'customer_only_feature'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
        return;
      }
    }

    currentIndex.value = index;
  }
  
  // Get current tab name
  String get currentTabName => tabNames[currentIndex.value];
}
