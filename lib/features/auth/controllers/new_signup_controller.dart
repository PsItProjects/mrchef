import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

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

  void signup() {
    // Get.toNamed(AppRoutes.VENDOR_STEP1);
    // formKey.currentState!.validate() &&
    if (agreeToTerms.value) {
      if (isVendor.value) {
        // Navigate to vendor onboarding step 1
        Get.toNamed(AppRoutes.VENDOR_STEP1);
      } else {
        // Navigate to OTP verification for regular users
        Get.toNamed(AppRoutes.OTP_VERIFICATION);
      }
    } else if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
      );
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
