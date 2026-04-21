import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/services/guest_service.dart';

class MainController extends GetxController {
  // Current selected tab index
  final RxInt currentIndex = 0.obs;

  // Auth service
  final AuthService _authService = Get.find<AuthService>();

  // Tab names for reference (customer mode)
  final List<String> tabNames = [
    'Home',
    'Categories',
    'Cart',
    'Favorite',
    'Profile'
  ];

  /// Whether shell is currently rendering merchant tabs.
  bool get isMerchantShell {
    try {
      if (Get.isRegistered<ProfileSwitchService>()) {
        final s = Get.find<ProfileSwitchService>().accountStatus.value;
        if (s != null) return s.isMerchantMode;
      }
    } catch (_) {}
    return _authService.userType.value == 'merchant';
  }

  /// Last tab index (Settings) for the current role.
  int get settingsTabIndex => isMerchantShell ? 3 : 4;

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
    final isMerchant = isMerchantShell;

    // Customer-mode-only guard rails
    if (!isMerchant) {
      // In guest mode: allow browsing Home/Categories/Cart/Favorites, block Profile.
      if (_isGuestMode && index == 4) {
        _showGuestModal('guest_profile_message'.tr);
        return;
      }

      // Check if trying to access favorites (index 3) without authentication
      if (index == 3) {
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
    }

    currentIndex.value = index;
  }

  /// Snap to the Settings tab of whatever role is currently active.
  /// Used after a role switch so the user stays in Settings across roles.
  void goToSettings() {
    currentIndex.value = settingsTabIndex;
  }

  // Get current tab name
  String get currentTabName =>
      currentIndex.value < tabNames.length ? tabNames[currentIndex.value] : '';
}
