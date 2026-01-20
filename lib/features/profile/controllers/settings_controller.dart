import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/settings_model.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/profile/services/profile_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/profile/widgets/about_app_bottom_sheet.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/profile/pages/privacy_policy_screen.dart';
import '../../../core/services/toast_service.dart';

class SettingsController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();
  final LanguageService _languageService = Get.find<LanguageService>();
  final ApiClient _apiClient = ApiClient.instance;

  // Settings data
  final Rx<SettingsModel> settings = SettingsModel(
    isDarkMode: false,
    currency: 'KWD',
    language: 'ar',
    notificationsEnabled: true,
    cacheSize: '7.65 MB',
    appVersion: '1.0.0',
  ).obs;

  // Loading states
  final RxBool isChangingLanguage = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadUserProfile();
  }

  void _loadSettings() {
    // TODO: Load settings from local storage
    // For now using default values
  }

  /// Load user profile to get current language
  Future<void> _loadUserProfile() async {
    try {
      final result = await _profileService.getUserProfile();

      if (result['success'] == true && result['data'] != null) {
        final userData = result['data'] as Map<String, dynamic>;
        final userLanguage = userData['preferred_language'] as String?;

        if (userLanguage != null) {
          // Update settings with user's language from backend
          settings.value = settings.value.copyWith(language: userLanguage);

          // Update language service if different
          if (_languageService.currentLanguage != userLanguage) {
            await _languageService.setLanguage(userLanguage);
          }

          // Force UI update
          settings.refresh();
          update();

          print('🌐 User language loaded from profile: $userLanguage');
        }
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
  }

  // Settings actions
  void toggleDarkMode(bool value) {
    settings.value = settings.value.copyWith(isDarkMode: value);
    _saveSettings();
    
    ToastService.showInfo(value ? 'Dark mode enabled' : 'Dark mode disabled');
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

  void navigateToSupport() {
    Get.toNamed('/support/tickets');
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

        ToastService.showSuccess('Currency changed to $code');
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
      onTap: isChangingLanguage.value ? null : () {
        _updateLanguage(code);
        Get.back();
      },
    );
  }

  /// Update language preference
  Future<void> _updateLanguage(String languageCode) async {
    // Set loading state
    isChangingLanguage.value = true;

    try {
      // Update language in backend
      final result = await _profileService.updateLanguage(languageCode);

      if (result['success'] == true) {
        // Update local settings
        settings.value = settings.value.copyWith(language: languageCode);
        _saveSettings();

        // Update language service
        await _languageService.setLanguage(languageCode);

        // Clear all cached data
        await _apiClient.clearCache();

        // Update GetX locale
        final locale = languageCode == 'ar'
          ? const Locale('ar', 'SA')
          : const Locale('en', 'US');
        Get.updateLocale(locale);

        // Force reload all controllers
        _reloadAllControllers();

        ToastService.showSuccess(
          languageCode == 'ar'
            ? 'تم تحديث اللغة بنجاح'
            : 'Language updated successfully'
        );
      } else {
        ToastService.showError(result['message'] ?? 'Failed to update language');
      }
    } catch (e) {
      ToastService.showError('Network error occurred');
    } finally {
      // Reset loading state
      isChangingLanguage.value = false;
    }
  }

  /// Force reload all controllers to refresh data with new language
  void _reloadAllControllers() {
    try {
      // Reload Home Controller
      if (Get.isRegistered<dynamic>(tag: 'HomeController')) {
        final homeController = Get.find(tag: 'HomeController');
        if (homeController.hasListeners) {
          homeController.onInit();
        }
      }

      // Reload Categories Controller
      if (Get.isRegistered<dynamic>(tag: 'CategoriesController')) {
        final categoriesController = Get.find(tag: 'CategoriesController');
        if (categoriesController.hasListeners) {
          categoriesController.onInit();
        }
      }

      print('🔄 All controllers reloaded for language change');
    } catch (e) {
      print('❌ Error reloading controllers: $e');
    }
  }

  void openNotificationSettings() {
    ToastService.showInfo('Opening notification settings...');
    // TODO: Navigate to notification settings screen
  }

  void openSecuritySettings() {
    ToastService.showInfo('Opening security settings...');
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
    
    ToastService.showSuccess('App cache has been cleared successfully');
    
    // Reset cache size after a delay (simulation)
    Future.delayed(const Duration(seconds: 3), () {
      settings.value = settings.value.copyWith(cacheSize: '2.15 MB');
    });
  }

  void rateTheApp() {
    ToastService.showInfo('Opening app store for rating...');
    // TODO: Open app store for rating
  }

  void showAboutApp() {
    AboutAppBottomSheet.show();
  }

  void inviteFriends() {
    ToastService.showInfo('Opening share dialog...');
    // TODO: Open share dialog
  }

  void navigateToPaymentMethods() {
    ToastService.showInfo('Opening payment methods...');
    // TODO: Navigate to payment methods screen
  }

  void navigateToConversations() {
    Get.toNamed('/conversations');
  }

  void navigateToMyReviews() {
    Get.toNamed(AppRoutes.MY_REVIEWS);
  }

  void _saveSettings() {
    // TODO: Save settings to local storage
  }

  /// Open Privacy Policy page in WebView
  /// Account deletion is handled through the website: https://mr-shife.com/complaints
  void openPrivacyPolicy() {
    Get.to(() => const PrivacyPolicyScreen());
  }

  // Getters for UI
  bool get isDarkMode => settings.value.isDarkMode;
  String get currency => settings.value.currency;
  String get language => settings.value.language;
  String get languageDisplayName => settings.value.language == 'ar' ? 'العربية' : 'English';
  String get cacheSize => settings.value.cacheSize;
}
