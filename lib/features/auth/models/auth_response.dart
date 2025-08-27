import 'user_model.dart';

// Login response model
class LoginResponse {
  final UserModel user;
  final String token;
  final String? userType;
  final String? nextStep;

  LoginResponse({
    required this.user,
    required this.token,
    this.userType,
    this.nextStep,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserModel.fromJson(json['user'] ?? json['customer'] ?? json['merchant']),
      token: json['token'] ?? '',
      userType: json['user_type'],
      nextStep: json['next_step'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'user_type': userType,
      'next_step': nextStep,
    };
  }
}

// Registration response model
class RegistrationResponse {
  final UserModel user;
  final String? verificationCode; // Only for development
  final String? expiresAt;
  final String nextStep;

  RegistrationResponse({
    required this.user,
    this.verificationCode,
    this.expiresAt,
    required this.nextStep,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      user: UserModel.fromJson(json['customer'] ?? json['merchant'] ?? json['user']),
      verificationCode: json['verification_code'],
      expiresAt: json['expires_at'],
      nextStep: json['next_step'] ?? 'otp_verification',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'verification_code': verificationCode,
      'expires_at': expiresAt,
      'next_step': nextStep,
    };
  }
}

// OTP verification response model
class OTPVerificationResponse {
  final UserModel user;
  final String token;
  final String? userType;
  final String? nextStep;

  OTPVerificationResponse({
    required this.user,
    required this.token,
    this.userType,
    this.nextStep,
  });

  factory OTPVerificationResponse.fromJson(Map<String, dynamic> json) {
    return OTPVerificationResponse(
      user: UserModel.fromJson(json['user'] ?? json['customer'] ?? json['merchant']),
      token: json['token'] ?? '',
      userType: json['user_type'],
      nextStep: json['next_step'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'user_type': userType,
      'next_step': nextStep,
    };
  }
}

// Send OTP response model
class SendOTPResponse {
  final String? verificationCode; // Only for development
  final String? expiresAt;
  final String message;

  SendOTPResponse({
    this.verificationCode,
    this.expiresAt,
    required this.message,
  });

  factory SendOTPResponse.fromJson(Map<String, dynamic> json) {
    return SendOTPResponse(
      verificationCode: json['verification_code'],
      expiresAt: json['expires_at'],
      message: json['message'] ?? 'OTP sent successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verification_code': verificationCode,
      'expires_at': expiresAt,
      'message': message,
    };
  }
}
