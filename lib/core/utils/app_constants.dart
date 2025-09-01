class AppConstants {
  // App Information
  static const String appName = 'MrSheaf';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Design Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultMargin = 16.0;
  static const double smallMargin = 8.0;
  static const double largeMargin = 24.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 32.0;
  
  static const double defaultElevation = 2.0;
  static const double smallElevation = 1.0;
  static const double largeElevation = 4.0;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration extraSlowAnimation = Duration(milliseconds: 800);
  
  // Screen Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Form Constants
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  static const int maxPasswordLength = 128;
  static const int minPasswordLength = 8;
  static const int maxPhoneLength = 15;
  static const int maxAddressLength = 200;
  
  // Validation Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^[5][0-9]{8}$'; // Saudi phone pattern
  static const String namePattern = r'^[a-zA-Z\u0600-\u06FF\s]+$';
  
  // API Constants
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Storage Keys
  static const String userTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'user_language';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String cartKey = 'cart_items';
  static const String favoritesKey = 'favorite_items';
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultCurrency = 'SAR';
  static const String defaultCountryCode = '+966';
  
  // Image Constants
  static const double maxImageSizeMB = 5.0;
  static const int imageQuality = 85;
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1080;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Constants
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // Number of items
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String timeoutErrorMessage = 'Request timeout. Please try again.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String signupSuccessMessage = 'Account created successfully!';
  static const String updateSuccessMessage = 'Updated successfully!';
  static const String deleteSuccessMessage = 'Deleted successfully!';
  
  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Social Media URLs
  static const String facebookUrl = 'https://facebook.com/mrsheaf';
  static const String twitterUrl = 'https://twitter.com/mrsheaf';
  static const String instagramUrl = 'https://instagram.com/mrsheaf';
  static const String linkedinUrl = 'https://linkedin.com/company/mrsheaf';
  
  // Support URLs
  static const String supportEmail = 'support@mrsheaf.com';
  static const String supportPhone = '+966500000000';
  static const String privacyPolicyUrl = 'https://mrsheaf.com/privacy';
  static const String termsOfServiceUrl = 'https://mrsheaf.com/terms';
  static const String helpCenterUrl = 'https://help.mrsheaf.com';
  
  // App Store URLs
  static const String appStoreUrl = 'https://apps.apple.com/app/mrsheaf';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.mrsheaf.app';
  
  // Rating and Review
  static const int minRatingForReview = 4;
  static const int sessionsBeforeRatingPrompt = 5;
  
  // Location Constants
  static const double defaultLatitude = 24.7136;
  static const double defaultLongitude = 46.6753; // Riyadh coordinates
  static const double locationAccuracyThreshold = 100.0; // meters
  
  // Payment Constants
  static const List<String> supportedCurrencies = ['SAR', 'USD', 'EUR'];
  static const double minOrderAmount = 10.0;
  static const double maxOrderAmount = 10000.0;
  static const double deliveryFee = 15.0;
  static const double freeDeliveryThreshold = 100.0;
  
  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';
  
  // Notification Types
  static const String notificationTypeOrder = 'order';
  static const String notificationTypePromotion = 'promotion';
  static const String notificationTypeGeneral = 'general';
  static const String notificationTypeSystem = 'system';
  
  // File Types
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // Regular Expressions
  static RegExp get emailRegex => RegExp(emailPattern);
  static RegExp get phoneRegex => RegExp(phonePattern);
  static RegExp get nameRegex => RegExp(namePattern);
  
  // Helper Methods
  static bool isValidEmail(String email) => emailRegex.hasMatch(email);
  static bool isValidPhone(String phone) => phoneRegex.hasMatch(phone);
  static bool isValidName(String name) => nameRegex.hasMatch(name);
  
  static bool isMobile(double width) => width < mobileBreakpoint;
  static bool isTablet(double width) => width >= mobileBreakpoint && width < tabletBreakpoint;
  static bool isDesktop(double width) => width >= desktopBreakpoint;
  
  static String formatCurrency(double amount, [String currency = defaultCurrency]) {
    return '$amount $currency';
  }
  
  static String formatPhone(String phone, [String countryCode = defaultCountryCode]) {
    return '$countryCode$phone';
  }
}
