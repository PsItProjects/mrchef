import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../../../core/services/toast_service.dart';

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
      ToastService.showInfo('processing_signup'.tr);
      
      // Simulate signup success
      Future.delayed(const Duration(seconds: 2), () {
        // Navigate to login screen
        Get.offAllNamed(AppRoutes.LOGIN);
      });
    } else if (!agreeToTerms.value) {
      ToastService.showError('agree_to_terms'.tr);
    }
  }

  void signupWithFacebook() {
    // Implement Facebook signup
    ToastService.showInfo('processing_facebook_signup'.tr);
  }

  void signupWithGoogle() {
    // Implement Google signup
    ToastService.showInfo('processing_google_signup'.tr);
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
