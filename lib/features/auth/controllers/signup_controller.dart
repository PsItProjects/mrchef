import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final RxBool agreeToTerms = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void toggleAgreeToTerms(bool? value) {
    agreeToTerms.value = value ?? false;
  }

  void signup() {
    if (formKey.currentState!.validate() && agreeToTerms.value) {
      // Implement signup functionality
      Get.snackbar(
        'Signup',
        'Processing signup...',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Simulate signup success
      Future.delayed(const Duration(seconds: 2), () {
        // Navigate to login screen
        Get.offAllNamed(AppRoutes.LOGIN);
      });
    } else if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
      );
    }
  }

  void signupWithFacebook() {
    // Implement Facebook signup
    Get.snackbar(
      'Facebook Signup',
      'Processing Facebook signup...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void signupWithGoogle() {
    // Implement Google signup
    Get.snackbar(
      'Google Signup',
      'Processing Google signup...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
