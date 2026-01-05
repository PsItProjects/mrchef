import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/biometric_service.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
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

          // Conversations
          SettingsMenuItem(
            title: 'conversations'.tr,
            hasArrow: true,
            onTap: controller.navigateToConversations,
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
            showDivider: false,
          ),
        ],
      ),
    );
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
          Get.snackbar(
            TranslationHelper.tr('biometric_enable_failed'),
            TranslationHelper.tr('biometric_login_manually'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
          );
          return;
        }
        
        final success = await biometricService.enableBiometricLogin(
          token: token,
          userType: userType,
          userId: user.id.toString(),
          phoneNumber: user.phoneNumber ?? '',
        );
        
        if (success) {
          Get.snackbar(
            TranslationHelper.tr('success'),
            TranslationHelper.tr('biometric_enable_success'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.3),
          );
        } else {
          Get.snackbar(
            TranslationHelper.tr('biometric_enable_failed'),
            TranslationHelper.tr('biometric_auth_failed'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
          );
        }
      } catch (e) {
        Get.snackbar(
          TranslationHelper.tr('biometric_enable_failed'),
          TranslationHelper.tr('biometric_login_manually'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
      }
    } else {
      // إلغاء تفعيل البصمة
      await biometricService.disableBiometricLogin();
      Get.snackbar(
        TranslationHelper.tr('success'),
        TranslationHelper.tr('biometric_disable_success'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.3),
      );
    }
  }
}
