import 'package:get/get.dart';
import '../services/language_service.dart';

class CurrencyHelper {
  static LanguageService get _languageService => Get.find<LanguageService>();

  /// Get currency symbol based on current language
  static String getCurrencySymbol() {
    final currentLanguage = _languageService.currentLanguage;

    switch (currentLanguage) {
      case 'ar':
        return 'ر.س';
      case 'en':
        return 'SAR';
      default:
        return 'SAR';
    }
  }

  /// Format price with currency symbol
  static String formatPrice(double price) {
    final symbol = getCurrencySymbol();
    final currentLanguage = _languageService.currentLanguage;

    if (currentLanguage == 'ar') {
      // Arabic: "45.00 ر.س"
      return '${price.toStringAsFixed(2)} $symbol';
    } else {
      // English: "SAR 45.00"
      return '$symbol ${price.toStringAsFixed(2)}';
    }
  }

  /// Format price with currency symbol (short version)
  static String formatPriceShort(double price) {
    final symbol = getCurrencySymbol();
    final currentLanguage = _languageService.currentLanguage;

    if (currentLanguage == 'ar') {
      // Arabic: "45 ر.س"
      return '${price.toStringAsFixed(0)} $symbol';
    } else {
      // English: "SAR 45"
      return '$symbol ${price.toStringAsFixed(0)}';
    }
  }

  /// Get currency name based on current language
  static String getCurrencyName() {
    final currentLanguage = _languageService.currentLanguage;

    switch (currentLanguage) {
      case 'ar':
        return 'ريال سعودي';
      case 'en':
        return 'Saudi Riyal';
      default:
        return 'Saudi Riyal';
    }
  }

  /// Get currency code
  static String getCurrencyCode() {
    return 'SAR';
  }
}
