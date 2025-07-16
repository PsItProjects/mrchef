import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void login() {
    if (formKey.currentState!.validate()) {
      // Implement login functionality
      Get.snackbar(
        'Login',
        'Processing login...',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Simulate login success
      Future.delayed(const Duration(seconds: 2), () {
        // Navigate to home screen
        Get.offAllNamed(AppRoutes.HOME);
      });
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
