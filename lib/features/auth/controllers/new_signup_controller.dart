import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
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

  String _extractBackendMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
    }
    return 'unexpected_error'.tr;
  }

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
      ToastService.showError('Please agree to the terms and conditions');
      return;
    }

    if (!isPhoneNumberValid.value) {
      ToastService.showError('Please enter a valid phone number');
      return;
    }

    isLoading.value = true;

    try {
      if (isVendor.value) {
        // Register as merchant
        final languageService = Get.find<LanguageService>();
        
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
          ToastService.showSuccess(response.message);

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
        final languageService = Get.find<LanguageService>();
        
        final request = CustomerRegistrationRequest(
          nameEn: englishFullNameController.text.trim(),
          nameAr: arabicFullNameController.text.trim(),
          phoneNumber: phoneController.text.replaceAll(' ', ''),
          countryCode: '+966',
          email: emailController.text.trim().isNotEmpty
              ? emailController.text.trim()
              : null,
          preferredLanguage: languageService.currentLanguage, // Use current app language
          agreeToTerms: agreeToTerms.value,
        );

        final response = await _authService.registerCustomer(request);

        if (response.isSuccess) {
          ToastService.showSuccess(response.message);

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
    } on DioException catch (e) {
      // Handle Dio errors (network, 409, etc.)
      _clearValidationErrors();
      
      final data = e.response?.data;
      String errorMessage = 'unexpected_error'.tr;
      
      if (data is Map && data['message'] != null) {
        errorMessage = data['message'].toString();
      }
      
      // Check if it's a phone error
      if (errorMessage.contains('الهاتف') || 
          errorMessage.contains('phone') ||
          errorMessage.contains('مسجل') ||
          e.response?.statusCode == 409) {
        phoneNumberError.value = errorMessage;
      }
      
      ToastService.showError(errorMessage);
    } catch (e) {
      ToastService.showError('unexpected_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle registration errors from backend
  void _handleRegistrationErrors(dynamic response) {
    // Clear all previous errors
    _clearValidationErrors();

    // Check if it's a phone already registered error (HTTP 409 or message contains phone)
    final message = response.message ?? '';
    final isPhoneError = response.statusCode == 409 || 
        message.contains('الهاتف') || 
        message.contains('phone') ||
        message.contains('مسجل');
    
    if (isPhoneError && message.isNotEmpty) {
      // Show phone number error in the field
      phoneNumberError.value = message;
      
      // Show professional toast
      ToastService.showError(message);
      return;
    }

    // Check if response has errors object
    if (response.errors != null && response.errors is Map) {
      final errors = response.errors as Map<String, dynamic>;
      
      // Collect all error messages
      List<String> allErrorMessages = [];

      // Handle specific field errors
      if (errors.containsKey('phone_number')) {
        final phoneErrors = errors['phone_number'];
        if (phoneErrors is List && phoneErrors.isNotEmpty) {
          phoneNumberError.value = phoneErrors.first.toString();
          allErrorMessages.add('• ${'phone_number'.tr}: ${phoneErrors.first}');
        }
      }

      if (errors.containsKey('email')) {
        final emailErrors = errors['email'];
        if (emailErrors is List && emailErrors.isNotEmpty) {
          emailError.value = emailErrors.first.toString();
          allErrorMessages.add('• ${'email'.tr}: ${emailErrors.first}');
        }
      }

      if (errors.containsKey('english_full_name')) {
        final nameErrors = errors['english_full_name'];
        if (nameErrors is List && nameErrors.isNotEmpty) {
          englishNameError.value = nameErrors.first.toString();
          allErrorMessages.add('• ${'english_full_name'.tr}: ${nameErrors.first}');
        }
      }

      if (errors.containsKey('arabic_full_name')) {
        final nameErrors = errors['arabic_full_name'];
        if (nameErrors is List && nameErrors.isNotEmpty) {
          arabicNameError.value = nameErrors.first.toString();
          allErrorMessages.add('• ${'arabic_full_name'.tr}: ${nameErrors.first}');
        }
      }

      if (errors.containsKey('name_ar')) {
        final nameErrors = errors['name_ar'];
        if (nameErrors is List && nameErrors.isNotEmpty) {
          arabicNameError.value = nameErrors.first.toString();
          allErrorMessages.add('• ${'arabic_full_name'.tr}: ${nameErrors.first}');
        }
      }

      if (errors.containsKey('name_en')) {
        final nameErrors = errors['name_en'];
        if (nameErrors is List && nameErrors.isNotEmpty) {
          englishNameError.value = nameErrors.first.toString();
          allErrorMessages.add('• ${'english_full_name'.tr}: ${nameErrors.first}');
        }
      }

      // Show detailed error message with all errors
      String errorMessage = allErrorMessages.isNotEmpty
          ? allErrorMessages.join('\n')
          : 'please_check_errors_below'.tr;

      ToastService.showValidationErrors({'message': [errorMessage]});
    } else {
      // Show general error message from backend
      ToastService.showError(
        response.message ?? 'unknown_error_occurred'.tr,
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
