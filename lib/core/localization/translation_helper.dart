import 'package:mrsheaf/core/services/language_service.dart';

class TranslationHelper {
  static final LanguageService _languageService = LanguageService.instance;

  // English translations
  static const Map<String, String> _englishTranslations = {
    'welcome': 'Welcome',
    'phone': 'Phone',
    'enter_phone': 'Enter your phone number',
    'login': 'Login',
    'dont_have_account': 'Don\'t have an account?',
    'sign_up': 'Sign Up',
    'get_started': 'Get Started',
    'customer': 'Customer',
    'vendor': 'Vendor',
    'already_have_account': 'Already have an account?',
    'continue': 'Continue',
    'home': 'Home',
    'search_food': 'Search for food...',
    'categories': 'Categories',
    'cart': 'Cart',
    'favorites': 'Favorites',
    'profile': 'Profile',
    'my_orders': 'My Orders',
    'shipping_addresses': 'Shipping Addresses',
    'payment_methods': 'Payment Methods',
    'my_reviews': 'My Reviews',
    'cart_empty': 'Your cart is empty',
    'add_items_to_cart': 'Add items to your cart',
    'continue_shopping': 'Continue Shopping',
    'subtotal': 'Subtotal',
    'delivery_fee': 'Delivery Fee',
    'tax': 'Tax',
    'total': 'Total',
    'checkout': 'Checkout',
    'meal_types': 'Meal Types',
    'search': 'Search',
    'feature_not_available': 'Feature not available',
    'language': 'Language',
    'cancel': 'Cancel',
    'see_all': 'See All',
    'best_seller': 'Best Seller',
    'recently': 'Recently',
    'featured_restaurants': 'Featured Restaurants',
    'nearby_restaurants': 'Nearby Restaurants',
    'popular_categories': 'Popular Categories',
    'top_picks': 'Top Picks',
    'special_offers': 'Special Offers',
    'item': 'Item',
    'promo_code': 'Promo Code',
  };

  // Arabic translations
  static const Map<String, String> _arabicTranslations = {
    'welcome': 'مرحباً',
    'phone': 'الهاتف',
    'enter_phone': 'أدخل رقم هاتفك',
    'login': 'تسجيل الدخول',
    'dont_have_account': 'ليس لديك حساب؟',
    'sign_up': 'إنشاء حساب',
    'get_started': 'ابدأ الآن',
    'customer': 'عميل',
    'vendor': 'بائع',
    'already_have_account': 'لديك حساب بالفعل؟',
    'continue': 'متابعة',
    'home': 'الرئيسية',
    'search_food': 'ابحث عن الطعام...',
    'categories': 'الفئات',
    'cart': 'السلة',
    'favorites': 'المفضلة',
    'profile': 'الملف الشخصي',
    'my_orders': 'طلباتي',
    'shipping_addresses': 'عناوين الشحن',
    'payment_methods': 'طرق الدفع',
    'my_reviews': 'تقييماتي',
    'cart_empty': 'سلتك فارغة',
    'add_items_to_cart': 'أضف عناصر إلى سلتك',
    'continue_shopping': 'متابعة التسوق',
    'subtotal': 'المجموع الفرعي',
    'delivery_fee': 'رسوم التوصيل',
    'tax': 'الضريبة',
    'total': 'المجموع',
    'checkout': 'الدفع',
    'meal_types': 'أنواع الوجبات',
    'search': 'بحث',
    'feature_not_available': 'الميزة غير متاحة',
    'language': 'اللغة',
    'cancel': 'إلغاء',
    'see_all': 'عرض الكل',
    'best_seller': 'الأكثر مبيعاً',
    'recently': 'مؤخراً',
    'featured_restaurants': 'المطاعم المميزة',
    'nearby_restaurants': 'المطاعم القريبة',
    'popular_categories': 'الفئات الشائعة',
    'top_picks': 'أفضل الاختيارات',
    'special_offers': 'العروض الخاصة',
    'item': 'عنصر',
    'promo_code': 'رمز الخصم',
  };

  /// Get translated text by key
  static String tr(String key, {Map<String, String>? args}) {
    final translations = {
      'en': _englishTranslations,
      'ar': _arabicTranslations,
    };

    final currentLang = _languageService.currentLanguage;
    final langTranslations = translations[currentLang] ?? translations['en']!;

    String translation = langTranslations[key] ?? key;

    // Replace arguments if provided
    if (args != null) {
      args.forEach((argKey, argValue) {
        translation = translation.replaceAll('@$argKey', argValue);
      });
    }

    return translation;
  }

  /// Get translated text with plural support
  static String trPlural(String key, int count, {Map<String, String>? args}) {
    // Simple plural implementation
    String pluralKey = count == 1 ? key : '${key}_plural';
    return tr(pluralKey, args: args);
  }

  /// Get translated text with fallback
  static String trWithFallback(String key, String fallback, {Map<String, String>? args}) {
    final translation = tr(key, args: args);
    return translation == key ? fallback : translation;
  }

  /// Get localized text from dynamic field (for API responses)
  static String getLocalizedText(dynamic field) {
    return _languageService.getLocalizedText(field);
  }

  /// Check if current language is RTL
  static bool get isRTL => _languageService.isArabic;

  /// Check if current language is LTR
  static bool get isLTR => !isRTL;

  /// Get current language code
  static String get currentLanguage => _languageService.currentLanguage;

  /// Check if current language is Arabic
  static bool get isArabic => _languageService.isArabic;

  /// Check if current language is English
  static bool get isEnglish => _languageService.isEnglish;

  /// Format currency with localization
  static String formatCurrency(double amount, {String? currency}) {
    final currencySymbol = currency ?? (isArabic ? 'ر.س' : 'SAR');
    final formattedAmount = amount.toStringAsFixed(2);
    
    if (isArabic) {
      return '$formattedAmount $currencySymbol';
    } else {
      return '$currencySymbol $formattedAmount';
    }
  }

  /// Format number with localization
  static String formatNumber(num number) {
    if (isArabic) {
      // Convert to Arabic numerals if needed
      return number.toString().replaceAllMapped(
        RegExp(r'[0-9]'),
        (match) => _getArabicNumeral(match.group(0)!),
      );
    }
    return number.toString();
  }

  /// Get Arabic numeral for English digit
  static String _getArabicNumeral(String digit) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final index = int.parse(digit);
    return arabicNumerals[index];
  }

  /// Format date with localization
  static String formatDate(DateTime date) {
    if (isArabic) {
      // Arabic date format
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } else {
      // English date format
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  /// Format time with localization
  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    
    if (isArabic) {
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final period = hour < 12 ? 'ص' : 'م';
      return '$hour12:$minute $period';
    } else {
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final period = hour < 12 ? 'AM' : 'PM';
      return '$hour12:$minute $period';
    }
  }

  /// Get greeting based on time and language
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return tr('good_morning');
    } else if (hour < 17) {
      return tr('good_afternoon');
    } else {
      return tr('good_evening');
    }
  }

  /// Get relative time (time ago)
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return isArabic 
          ? 'منذ ${formatNumber(years)} ${years == 1 ? 'سنة' : 'سنوات'}'
          : '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return isArabic 
          ? 'منذ ${formatNumber(months)} ${months == 1 ? 'شهر' : 'أشهر'}'
          : '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return isArabic 
          ? 'منذ ${formatNumber(difference.inDays)} ${difference.inDays == 1 ? 'يوم' : 'أيام'}'
          : '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return isArabic 
          ? 'منذ ${formatNumber(difference.inHours)} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}'
          : '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return isArabic 
          ? 'منذ ${formatNumber(difference.inMinutes)} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}'
          : '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return tr('now');
    }
  }

  /// Get order status text
  static String getOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return tr('pending');
      case 'confirmed':
        return tr('order_confirmed');
      case 'preparing':
        return tr('preparing');
      case 'ready':
        return tr('ready_for_pickup');
      case 'out_for_delivery':
        return tr('out_for_delivery');
      case 'delivered':
        return tr('delivered');
      case 'cancelled':
        return tr('cancelled');
      default:
        return status;
    }
  }

  /// Get payment status text
  static String getPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return tr('payment_pending');
      case 'successful':
      case 'completed':
        return tr('payment_successful');
      case 'failed':
        return tr('payment_failed');
      case 'refunded':
        return tr('refunded');
      default:
        return status;
    }
  }

  /// Get rating text
  static String getRatingText(double rating) {
    if (rating >= 4.5) {
      return tr('excellent');
    } else if (rating >= 4.0) {
      return tr('very_good');
    } else if (rating >= 3.5) {
      return tr('good');
    } else if (rating >= 3.0) {
      return tr('average');
    } else if (rating >= 2.0) {
      return tr('below_average');
    } else {
      return tr('poor');
    }
  }

  /// Get delivery time text
  static String getDeliveryTime(int minutes) {
    if (minutes < 60) {
      return isArabic 
          ? '${formatNumber(minutes)} دقيقة'
          : '$minutes min${minutes == 1 ? '' : 's'}';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      
      if (remainingMinutes == 0) {
        return isArabic 
            ? '${formatNumber(hours)} ${hours == 1 ? 'ساعة' : 'ساعات'}'
            : '$hours hour${hours == 1 ? '' : 's'}';
      } else {
        return isArabic 
            ? '${formatNumber(hours)} ${hours == 1 ? 'ساعة' : 'ساعات'} و ${formatNumber(remainingMinutes)} دقيقة'
            : '$hours hour${hours == 1 ? '' : 's'} $remainingMinutes min${remainingMinutes == 1 ? '' : 's'}';
      }
    }
  }

  /// Get distance text
  static String getDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return isArabic 
          ? '${formatNumber(meters)} متر'
          : '$meters m';
    } else {
      return isArabic 
          ? '${distanceInKm.toStringAsFixed(1)} كم'
          : '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Get quantity text with proper pluralization
  static String getQuantityText(int quantity, String itemName) {
    if (isArabic) {
      if (quantity == 1) {
        return '$itemName واحد';
      } else if (quantity == 2) {
        return '$itemName اثنان';
      } else if (quantity <= 10) {
        return '${formatNumber(quantity)} $itemName';
      } else {
        return '${formatNumber(quantity)} $itemName';
      }
    } else {
      return '$quantity $itemName${quantity == 1 ? '' : 's'}';
    }
  }

  /// Get price range text
  static String getPriceRange(double minPrice, double maxPrice) {
    final min = formatCurrency(minPrice);
    final max = formatCurrency(maxPrice);
    
    return isArabic 
        ? '$min - $max'
        : '$min - $max';
  }

  /// Get error message for validation
  static String getValidationError(String field, String error) {
    switch (error) {
      case 'required':
        return tr('required_field');
      case 'invalid_email':
        return tr('invalid_email');
      case 'weak_password':
        return tr('weak_password');
      case 'passwords_dont_match':
        return tr('passwords_dont_match');
      case 'invalid_phone':
        return tr('invalid_format');
      case 'too_short':
        return tr('too_short');
      case 'too_long':
        return tr('too_long');
      default:
        return error;
    }
  }
}

// Extension for easy translation access
extension StringTranslationHelper on String {
  String get tr => TranslationHelper.tr(this);
  String trArgs(Map<String, String> args) => TranslationHelper.tr(this, args: args);
  String trPlural(int count) => TranslationHelper.trPlural(this, count);
}
