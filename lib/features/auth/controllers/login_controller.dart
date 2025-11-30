import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../models/auth_request.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late TextEditingController phoneController;
  late TextEditingController countryCodeController;

  final RxBool isLoading = false.obs;
  final RxBool isPhoneNumberValid = false.obs;
  bool _isInitialized = false;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _initControllers();
  }

  void _initControllers() {
    if (!_isInitialized) {
      phoneController = TextEditingController();
      countryCodeController = TextEditingController(text: '+966');
      phoneController.addListener(_validatePhoneNumber);
      _isInitialized = true;
    }
  }

  void _validatePhoneNumber() {
    if (_isInitialized) {
      String phoneNumber = phoneController.text.replaceAll(' ', '');
      isPhoneNumberValid.value = phoneNumber.length >= 9;
    }
  }

  /// Reset phone input for new login attempt
  void resetPhoneInput() {
    if (_isInitialized) {
      phoneController.clear();
      isPhoneNumberValid.value = false;
    }
  }

  Future<void> sendLoginOTP() async {
    if (!isPhoneNumberValid.value) {
      Get.snackbar(
        'Invalid Phone Number',
        'Please enter a valid phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
      return;
    }

    isLoading.value = true;

    try {
      final request = LoginRequest(
        phoneNumber: phoneController.text.replaceAll(' ', ''),
        countryCode: countryCodeController.text,
      );

      final response = await _authService.sendLoginOTP(request);

      if (response.isSuccess) {
        Get.snackbar(
          'OTP Sent',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.3),
        );

        // Navigate to OTP verification screen
        final arguments = {
          'phone_number': phoneController.text.replaceAll(' ', ''),
          'country_code': countryCodeController.text,
          'purpose': 'login',
        };

        print('🚀 LOGIN: Navigating to OTP with arguments: $arguments');
        Get.toNamed(AppRoutes.OTP_VERIFICATION, arguments: arguments);
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithFacebook() {
    // Implement Facebook login
    Get.snackbar(
      'Facebook Login',
      'Processing Facebook login...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void loginWithGoogle() {
    // Implement Google login
    Get.snackbar(
      'Google Login',
      'Processing Google login...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    if (_isInitialized) {
      phoneController.removeListener(_validatePhoneNumber);
      phoneController.dispose();
      countryCodeController.dispose();
      _isInitialized = false;
    }
    super.onClose();
  }
}
