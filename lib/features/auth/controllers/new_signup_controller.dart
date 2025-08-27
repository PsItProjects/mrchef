import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../models/auth_request.dart';

class NewSignupController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // For vendor
  final englishFullNameController = TextEditingController();
  final arabicFullNameController = TextEditingController();

  // Observable variables
  final RxBool isVendor = false.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool isPhoneNumberValid = false.obs;
  final RxBool isLoading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  void toggleUserType(bool vendor) {
    isVendor.value = vendor;
  }

  void toggleAgreeToTerms(bool? value) {
    agreeToTerms.value = value ?? false;
  }

  void validatePhoneNumber() {
    String phoneNumber = phoneController.text.replaceAll(' ', '');
    isPhoneNumberValid.value = phoneNumber.length >= 9;
  }

  Future<void> signup() async {
    if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
      return;
    }

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
      if (isVendor.value) {
        // Register as merchant
        final request = MerchantRegistrationRequest(
          englishFullName: englishFullNameController.text.trim(),
          arabicFullName: arabicFullNameController.text.trim(),
          phoneNumber: phoneController.text.replaceAll(' ', ''),
          countryCode: '+966',
          email: emailController.text.trim(),
          agreeToTerms: agreeToTerms.value,
        );

        final response = await _authService.registerMerchant(request);

        if (response.isSuccess) {
          Get.snackbar(
            'Registration Successful',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.3),
          );

          // Navigate to OTP verification
          Get.toNamed(AppRoutes.OTP_VERIFICATION, arguments: {
            'phone_number': phoneController.text.replaceAll(' ', ''),
            'country_code': '+966',
            'user_type': 'merchant',
            'purpose': 'registration',
          });
        } else {
          Get.snackbar(
            'Registration Failed',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
          );
        }
      } else {
        // Register as customer
        final request = CustomerRegistrationRequest(
          nameEn: fullNameController.text.trim(),
          phoneNumber: phoneController.text.replaceAll(' ', ''),
          countryCode: '+966',
          email: emailController.text.trim().isNotEmpty
              ? emailController.text.trim()
              : null,
          agreeToTerms: agreeToTerms.value,
        );

        final response = await _authService.registerCustomer(request);

        if (response.isSuccess) {
          Get.snackbar(
            'Registration Successful',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.3),
          );

          // Navigate to OTP verification
          Get.toNamed(AppRoutes.OTP_VERIFICATION, arguments: {
            'phone_number': phoneController.text.replaceAll(' ', ''),
            'country_code': '+966',
            'user_type': 'customer',
            'purpose': 'registration',
          });
        } else {
          Get.snackbar(
            'Registration Failed',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
          );
        }
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

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(validatePhoneNumber);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    englishFullNameController.dispose();
    arabicFullNameController.dispose();
    super.onClose();
  }
}
