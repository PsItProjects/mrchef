import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../../../core/services/toast_service.dart';
import '../services/auth_service.dart';
import '../models/auth_request.dart';
import '../../merchant/services/merchant_settings_service.dart';

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
  final RxInt countdown = 30.obs;

  final AuthService _authService = Get.find<AuthService>();

  String _extractBackendMessage(Object error, {String? fallbackKey}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
    }
    return (fallbackKey ?? 'unexpected_error').tr;
  }

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

    if (kDebugMode) {
      print('🔍 OTP Controller - Received arguments: $args');
    }

    if (args != null) {
      phoneNumber = args['phone_number'];
      countryCode = args['country_code'] ?? '+966';
      userType = args['user_type']; // Will be null for unified login
      purpose = args['purpose'] ?? 'registration';

      if (kDebugMode) {
        print('📱 Phone Number: $phoneNumber');
        print('🌍 Country Code: $countryCode');
        print('👤 User Type: $userType');
        print('🎯 Purpose: $purpose');
      }

      _startCountdown();
    } else {
      if (kDebugMode) {
        print('❌ No arguments received! OTP Controller initialized without navigation.');
      }
      // Don't start countdown if no arguments received
    }
  }

  void _startCountdown() {
    countdown.value = 30;
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

  /// Convert Arabic numerals (٠-٩) to English numerals (0-9)
  String _convertArabicToEnglishNumbers(String input) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    
    String result = input;
    for (int i = 0; i < arabicNumbers.length; i++) {
      result = result.replaceAll(arabicNumbers[i], englishNumbers[i]);
    }
    return result;
  }

  void onOTPChanged(int index, String value) {
    // Convert Arabic numbers to English
    String convertedValue = _convertArabicToEnglishNumbers(value);
    
    // Keep only digits
    convertedValue = convertedValue.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Update the controller with converted value if different
    if (convertedValue != value) {
      otpControllers[index].text = convertedValue;
      otpControllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: convertedValue.length),
      );
    }
    
    // Navigate to next field if value entered
    if (convertedValue.isNotEmpty && index < 3) {
      Future.delayed(const Duration(milliseconds: 50), () {
        focusNodes[index + 1].requestFocus();
      });
    }
    
    // Auto-verify when all fields are filled
    if (_isOTPComplete()) {
      Future.delayed(const Duration(milliseconds: 100), () {
        verifyOTP();
      });
    }
  }

  /// Handle backspace to go to previous field
  void onKeyPressed(int index, RawKeyEvent event) {
    if (event.logicalKey.keyLabel == 'Backspace' && 
        otpControllers[index].text.isEmpty && 
        index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  bool _isOTPComplete() {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOTPCode() {
    final rawCode = otpControllers.map((controller) => controller.text).join();
    // Convert any Arabic numbers to English
    return _convertArabicToEnglishNumbers(rawCode);
  }

  Future<void> verifyOTP() async {
    print('🚀 Starting OTP verification...');
    print('📱 Current phoneNumber: $phoneNumber');
    print('🌍 Current countryCode: $countryCode');
    print('👤 Current userType: $userType');
    print('🎯 Current purpose: $purpose');

    if (!_isOTPComplete()) {
      print('❌ OTP is not complete');
      ToastService.showError('Please enter the complete OTP code');
      return;
    }

    if (phoneNumber == null) {
      print('❌ Phone number is null!');
      ToastService.showError('Phone number not found');
      return;
    }

    isLoading.value = true;

    try {
      final rawCode = _getOTPCode();
      final cleanedCode = rawCode.replaceAll(RegExp(r'[^0-9]'), '');

      final request = OTPVerificationRequest(
        phoneNumber: phoneNumber!,
        otpCode: cleanedCode,
        countryCode: countryCode ?? '+966',
        userType: userType,
      );

      if (purpose == 'login') {
        // Verify login OTP
        final response = await _authService.verifyLoginOTP(request);

        if (response.isSuccess) {
          ToastService.showSuccess('Welcome back!');

          // Smart navigation based on user type
          _navigateBasedOnUserType();
        } else {
          ToastService.showError(response.message);
          _clearOTP();
        }
      } else {
        // Verify registration OTP
        final response = await _authService.verifyRegistrationOTP(request);
        
        if (response.isSuccess) {
          ToastService.showSuccess('Your account has been created successfully!');

          if (userType == 'merchant') {
            // Navigate to merchant onboarding
            Get.offAllNamed(AppRoutes.VENDOR_STEP1);
          } else {
            // Navigate to home screen for customers
            Get.offAllNamed(AppRoutes.HOME);
          }
        } else {
          ToastService.showError(response.message);
          _clearOTP();
        }
      }
    } catch (e) {
      ToastService.showError(_extractBackendMessage(e is Object ? e : Exception(e.toString())));
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
        ToastService.showSuccess('A new OTP has been sent to your phone');

        _clearOTP();
        _startCountdown();
      } else {
        ToastService.showError(response.message);
      }
    } catch (e) {
      ToastService.showError(_extractBackendMessage(
          e is Object ? e : Exception(e.toString()),
        ));
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

  /// Smart navigation based on detected user type
  void _navigateBasedOnUserType() async {
    final authService = Get.find<AuthService>();
    final detectedUserType = authService.storedUserType;

    if (kDebugMode) {
      print('🎯 SMART NAVIGATION: Detected user type: $detectedUserType');
    }

    if (detectedUserType == 'merchant') {
      // For merchants, check onboarding status first
      await _checkMerchantOnboardingStatus();
    } else {
      // Default to customer home (includes 'customer' and empty/null cases)
      Get.offAllNamed(AppRoutes.HOME);
    }
  }

  /// Check merchant onboarding status and navigate accordingly
  Future<void> _checkMerchantOnboardingStatus() async {
    if (kDebugMode) {
      print('🔍 CHECKING MERCHANT ONBOARDING STATUS...');
    }

    // Directly check onboarding via API call to get fresh data
    await _checkOnboardingViaAPI();
  }

  /// Check onboarding via direct API call
  Future<void> _checkOnboardingViaAPI() async {
    try {
      if (kDebugMode) {
        print('🔍 CHECKING ONBOARDING VIA API...');
      }

      // Create merchant settings service to check onboarding
      final merchantService = MerchantSettingsService();

      // Try to load merchant profile - this will trigger onboarding redirect if needed
      await merchantService.loadMerchantProfile();

      // If we reach here without exception, onboarding is complete
      if (kDebugMode) {
        print('✅ ONBOARDING COMPLETE - Navigating to merchant home');
      }
      Get.offAllNamed(AppRoutes.MERCHANT_HOME);

    } catch (e) {
      if (kDebugMode) {
        print('❌ API onboarding check failed: $e');
      }

      // Check if the error contains onboarding information
      final errorString = e.toString();
      if (errorString.contains('403') && errorString.contains('onboarding')) {
        if (kDebugMode) {
          print('🔄 ONBOARDING REQUIRED - MerchantSettingsService will handle redirect');
        }
        // The MerchantSettingsService._handleOnboardingRequired will handle the redirect
        // So we don't need to do anything here
      } else {
        // Unknown error - fallback to step 1
        if (kDebugMode) {
          print('🔄 UNKNOWN ERROR - Fallback to step 1');
        }
        Get.offAllNamed(AppRoutes.VENDOR_STEP1);
      }
    }
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
