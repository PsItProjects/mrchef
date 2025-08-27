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

  CustomerRegistrationRequest({
    required this.nameEn,
    this.nameAr,
    required this.phoneNumber,
    this.countryCode = '+966',
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name_en': nameEn,
      'name_ar': nameAr,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'email': email,
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

  MerchantRegistrationRequest({
    required this.englishFullName,
    required this.arabicFullName,
    required this.phoneNumber,
    this.countryCode = '+966',
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'english_full_name': englishFullName,
      'arabic_full_name': arabicFullName,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'email': email,
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
    final data = {
      'phone_number': phoneNumber,
      'otp_code': otpCode,
      'country_code': countryCode,
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
