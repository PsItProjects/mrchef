import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class MerchantLanguageService extends GetxService {
  static MerchantLanguageService get instance => Get.find<MerchantLanguageService>();
  
  final ApiClient _apiClient = ApiClient.instance;
  final LanguageService _languageService = LanguageService.instance;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    // Listen to language changes and sync with backend
    ever(_languageService.currentLanguageRx, (String language) {
      _syncLanguageWithBackend(language);
    });
  }
  
  /// Change language and sync with backend
  Future<void> changeLanguage(String languageCode) async {
    try {
      // First update locally
      await _languageService.setLanguage(languageCode);
      Get.updateLocale(Locale(languageCode));
      
      // Then sync with backend
      await _syncLanguageWithBackend(languageCode);
      
      // Show success message
      ToastService.showSuccess(
        languageCode == 'ar' 
            ? 'تم تغيير اللغة إلى العربية'
            : 'Language changed to English',
      );
      
    } catch (e) {
      print('Error changing language: $e');
      // Show error message
      ToastService.showError('Failed to change language');
    }
  }
  
  /// Sync language preference with backend
  Future<void> _syncLanguageWithBackend(String languageCode) async {
    try {
      // Check if user is authenticated
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        print('🌐 MERCHANT: No auth token, skipping backend sync');
        return;
      }
      
      print('🌐 MERCHANT: Syncing language $languageCode with backend...');
      
      // For merchants, we use the merchant profile endpoint
      final response = await _apiClient.put(
        '${ApiConstants.baseUrl}/merchant/profile/language',
        data: {
          'preferred_language': languageCode,
        },
      );
      
      if (response.statusCode == 200) {
        print('🌐 MERCHANT: Language synced successfully with backend');
        
        // Update user data in storage
        final userData = prefs.getString('user_data');
        if (userData != null) {
          try {
            final userMap = jsonDecode(userData) as Map<String, dynamic>;
            userMap['preferred_language'] = languageCode;
            await prefs.setString('user_data', jsonEncode(userMap));
            print('🌐 MERCHANT: Updated user data with new language');
          } catch (e) {
            print('Error updating user data: $e');
          }
        }
      } else {
        print('🌐 MERCHANT: Failed to sync language with backend: ${response.statusCode}');
      }
      
    } catch (e) {
      print('🌐 MERCHANT: Error syncing language with backend: $e');
      // Don't throw error, just log it - local language change should still work
    }
  }
  
  /// Load language preference from backend
  Future<void> loadLanguageFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        print('🌐 MERCHANT: No auth token, using local language');
        return;
      }
      
      print('🌐 MERCHANT: Loading language preference from backend...');
      
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/merchant/profile',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final preferredLanguage = data['data']?['preferred_language'] as String?;
        
        if (preferredLanguage != null && (preferredLanguage == 'ar' || preferredLanguage == 'en')) {
          print('🌐 MERCHANT: Loaded language from backend: $preferredLanguage');
          await _languageService.setLanguage(preferredLanguage);
          Get.updateLocale(Locale(preferredLanguage));
        }
      }
      
    } catch (e) {
      print('🌐 MERCHANT: Error loading language from backend: $e');
      // Don't throw error, use local language as fallback
    }
  }
  
  /// Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final currentLanguage = _languageService.currentLanguage;
    final newLanguage = currentLanguage == 'ar' ? 'en' : 'ar';
    await changeLanguage(newLanguage);
  }
  
  /// Get current language
  String get currentLanguage => _languageService.currentLanguage;
  
  /// Check if current language is Arabic
  bool get isArabic => _languageService.isArabic;
  
  /// Check if current language is English
  bool get isEnglish => _languageService.isEnglish;
}
