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

  // Validation error messages
  final RxString phoneNumberError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString englishNameError = ''.obs;
  final RxString arabicNameError = ''.obs;
  bool _isDisposed = false;

  final AuthService _authService = Get.find<AuthService>();

  void toggleUserType(bool vendor) {
    isVendor.value = vendor;
  }

  void toggleAgreeToTerms(bool? value) {
    agreeToTerms.value = value ?? false;
  }

  void validatePhoneNumber() {
    if (!_isDisposed) {
      String phoneNumber = phoneController.text.replaceAll(' ', '');

      // Clear previous error
      phoneNumberError.value = '';

      // Validate phone number format (Saudi format: 9 digits)
      if (phoneNumber.isEmpty) {
        phoneNumberError.value = 'phone_number_required'.tr;
        isPhoneNumberValid.value = false;
      } else if (phoneNumber.startsWith('0')) {
        phoneNumberError.value = 'phone_number_no_zero'.tr;
        isPhoneNumberValid.value = false;
      } else if (!RegExp(r'^[0-9]{9}$').hasMatch(phoneNumber)) {
        phoneNumberError.value = 'phone_number_9_digits'.tr;
        isPhoneNumberValid.value = false;
      } else {
        isPhoneNumberValid.value = true;
      }
    }
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
          // Print OTP code clearly for testing
          if (response.data != null && response.data!.verificationCode != null) {
            print('🎯🎯🎯 OTP CODE FOR TESTING: ${response.data!.verificationCode} 🎯🎯🎯');
            print('📱 Phone: ${phoneController.text.replaceAll(' ', '')}');
            print('👤 User Type: merchant');
            print('🎯🎯🎯 USE THIS CODE IN THE OTP SCREEN 🎯🎯🎯');
          }

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
          // Handle validation errors from backend
          _handleRegistrationErrors(response);
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
          // Handle validation errors from backend
          _handleRegistrationErrors(response);
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

  /// Handle registration errors from backend
  void _handleRegistrationErrors(dynamic response) {
    // Clear all previous errors
    _clearValidationErrors();

    // Check if response has errors object
    if (response.errors != null && response.errors is Map) {
      final errors = response.errors as Map<String, dynamic>;

      // Handle specific field errors
      if (errors.containsKey('phone_number')) {
        final phoneErrors = errors['phone_number'];
        if (phoneErrors is List && phoneErrors.isNotEmpty) {
          phoneNumberError.value = phoneErrors.first.toString();
        }
      }

      if (errors.containsKey('email')) {
        final emailErrors = errors['email'];
        if (emailErrors is List && emailErrors.isNotEmpty) {
          emailError.value = emailErrors.first.toString();
        }
      }

      if (errors.containsKey('english_full_name')) {
        final nameErrors = errors['english_full_name'];
        if (nameErrors is List && nameErrors.isNotEmpty) {
          englishNameError.value = nameErrors.first.toString();
        }
      }

      if (errors.containsKey('arabic_full_name')) {
        final nameErrors = errors['arabic_full_name'];
        if (nameErrors is List && nameErrors.isNotEmpty) {
          arabicNameError.value = nameErrors.first.toString();
        }
      }

      // Show general error message
      Get.snackbar(
        'registration_failed'.tr,
        'please_check_errors_below'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
        duration: const Duration(seconds: 4),
      );
    } else {
      // Show general error message
      Get.snackbar(
        'registration_failed'.tr,
        response.message ?? 'unknown_error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
    }
  }

  /// Clear all validation error messages
  void _clearValidationErrors() {
    phoneNumberError.value = '';
    emailError.value = '';
    englishNameError.value = '';
    arabicNameError.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(validatePhoneNumber);
  }

  @override
  void onClose() {
    _isDisposed = true;
    phoneController.removeListener(validatePhoneNumber);
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    englishFullNameController.dispose();
    arabicFullNameController.dispose();
    super.onClose();
  }
}
