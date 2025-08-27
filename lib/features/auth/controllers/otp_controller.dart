import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../models/auth_request.dart';

class OTPController extends GetxController {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  
  final List<FocusNode> focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  final RxBool isLoading = false.obs;
  final RxBool canResend = false.obs;
  final RxInt countdown = 60.obs;

  final AuthService _authService = Get.find<AuthService>();

  // Arguments from previous screen
  String? phoneNumber;
  String? countryCode;
  String? userType;
  String? purpose; // 'login' or 'registration'

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      phoneNumber = args['phone_number'];
      countryCode = args['country_code'] ?? '+966';
      userType = args['user_type'] ?? 'customer';
      purpose = args['purpose'] ?? 'registration';
    }

    _startCountdown();
  }

  void _startCountdown() {
    countdown.value = 60;
    canResend.value = false;
    
    // Start countdown timer
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      countdown.value--;
      
      if (countdown.value <= 0) {
        canResend.value = true;
        return false;
      }
      return true;
    });
  }

  void onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    if (_isOTPComplete()) {
      verifyOTP();
    }
  }

  bool _isOTPComplete() {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOTPCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  Future<void> verifyOTP() async {
    if (!_isOTPComplete()) {
      Get.snackbar(
        'Incomplete OTP',
        'Please enter the complete OTP code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
      return;
    }

    if (phoneNumber == null) {
      Get.snackbar(
        'Error',
        'Phone number not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
      return;
    }

    isLoading.value = true;

    try {
      final request = OTPVerificationRequest(
        phoneNumber: phoneNumber!,
        otpCode: _getOTPCode(),
        countryCode: countryCode ?? '+966',
        userType: userType,
      );

      if (purpose == 'login') {
        // Verify login OTP
        final response = await _authService.verifyLoginOTP(request);
        
        if (response.isSuccess) {
          Get.snackbar(
            'Login Successful',
            'Welcome back!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.3),
          );

          // Navigate to home screen
          Get.offAllNamed(AppRoutes.HOME);
        } else {
          Get.snackbar(
            'Verification Failed',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
          );
          _clearOTP();
        }
      } else {
        // Verify registration OTP
        final response = await _authService.verifyRegistrationOTP(request);
        
        if (response.isSuccess) {
          Get.snackbar(
            'Registration Successful',
            'Your account has been created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.3),
          );

          if (userType == 'merchant') {
            // Navigate to merchant onboarding
            Get.offAllNamed(AppRoutes.VENDOR_STEP1);
          } else {
            // Navigate to home screen for customers
            Get.offAllNamed(AppRoutes.HOME);
          }
        } else {
          Get.snackbar(
            'Verification Failed',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
          );
          _clearOTP();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
      _clearOTP();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOTP() async {
    if (!canResend.value || phoneNumber == null) {
      return;
    }

    isLoading.value = true;

    try {
      final request = ResendOTPRequest(
        phoneNumber: phoneNumber!,
        countryCode: countryCode ?? '+966',
        userType: userType,
      );

      final response = await _authService.resendOTP(request);

      if (response.isSuccess) {
        Get.snackbar(
          'OTP Sent',
          'A new OTP has been sent to your phone',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.3),
        );

        _clearOTP();
        _startCountdown();
      } else {
        Get.snackbar(
          'Failed to Resend',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearOTP() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
  }

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }
}
