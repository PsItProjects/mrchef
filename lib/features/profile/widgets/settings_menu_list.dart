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
            title: 'Dark Mode',
            hasToggle: true,
            toggleValue: controller.isDarkMode,
            onToggleChanged: controller.toggleDarkMode,
            showDivider: true,
          )),
          
          // Currency
          Obx(() => SettingsMenuItem(
            title: 'Currency',
            subtitle: controller.currency,
            onTap: controller.changeCurrency,
            showDivider: true,
          )),
          
          // Notification
          SettingsMenuItem(
            title: 'Notification',
            hasArrow: true,
            onTap: controller.openNotificationSettings,
            showDivider: true,
          ),
          
          // Security
          SettingsMenuItem(
            title: 'Security',
            hasArrow: true,
            onTap: controller.openSecuritySettings,
            showDivider: true,
          ),
          
          // Clear app cache
          Obx(() => SettingsMenuItem(
            title: 'Clear app cache',
            subtitle: controller.cacheSize,
            onTap: controller.clearAppCache,
            showDivider: true,
          )),
          
          // Rate the app
          SettingsMenuItem(
            title: 'Rate the app',
            hasArrow: true,
            onTap: controller.rateTheApp,
            showDivider: true,
          ),
          
          // About Heba App
          SettingsMenuItem(
            title: 'About Heba App',
            hasArrow: true,
            onTap: controller.showAboutApp,
            showDivider: true,
          ),
          
          // Invite Friends
          SettingsMenuItem(
            title: 'Invite Friends',
            hasArrow: true,
            onTap: controller.inviteFriends,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
