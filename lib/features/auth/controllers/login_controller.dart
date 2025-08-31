import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../models/auth_request.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final countryCodeController = TextEditingController(text: '+966');

  final RxBool isLoading = false.obs;
  final RxBool isPhoneNumberValid = false.obs;
  bool _isDisposed = false;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_validatePhoneNumber);
  }

  void _validatePhoneNumber() {
    if (!_isDisposed) {
      String phoneNumber = phoneController.text.replaceAll(' ', '');
      isPhoneNumberValid.value = phoneNumber.length >= 9;
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
          'user_type': 'customer',
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
    _isDisposed = true;
    phoneController.removeListener(_validatePhoneNumber);
    phoneController.dispose();
    countryCodeController.dispose();
    super.onClose();
  }
}
