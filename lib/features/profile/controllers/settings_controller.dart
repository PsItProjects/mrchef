import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/settings_model.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/profile/services/profile_service.dart';

class SettingsController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();
  final LanguageService _languageService = Get.find<LanguageService>();

  // Settings data
  final Rx<SettingsModel> settings = SettingsModel(
    isDarkMode: false,
    currency: 'KWD',
    language: 'ar',
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

  void changeLanguage() {
    // Show language selection dialog
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Select Language',
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
            _buildLanguageOption('ar', 'العربية', '🇸🇦'),
            _buildLanguageOption('en', 'English', '🇺🇸'),
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

  Widget _buildLanguageOption(String code, String name, String flag) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFF262626),
        ),
      ),
      trailing: settings.value.language == code
        ? const Icon(Icons.check, color: Color(0xFF27AE60))
        : null,
      onTap: () {
        _updateLanguage(code);
        Get.back();
      },
    );
  }

  /// Update language preference
  Future<void> _updateLanguage(String languageCode) async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Update language in backend
      final result = await _profileService.updateLanguage(languageCode);

      // Close loading dialog
      Get.back();

      if (result['success'] == true) {
        // Update local settings
        settings.value = settings.value.copyWith(language: languageCode);
        _saveSettings();

        // Update language service
        await _languageService.setLanguage(languageCode);

        // Update GetX locale
        final locale = languageCode == 'ar'
          ? const Locale('ar', 'SA')
          : const Locale('en', 'US');
        Get.updateLocale(locale);

        Get.snackbar(
          languageCode == 'ar' ? 'تم تحديث اللغة' : 'Language Updated',
          languageCode == 'ar'
            ? 'تم تحديث اللغة بنجاح'
            : 'Language updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF27AE60),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to update language',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEB5757),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Network error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEB5757),
        colorText: Colors.white,
      );
    }
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
  String get language => settings.value.language;
  String get languageDisplayName => settings.value.language == 'ar' ? 'العربية' : 'English';
  String get cacheSize => settings.value.cacheSize;
}
