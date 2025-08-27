// Login request model
class LoginRequest {
  final String phoneNumber;
  final String countryCode;

  LoginRequest({
    required this.phoneNumber,
    this.countryCode = '+966',
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'country_code': countryCode,
    };
  }
}

// Customer registration request model
class CustomerRegistrationRequest {
  final String nameEn;
  final String? nameAr;
  final String phoneNumber;
  final String countryCode;
  final String? email;
  final bool agreeToTerms;

  CustomerRegistrationRequest({
    required this.nameEn,
    this.nameAr,
    required this.phoneNumber,
    this.countryCode = '+966',
    this.email,
    this.agreeToTerms = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name_en': nameEn,
      'name_ar': nameAr,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'email': email,
      'agree_to_terms': agreeToTerms,
    };
  }
}

// Merchant registration request model
class MerchantRegistrationRequest {
  final String englishFullName;
  final String arabicFullName;
  final String phoneNumber;
  final String countryCode;
  final String email;
  final bool agreeToTerms;

  MerchantRegistrationRequest({
    required this.englishFullName,
    required this.arabicFullName,
    required this.phoneNumber,
    this.countryCode = '+966',
    required this.email,
    this.agreeToTerms = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'english_full_name': englishFullName,
      'arabic_full_name': arabicFullName,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'email': email,
      'agree_to_terms': agreeToTerms,
    };
  }
}

// OTP verification request model
class OTPVerificationRequest {
  final String phoneNumber;
  final String otpCode;
  final String countryCode;
  final String? userType; // 'customer' or 'merchant'

  OTPVerificationRequest({
    required this.phoneNumber,
    required this.otpCode,
    this.countryCode = '+966',
    this.userType,
  });

  Map<String, dynamic> toJson() {
    // Normalize OTP to digits only
    final cleaned = otpCode.replaceAll(RegExp(r'[^0-9]'), '');

    final data = <String, dynamic>{
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'otp': cleaned, // unified key for all cases
    };

    if (userType != null) {
      data['user_type'] = userType!;
    }

    return data;
  }
}

// Resend OTP request model
class ResendOTPRequest {
  final String phoneNumber;
  final String countryCode;
  final String? userType;

  ResendOTPRequest({
    required this.phoneNumber,
    this.countryCode = '+966',
    this.userType,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'phone_number': phoneNumber,
      'country_code': countryCode,
    };
    
    if (userType != null) {
      data['user_type'] = userType!;
    }
    
    return data;
  }
}

// Customer profile update request model
class CustomerProfileUpdateRequest {
  final String? nameEn;
  final String? nameAr;
  final String? email;
  final String? preferredLanguage;
  final String? dateOfBirth;
  final String? gender;
  final bool? notificationsEnabled;
  final bool? smsNotifications;
  final bool? emailNotifications;

  CustomerProfileUpdateRequest({
    this.nameEn,
    this.nameAr,
    this.email,
    this.preferredLanguage,
    this.dateOfBirth,
    this.gender,
    this.notificationsEnabled,
    this.smsNotifications,
    this.emailNotifications,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (nameEn != null) data['name_en'] = nameEn;
    if (nameAr != null) data['name_ar'] = nameAr;
    if (email != null) data['email'] = email;
    if (preferredLanguage != null) data['preferred_language'] = preferredLanguage;
    if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;
    if (gender != null) data['gender'] = gender;
    if (notificationsEnabled != null) data['notifications_enabled'] = notificationsEnabled;
    if (smsNotifications != null) data['sms_notifications'] = smsNotifications;
    if (emailNotifications != null) data['email_notifications'] = emailNotifications;

    return data;
  }
}
