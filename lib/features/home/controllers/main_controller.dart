import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/services/guest_service.dart';

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

  /// Check if user is in guest mode
  bool get _isGuestMode {
    try {
      final guestService = Get.find<GuestService>();
      return guestService.isGuestMode;
    } catch (e) {
      return false;
    }
  }

  /// Show guest mode modal with custom message
  void _showGuestModal(String message) {
    try {
      final guestService = Get.find<GuestService>();
      guestService.showLoginRequiredModal(
        message: message,
      );
    } catch (e) {
      print('❌ Error showing guest modal: $e');
    }
  }
  
  // Method to change tab
  void changeTab(int index) {
    // In guest mode: allow browsing Home/Categories/Cart/Favorites, block Profile.
    if (_isGuestMode && index == 4) {
      _showGuestModal('guest_profile_message'.tr);
      return;
    }
    
    // Check if trying to access favorites (index 3) without authentication
    if (index == 3) { // Favorites tab
      if (_isGuestMode) {
        currentIndex.value = index;
        return;
      }
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
