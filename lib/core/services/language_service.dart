import 'dart:convert';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mrsheaf/core/services/fcm_service.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';

class LanguageService extends GetxService {
  static LanguageService get instance => Get.find<LanguageService>();

  final RxString _currentLanguage = 'en'.obs;

  String get currentLanguage => _currentLanguage.value;
  RxString get currentLanguageRx => _currentLanguage;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLanguageFromStorage();
  }

  /// Load saved language from storage
  Future<void> _loadLanguageFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // First check if user is logged in and has language preference
      final userData = prefs.getString('user_data');
      if (userData != null) {
        try {
          final userMap = jsonDecode(userData) as Map<String, dynamic>;
          final userLanguage = userMap['language'] as String?;
          if (userLanguage != null &&
              (userLanguage == 'ar' || userLanguage == 'en')) {
            _currentLanguage.value = userLanguage;
            print('🌐 Language loaded from user profile: $userLanguage');
            return;
          }
        } catch (e) {
          print('Error parsing user data for language: $e');
        }
      }

      // Fallback to saved language preference
      final savedLanguage = prefs.getString('user_language') ?? 'en';
      _currentLanguage.value = savedLanguage;
      print('🌐 Language loaded from storage: $savedLanguage');
    } catch (e) {
      print('Error loading language: $e');
      _currentLanguage.value = 'en'; // Default to English
    }
  }

  /// Save language to storage
  Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_language', languageCode);
      _currentLanguage.value = languageCode;

      // Update GetX locale immediately
      final locale = languageCode == 'ar'
          ? const Locale('ar', 'SA')
          : const Locale('en', 'US');
      Get.updateLocale(locale);

      // Update device language on server for push notifications
      _updateDeviceLanguage(languageCode);
      
      // ✅ Update user's preferred language in backend
      _updateUserPreferredLanguage(languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  /// Update device language on server for push notifications
  void _updateDeviceLanguage(String languageCode) {
    try {
      if (Get.isRegistered<FCMService>()) {
        final fcmService = Get.find<FCMService>();
        fcmService.updateLanguage(languageCode);
      }
    } catch (e) {
      print('Error updating device language: $e');
    }
  }
  
  /// Update user's preferred language in backend
  Future<void> _updateUserPreferredLanguage(String languageCode) async {
    try {
      // Check if user is logged in
      if (!Get.isRegistered<AuthService>()) return;
      
      final authService = Get.find<AuthService>();
      if (!authService.isLoggedIn.value) return;
      
      print('🌐 LANGUAGE: Updating user preferred language to: $languageCode');
      
      // Import the request model dynamically
      final request = {
        'preferred_language': languageCode,
      };
      
      // Call API to update profile with new language
      if (Get.isRegistered<ApiClient>()) {
        final apiClient = Get.find<ApiClient>();
        await apiClient.put('/customer/profile', data: request);
        print('✅ LANGUAGE: User preferred language updated successfully');
      }
    } catch (e) {
      print('❌ LANGUAGE: Error updating user preferred language - $e');
      // Don't throw error, language still works locally
    }
  }

  /// Get localized text from translatable field
  String getLocalizedText(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field[currentLanguage] ??
          field['current'] ??
          field['en'] ??
          field['ar'] ??
          field.values.first ??
          '';
    }
    return field?.toString() ?? '';
  }

  /// Check if current language is Arabic
  bool get isArabic => currentLanguage == 'ar';

  /// Check if current language is English
  bool get isEnglish => currentLanguage == 'en';

  /// Update language from user profile data
  Future<void> updateLanguageFromUserProfile(
      Map<String, dynamic> userData) async {
    try {
      final userLanguage = userData['preferred_language'] as String?;
      if (userLanguage != null &&
          (userLanguage == 'en' || userLanguage == 'ar')) {
        print('🌐 Updating language from user profile: $userLanguage');
        await setLanguage(userLanguage);

        // Update GetX locale immediately
        final locale = userLanguage == 'ar'
            ? const Locale('ar', 'SA')
            : const Locale('en', 'US');
        Get.updateLocale(locale);
        print('🌐 Updated GetX locale to: $userLanguage');
      }
    } catch (e) {
      print('Error updating language from user profile: $e');
    }
  }
}
