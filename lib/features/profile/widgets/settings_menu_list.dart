import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
}
