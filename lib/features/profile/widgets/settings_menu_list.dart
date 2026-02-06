import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/biometric_service.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/profile/controllers/settings_controller.dart';
import 'package:mrsheaf/features/profile/widgets/settings_menu_item.dart';

class SettingsMenuList extends GetView<SettingsController> {
  const SettingsMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          // Profile Switch / Become Merchant
          _buildProfileSwitchItem(),

          // Dark Mode
          Obx(() => SettingsMenuItem(
            title: 'dark_mode'.tr,
            hasToggle: true,
            toggleValue: controller.isDarkMode,
            onToggleChanged: controller.toggleDarkMode,
            showDivider: true,
          )),

          // Biometric Login - يظهر فقط إذا كان الجهاز يدعم البصمة
          _buildBiometricToggle(),

          // Currency
          Obx(() => SettingsMenuItem(
            title: 'currency_label'.tr,
            subtitle: controller.currency,
            onTap: controller.changeCurrency,
            showDivider: true,
          )),

          // Language
          Obx(() => SettingsMenuItem(
            title: 'language_label'.tr,
            subtitle: controller.languageDisplayName,
            onTap: controller.isChangingLanguage.value ? null : controller.changeLanguage,
            showDivider: true,
            isLoading: controller.isChangingLanguage.value,
          )),

          // My Reviews - Only for customers
          _buildMyReviewsItem(),

          // Conversations
          SettingsMenuItem(
            title: 'conversations'.tr,
            hasArrow: true,
            onTap: controller.navigateToConversations,
            showDivider: true,
          ),

          // Help & Support
          SettingsMenuItem(
            title: 'help_support'.tr,
            hasArrow: true,
            onTap: controller.navigateToSupport,
            showDivider: true,
          ),

          // Notification
          SettingsMenuItem(
            title: 'notification_label'.tr,
            hasArrow: true,
            onTap: controller.openNotificationSettings,
            showDivider: true,
          ),

          // Security
          SettingsMenuItem(
            title: 'security'.tr,
            hasArrow: true,
            onTap: controller.openSecuritySettings,
            showDivider: true,
          ),

          // Clear app cache
          Obx(() => SettingsMenuItem(
            title: 'clear_app_cache'.tr,
            subtitle: controller.cacheSize,
            onTap: controller.clearAppCache,
            showDivider: true,
          )),

          // Rate the app
          SettingsMenuItem(
            title: 'rate_the_app'.tr,
            hasArrow: true,
            onTap: controller.rateTheApp,
            showDivider: true,
          ),

          // About Heba App
          SettingsMenuItem(
            title: 'about_heba_app'.tr,
            hasArrow: true,
            onTap: controller.showAboutApp,
            showDivider: true,
          ),

          // Invite Friends
          SettingsMenuItem(
            title: 'invite_friends'.tr,
            hasArrow: true,
            onTap: controller.inviteFriends,
            showDivider: true,
          ),

          // Privacy Policy - includes account deletion instructions
          SettingsMenuItem(
            title: 'delete_account'.tr,
            hasArrow: true,
            onTap: controller.openAccountDeletion,
            showDivider: true,
            textColor: const Color(0xFFEB5757),
          ),

          SettingsMenuItem(
            title: 'privacy'.tr,
            hasArrow: true,
            onTap: controller.openPrivacyPolicy,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  /// بناء زر تبديل الملف الشخصي (عميل ↔ تاجر)
  Widget _buildProfileSwitchItem() {
    try {
      if (!Get.isRegistered<ProfileSwitchService>()) {
        return const SizedBox.shrink();
      }

      final profileSwitch = Get.find<ProfileSwitchService>();

      return Obx(() {
        final status = profileSwitch.accountStatus.value;

        // Still loading or no status yet
        if (status == null) {
          // Trigger a fetch if not already loading
          if (!profileSwitch.isLoadingStatus.value) {
            profileSwitch.fetchAccountStatus();
          }
          return const SizedBox.shrink();
        }

        // If user already has a merchant profile, show "Switch" button
        if (status.canSwitchToMerchant) {
          final targetLabel = status.isMerchantMode
              ? 'switch_to_customer'.tr
              : 'switch_to_merchant'.tr;

          return SettingsMenuItem(
            title: targetLabel,
            hasArrow: true,
            onTap: profileSwitch.isSwitching.value ? null : () => _handleSwitch(profileSwitch),
            showDivider: true,
            isLoading: profileSwitch.isSwitching.value,
            textColor: const Color(0xFF27AE60),
          );
        }

        // If no merchant profile, show "Become a Merchant"
        if (status.canActivateMerchant && status.isCustomerMode) {
          return SettingsMenuItem(
            title: 'become_merchant'.tr,
            hasArrow: true,
            onTap: profileSwitch.isSwitching.value ? null : () => _handleActivateMerchant(profileSwitch),
            showDivider: true,
            isLoading: profileSwitch.isSwitching.value,
            textColor: const Color(0xFFF2994A),
          );
        }

        return const SizedBox.shrink();
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  /// Handle switch role action
  Future<void> _handleSwitch(ProfileSwitchService profileSwitch) async {
    final success = await profileSwitch.switchRole();
    if (success) {
      ToastService.showSuccess('profile_switch_success'.tr);
      // Navigate to the appropriate home
      if (profileSwitch.isMerchantMode) {
        Get.offAllNamed('/merchant-home');
      } else {
        Get.offAllNamed('/home');
      }
    } else {
      ToastService.showError('profile_switch_failed'.tr);
    }
  }

  /// Handle activate merchant action
  Future<void> _handleActivateMerchant(ProfileSwitchService profileSwitch) async {
    final success = await profileSwitch.activateMerchant();
    if (success) {
      ToastService.showSuccess('merchant_activated'.tr);
      // Switch to merchant mode and navigate to merchant onboarding
      final switched = await profileSwitch.switchRole();
      if (switched) {
        Get.offAllNamed('/merchant-home');
      }
    } else {
      ToastService.showError('merchant_activation_failed'.tr);
    }
  }

  /// بناء خيار "تقييماتي" - يظهر فقط للعملاء (Customers)
  Widget _buildMyReviewsItem() {
    try {
      final authService = Get.find<AuthService>();
      final user = authService.currentUser.value;

      // إخفاء "تقييماتي" من التجار - تظهر فقط للعملاء
      if (user == null || user.isMerchant) {
        return const SizedBox.shrink();
      }

      return SettingsMenuItem(
        title: 'my_reviews'.tr,
        hasArrow: true,
        onTap: controller.navigateToMyReviews,
        showDivider: true,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  /// بناء خيار تفعيل البصمة - يظهر فقط إذا كان الجهاز يدعمها
  Widget _buildBiometricToggle() {
    try {
      final biometricService = Get.find<BiometricService>();

      return Obx(() {
        // لا تظهر الخيار إذا الجهاز لا يدعم البصمة
        if (!biometricService.isBiometricAvailable.value) {
          return const SizedBox.shrink();
        }

        return SettingsMenuItem(
          title: 'biometric_login'.tr,
          hasToggle: true,
          toggleValue: biometricService.isBiometricEnabled.value,
          onToggleChanged: (value) => _handleBiometricToggle(value, biometricService),
          showDivider: true,
          isLoading: biometricService.isLoading.value,
        );
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  /// معالجة تغيير حالة البصمة
  Future<void> _handleBiometricToggle(bool value, BiometricService biometricService) async {
    if (value) {
      // تفعيل البصمة - نحتاج التوكن الحالي من AuthService
      try {
        final authService = Get.find<AuthService>();
        final token = await authService.getToken();
        final user = authService.currentUser.value;
        final userType = authService.userType.value;

        if (token == null || user == null || userType.isEmpty) {
          ToastService.showError('biometric_login_manually'.tr);
          return;
        }

        final success = await biometricService.enableBiometricLogin(
          token: token,
          userType: userType,
          userId: user.id.toString(),
          phoneNumber: user.phoneNumber ?? '',
        );

        if (success) {
          ToastService.showSuccess('biometric_enable_success'.tr);
        } else {
          ToastService.showError('biometric_auth_failed'.tr);
        }
      } catch (e) {
        ToastService.showError('biometric_login_manually'.tr);
      }
    } else {
      // إلغاء تفعيل البصمة
      await biometricService.disableBiometricLogin();
      ToastService.showWarning('biometric_disable_success'.tr);
    }
  }
}
