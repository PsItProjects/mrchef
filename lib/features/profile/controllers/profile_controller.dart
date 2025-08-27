import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/user_profile_model.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/profile/pages/edit_profile_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_orders_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_reviews_screen.dart';
import 'package:mrsheaf/features/profile/pages/settings_screen.dart';
import 'package:mrsheaf/features/profile/pages/shipping_addresses_screen.dart';
import '../../auth/services/auth_service.dart';

class ProfileController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;

  // User profile data
  final Rx<UserProfileModel> userProfile = UserProfileModel(
    id: 1,
    fullName: 'Sana Ahmad',
    email: 'sanaahmd@mail.com',
    phoneNumber: '58 768 8576',
    countryCode: '+966',
  ).obs;

  // Profile stats
  final RxInt orderCount = 10.obs;
  final RxInt addressCount = 3.obs;
  final RxInt cardCount = 2.obs;
  final RxInt reviewCount = 5.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authService = Get.find<AuthService>();
      final response = await authService.getCustomerProfile();

      if (response.isSuccess && response.data != null) {
        final user = response.data!;
        userProfile.value = UserProfileModel(
          id: user.id,
          fullName: user.displayName,
          email: user.email ?? '',
          phoneNumber: user.phoneNumber,
          countryCode: user.countryCode,
        );
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Keep using sample data if API fails
    }
  }

  // Navigation methods
  void navigateToEditProfile() {
    // Get.toNamed('/profile/edit');
    Get.to(() => const EditProfileScreen());

  }

  void navigateToMyOrders() {
    Get.to(() => const MyOrdersScreen());
  }

  void navigateToShippingAddresses() {
    Get.to(() => const ShippingAddressesScreen());
  }

  void navigateToPaymentMethods() {
    Get.toNamed('/profile/payment');
  }

  void navigateToMyReviews() {
    Get.to(() => const MyReviewsScreen());
  }

  void navigateToSettings() {
    Get.to(() => const SettingsScreen());
  }

  // Profile actions
  void updateProfile(UserProfileModel updatedProfile) {
    userProfile.value = updatedProfile;
    Get.snackbar(
      'Profile Updated',
      'Your profile has been updated successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void changeProfilePhoto() {
    // TODO: Implement photo picker
    Get.snackbar(
      'Change Photo',
      'Photo picker functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF5E5E5E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFFEB5757),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      isLoading.value = true;

      // Call logout API through AuthService
      final authService = Get.find<AuthService>();
      final response = await authService.logout();

      if (response.isSuccess) {
        Get.snackbar(
          'Logged Out',
          'You have been logged out successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.3),
        );

        // Navigate to login screen
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Logout Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during logout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Getters for UI
  String get orderCountText => 'Already have $orderCount orders';
  String get addressCountText => '${addressCount.toString().padLeft(2, '0')} Addresses';
  String get cardCountText => 'You have $cardCount cards';
  String get reviewCountText => 'Reviews for $reviewCount items';
}
