import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mrsheaf/features/profile/models/user_profile_model.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/services/guest_service.dart';
import 'package:mrsheaf/features/profile/pages/edit_profile_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_orders_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_reviews_screen.dart';
import 'package:mrsheaf/features/profile/pages/settings_screen.dart';
import 'package:mrsheaf/features/profile/pages/shipping_addresses_screen.dart';
import 'package:mrsheaf/features/profile/pages/privacy_policy_screen.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';
import 'package:mrsheaf/features/profile/services/address_service.dart';
import 'package:mrsheaf/features/profile/services/order_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import '../../../core/services/toast_service.dart';
import '../../auth/services/auth_service.dart';

class ProfileController extends GetxController {
  // Cache Keys
  static const String _profileCacheKey = 'cached_user_profile';
  static const String _orderCountCacheKey = 'cached_order_count';
  static const String _addressCountCacheKey = 'cached_address_count';
  
  // Loading state
  final RxBool isLoading = false.obs;

  // User profile data - will be loaded from cache or API
  final Rx<UserProfileModel> userProfile = UserProfileModel(
    id: 0,
    fullName: '',
    email: '',
    phoneNumber: '',
    countryCode: '',
  ).obs;

  // Profile stats
  final RxInt orderCount = 0.obs;
  final RxInt addressCount = 0.obs;
  final RxInt cardCount = 2.obs;
  final RxInt reviewCount = 5.obs;

  final AddressService _addressService = AddressService();
  late final OrderService _orderService;

  /// Load cached data from SharedPreferences
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cached profile
      final cachedProfile = prefs.getString(_profileCacheKey);
      if (cachedProfile != null) {
        final Map<String, dynamic> profileJson = json.decode(cachedProfile);
        userProfile.value = UserProfileModel.fromJson(profileJson);
        print('💾 PROFILE: Loaded from cache');
        print('   - Name: ${userProfile.value.fullName}');
      }
      
      // Load cached order count
      final cachedOrderCount = prefs.getInt(_orderCountCacheKey);
      if (cachedOrderCount != null) {
        orderCount.value = cachedOrderCount;
        print('💾 PROFILE: Loaded order count from cache: $cachedOrderCount');
      }
      
      // Load cached address count
      final cachedAddressCount = prefs.getInt(_addressCountCacheKey);
      if (cachedAddressCount != null) {
        addressCount.value = cachedAddressCount;
        print('💾 PROFILE: Loaded address count from cache: $cachedAddressCount');
      }
    } catch (e) {
      print('❌ PROFILE: Error loading cached data - $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    _orderService = OrderService(Get.find<ApiClient>());
    
    // Check if user is in guest mode
    if (_isGuestMode) {
      // Show modal for guest mode
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGuestModeModal();
      });
      return;
    }
    
    // تحميل البيانات من الـ Cache أولاً
    _loadCachedData();
    // ثم تحديث البيانات من الـ API
    _loadUserProfile();
    _loadAddressCount();
    _loadOrderCount();
  }

  /// Check if user is in guest mode
  bool get _isGuestMode {
    try {
      final guestService = Get.find<GuestService>();
      return guestService.isGuestMode;
    } catch (e) {
      return false;
    }
  }

  /// Show guest mode modal
  void _showGuestModeModal() {
    try {
      final guestService = Get.find<GuestService>();
      guestService.showLoginRequiredModal(
        message: 'guest_profile_message'.tr,
      );
    } catch (e) {
      print('❌ PROFILE: Error showing guest modal - $e');
    }
  }

  Future<void> _loadAddressCount() async {
    try {
      final addresses = await _addressService.getAddresses();
      addressCount.value = addresses.length;
      
      // Save to cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_addressCountCacheKey, addressCount.value);
      
      print('📍 PROFILE: Loaded ${addressCount.value} addresses and cached');
    } catch (e) {
      print('❌ PROFILE: Error loading address count - $e');
      // Keep cached value if API fails
    }
  }

  Future<void> _loadOrderCount() async {
    try {
      final response = await _orderService.getOrders(page: 1, perPage: 1);
      final pagination = response['pagination'] as Map<String, dynamic>;
      orderCount.value = pagination['total'] ?? 0;
      
      // Save to cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_orderCountCacheKey, orderCount.value);
      
      print('📦 PROFILE: Loaded ${orderCount.value} orders and cached');
    } catch (e) {
      print('❌ PROFILE: Error loading order count - $e');
      // Keep cached value if API fails
    }
  }

  /// Load user profile from API
  /// [skipLanguageUpdate] - إذا true، لا يحدث لغة التطبيق (بعد تعديل الملف الشخصي)
  Future<void> _loadUserProfile({bool skipLanguageUpdate = false}) async {
    try {
      print('🔄 PROFILE: Loading user profile from API... (skipLanguageUpdate: $skipLanguageUpdate)');
      final authService = Get.find<AuthService>();
      final response = await authService.getCustomerProfile(skipLanguageUpdate: skipLanguageUpdate);

      if (response.isSuccess && response.data != null) {
        final user = response.data!;
        userProfile.value = UserProfileModel(
          id: user.id,
          fullName: user.displayName,
          email: user.email ?? '',
          phoneNumber: user.phoneNumber,
          countryCode: user.countryCode,
          avatar: user.avatarUrl,
        );

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        final profileJson = json.encode(userProfile.value.toJson());
        await prefs.setString(_profileCacheKey, profileJson);

        print('✅ PROFILE: Loaded and cached user profile');
        print('   - Name: ${user.displayName}');
        print('   - Email: ${user.email}');
        print('   - Avatar: ${user.avatarUrl}');
      } else {
        print('❌ PROFILE: Failed to load - ${response.message}');
      }
    } catch (e) {
      print('❌ PROFILE: Error loading user profile - $e');
      // Keep using cached data if API fails
    }
  }

  /// Refresh profile data (call this when returning from edit profile)
  /// 
  /// If [forceRefresh] is true, shows loading indicator and loads directly from API
  /// If [forceRefresh] is false (default), loads from cache first then refreshes in background
  /// [skipLanguageUpdate] - إذا true، لا يحدث لغة التطبيق (يُستخدم بعد تعديل الملف الشخصي)
  Future<void> refreshProfile({bool forceRefresh = false, bool skipLanguageUpdate = false}) async {
    if (forceRefresh) {
      print('🔄 PROFILE CONTROLLER: Force refreshing from API...');
      isLoading.value = true;
      await _loadUserProfile(skipLanguageUpdate: skipLanguageUpdate);
      isLoading.value = false;
      print('✅ PROFILE CONTROLLER: Force refresh complete');
      print('   - Updated Name: ${userProfile.value.fullName}');
    } else {
      print('🔄 PROFILE CONTROLLER: Background refresh from API...');
      await _loadUserProfile(skipLanguageUpdate: skipLanguageUpdate);
      print('✅ PROFILE CONTROLLER: Background refresh complete');
    }
  }

  // Navigation methods
  void navigateToEditProfile() async {
    print('🔄 PROFILE CONTROLLER: Navigating to Edit Profile...');
    // Get.toNamed('/profile/edit');
    await Get.to(() => const EditProfileScreen());
    // Force refresh profile when returning from edit screen to ensure latest data is shown
    // ✅ skipLanguageUpdate: true - لمنع تغيير لغة التطبيق بعد التعديل
    print('🔄 PROFILE CONTROLLER: Returned from Edit Profile, forcing refresh...');
    await refreshProfile(forceRefresh: true, skipLanguageUpdate: true);
    print('✅ PROFILE CONTROLLER: Profile card should now show updated name: ${userProfile.value.fullName}');
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

  void navigateToSupportTickets() {
    Get.toNamed('/support/tickets');
  }

  void navigateToMyReports() {
    Get.toNamed('/support/reports');
  }

  /// Open Privacy Policy page in WebView
  /// Account deletion is handled through: https://mr-shife.com/complaints
  void openPrivacyPolicy() {
    Get.to(() => const PrivacyPolicyScreen());
  }

  // Profile actions
  Future<void> updateProfile(UserProfileModel updatedProfile) async {
    userProfile.value = updatedProfile;
    
    // Update cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(updatedProfile.toJson());
      await prefs.setString(_profileCacheKey, profileJson);
      print('💾 PROFILE: Updated cache after profile edit');
    } catch (e) {
      print('❌ PROFILE: Error updating cache - $e');
    }
    
    ToastService.showSuccess('تم تحديث ملفك الشخصي بنجاح');
  }

  void changeProfilePhoto() {
    // TODO: Implement photo picker
    ToastService.showInfo('سيتم إضافة هذه الميزة قريباً');
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
        // Clear cached profile data
        await _clearCache();
        
        ToastService.showSuccess('تم تسجيل الخروج بنجاح');

        // Navigate to login screen
        Get.offAllNamed('/login');
      } else {
        ToastService.showError(response.message);
      }
    } catch (e) {
      ToastService.showError('An error occurred during logout');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all cached profile data
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileCacheKey);
      await prefs.remove(_orderCountCacheKey);
      await prefs.remove(_addressCountCacheKey);
      print('🗑️ PROFILE: Cache cleared on logout');
    } catch (e) {
      print('❌ PROFILE: Error clearing cache - $e');
    }
  }

  // Getters for UI
  String get orderCountText => 'Already have $orderCount orders';
  String get addressCountText =>
      '${addressCount.toString().padLeft(2, '0')} Addresses';
  String get cardCountText => 'You have $cardCount cards';
  String get reviewCountText => 'Reviews for $reviewCount items';
}
