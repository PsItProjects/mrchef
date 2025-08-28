import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends GetxService {
  static LanguageService get instance => Get.find<LanguageService>();
  
  final RxString _currentLanguage = 'en'.obs;
  
  String get currentLanguage => _currentLanguage.value;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLanguageFromStorage();
  }
  
  /// Load saved language from storage
  Future<void> _loadLanguageFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('user_language') ?? 'en';
      _currentLanguage.value = savedLanguage;
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
    } catch (e) {
      print('Error saving language: $e');
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
  Future<void> updateLanguageFromUserProfile(Map<String, dynamic> userData) async {
    try {
      final userLanguage = userData['preferred_language'] as String?;
      if (userLanguage != null && (userLanguage == 'en' || userLanguage == 'ar')) {
        print('🌐 Updating language from user profile: $userLanguage');
        await setLanguage(userLanguage);
      }
    } catch (e) {
      print('Error updating language from user profile: $e');
    }
  }
}
