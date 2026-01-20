import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';

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
        ToastService.showWarning('please_login_to_continue'.tr);
        Get.toNamed('/login');
        return;
      }

      if (!_authService.isCustomer) {
        ToastService.showError('customer_only_feature'.tr);
        return;
      }
    }

    currentIndex.value = index;
  }
  
  // Get current tab name
  String get currentTabName => tabNames[currentIndex.value];
}
