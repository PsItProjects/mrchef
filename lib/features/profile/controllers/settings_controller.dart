import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/settings_model.dart';

class SettingsController extends GetxController {
  // Settings data
  final Rx<SettingsModel> settings = SettingsModel(
    isDarkMode: false,
    currency: 'KWD',
    notificationsEnabled: true,
    cacheSize: '7.65 MB',
    appVersion: '1.0.0',
  ).obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // TODO: Load settings from local storage
    // For now using default values
  }

  // Settings actions
  void toggleDarkMode(bool value) {
    settings.value = settings.value.copyWith(isDarkMode: value);
    _saveSettings();
    
    Get.snackbar(
      'Dark Mode',
      value ? 'Dark mode enabled' : 'Dark mode disabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void changeCurrency() {
    // Show currency selection dialog
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Select Currency',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('KWD', 'Kuwaiti Dinar'),
            _buildCurrencyOption('USD', 'US Dollar'),
            _buildCurrencyOption('EUR', 'Euro'),
            _buildCurrencyOption('SAR', 'Saudi Riyal'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name) {
    return ListTile(
      title: Text(
        '$code - $name',
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFF262626),
        ),
      ),
      onTap: () {
        settings.value = settings.value.copyWith(currency: code);
        _saveSettings();
        Get.back();
        
        Get.snackbar(
          'Currency Changed',
          'Currency changed to $code',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void openNotificationSettings() {
    Get.snackbar(
      'Notification Settings',
      'Opening notification settings...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to notification settings screen
  }

  void openSecuritySettings() {
    Get.snackbar(
      'Security Settings',
      'Opening security settings...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to security settings screen
  }

  void clearAppCache() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Clear Cache',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        content: Text(
          'Are you sure you want to clear ${settings.value.cacheSize} of app cache?',
          style: const TextStyle(
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
              _performClearCache();
            },
            child: const Text(
              'Clear',
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

  void _performClearCache() {
    // Simulate cache clearing
    settings.value = settings.value.copyWith(cacheSize: '0.00 MB');
    
    Get.snackbar(
      'Cache Cleared',
      'App cache has been cleared successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
    
    // Reset cache size after a delay (simulation)
    Future.delayed(const Duration(seconds: 3), () {
      settings.value = settings.value.copyWith(cacheSize: '2.15 MB');
    });
  }

  void rateTheApp() {
    Get.snackbar(
      'Rate the App',
      'Opening app store for rating...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Open app store for rating
  }

  void showAboutApp() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'About MrSheaf App',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF262626),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: ${settings.value.appVersion}',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF5E5E5E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'MrSheaf is your go-to food delivery app for delicious meals from your favorite restaurants.',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF5E5E5E),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF262626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void inviteFriends() {
    Get.snackbar(
      'Invite Friends',
      'Opening share dialog...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Open share dialog
  }

  void navigateToPaymentMethods() {
    Get.snackbar(
      'Payment Methods',
      'Opening payment methods...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to payment methods screen
  }

  void _saveSettings() {
    // TODO: Save settings to local storage
  }

  // Getters for UI
  bool get isDarkMode => settings.value.isDarkMode;
  String get currency => settings.value.currency;
  String get cacheSize => settings.value.cacheSize;
}
