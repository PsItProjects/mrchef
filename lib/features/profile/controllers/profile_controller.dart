import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/user_profile_model.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/profile/pages/edit_profile_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_orders_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_reviews_screen.dart';
import 'package:mrsheaf/features/profile/pages/settings_screen.dart';
import 'package:mrsheaf/features/profile/pages/shipping_addresses_screen.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';
import 'package:mrsheaf/features/profile/services/address_service.dart';
import 'package:mrsheaf/features/profile/services/order_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
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
  final RxInt orderCount = 0.obs;
  final RxInt addressCount = 0.obs;
  final RxInt cardCount = 2.obs;
  final RxInt reviewCount = 5.obs;

  final AddressService _addressService = AddressService();
  late final OrderService _orderService;

  @override
  void onInit() {
    super.onInit();
    _orderService = OrderService(Get.find<ApiClient>());
    _loadUserProfile();
    _loadAddressCount();
    _loadOrderCount();
  }

  Future<void> _loadAddressCount() async {
    try {
      final addresses = await _addressService.getAddresses();
      addressCount.value = addresses.length;
      print('📍 PROFILE: Loaded ${addressCount.value} addresses');
    } catch (e) {
      print('❌ PROFILE: Error loading address count - $e');
      // Keep default value if API fails
    }
  }

  Future<void> _loadOrderCount() async {
    try {
      final response = await _orderService.getOrders(page: 1, perPage: 1);
      final pagination = response['pagination'] as Map<String, dynamic>;
      orderCount.value = pagination['total'] ?? 0;
      print('📦 PROFILE: Loaded ${orderCount.value} orders');
    } catch (e) {
      print('❌ PROFILE: Error loading order count - $e');
      // Keep default value if API fails
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      print('🔄 PROFILE: Loading user profile from API...');
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
          avatar: user.avatarUrl, // ✅ تحميل رابط الصورة
        );

        print('✅ PROFILE: Loaded user profile');
        print('   - Name: ${user.displayName}');
        print('   - Email: ${user.email}');
        print('   - Avatar: ${user.avatarUrl}');
      } else {
        print('❌ PROFILE: Failed to load - ${response.message}');
      }
    } catch (e) {
      print('❌ PROFILE: Error loading user profile - $e');
      // Keep using sample data if API fails
    }
  }

  /// Refresh profile data (call this when returning from edit profile)
  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  // Navigation methods
  void navigateToEditProfile() async {
    // Get.toNamed('/profile/edit');
    await Get.to(() => const EditProfileScreen());
    // Refresh profile when returning from edit screen
    await refreshProfile();
  }

  void navigateToMyOrders() async {
    // Ensure MyOrdersController is registered
    if (!Get.isRegistered<MyOrdersController>()) {
      Get.lazyPut<MyOrdersController>(() => MyOrdersController());
    }
    await Get.to(() => const MyOrdersScreen());
    // Reload order count when returning from my orders screen
    _loadOrderCount();
  }

  void navigateToShippingAddresses() async {
    await Get.to(() => const ShippingAddressesScreen());
    // Reload address count when returning from shipping addresses screen
    _loadAddressCount();
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
  String get addressCountText =>
      '${addressCount.toString().padLeft(2, '0')} Addresses';
  String get cardCountText => 'You have $cardCount cards';
  String get reviewCountText => 'Reviews for $reviewCount items';
}
