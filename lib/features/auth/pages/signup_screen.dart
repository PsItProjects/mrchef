import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/controllers/signup_controller.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller (it's already initialized in AuthBinding)
    final controller = Get.find<SignupController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('create_account'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'create_your_account'.tr,
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 20),
                Text(
                  'please_fill_details'.tr,
                  style: AppTheme.bodyStyle,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'full_name'.tr,
                    hintText: 'enter_your_full_name'.tr,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_your_name'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'email'.tr,
                    hintText: 'enter_your_email'.tr,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_your_email'.tr;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'please_enter_valid_email'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GetX<SignupController>(
                  builder: (controller) => TextFormField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      labelText: 'password'.tr,
                      hintText: 'enter_your_password'.tr,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                    obscureText: controller.obscurePassword.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please_enter_your_password'.tr;
                      }
                      if (value.length < 6) {
                        return 'password_min_6_chars'.tr;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                GetX<SignupController>(
                  builder: (controller) => TextFormField(
                    controller: controller.confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'confirm_password'.tr,
                      hintText: 'confirm_your_password'.tr,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    obscureText: controller.obscureConfirmPassword.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please_confirm_your_password'.tr;
                      }
                      if (value != controller.passwordController.text) {
                        return 'passwords_do_not_match'.tr;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Obx(() => Checkbox(
                          value: controller.agreeToTerms.value,
                          activeColor: AppColors.primaryColor,
                          onChanged: controller.toggleAgreeToTerms,
                        )),
                    Expanded(
                      child: Text(
                        'agree_terms_privacy'.tr,
                        style: AppTheme.bodyStyle.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.signup,
                    style: AppTheme.primaryButtonStyle,
                    child: Text('create_account'.tr),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or_sign_up_with'.tr,
                        style: AppTheme.bodyStyle
                            .copyWith(color: AppColors.darkGreyColor),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    socialSignupButton(
                      icon: Icons.facebook,
                      color: AppColors.socialFacebookColor,
                      onTap: controller.signupWithFacebook,
                    ),
                    const SizedBox(width: 16),
                    socialSignupButton(
                      icon: Icons.g_mobiledata,
                      color: AppColors.socialGoogleColor,
                      onTap: controller.signupWithGoogle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget socialSignupButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 32,
        ),
      ),
    );
  }
}
