import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/widgets/language_switcher.dart';
import 'package:mrsheaf/features/auth/controllers/new_signup_controller.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:segmented_button_slide/segmented_button_slide.dart';

class NewSignupScreen extends StatelessWidget {
  const NewSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    if (!Get.isRegistered<NewSignupController>()) {
      Get.put(NewSignupController());
    }
    final controller = Get.find<NewSignupController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with back button and language selector
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 24,
                        height: 24,
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Color(0xFF262626),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const LanguageSwitcher(
                            isCompact: true,
                            showLabel: false,
                          ),
                        ],
                      ),
                    ),
                    // Language selector
                  ],
                ),
              ),

              // App Logo
              SizedBox(height: 20),
              Image.asset(
                'assets/mr_sheaf_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 30),

              // Title
              Text(
                'get_started'.tr,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF262626),
                  letterSpacing: -0.01,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40),

              // Form content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // User/Vendor toggle
                    _buildUserVendorToggle(controller),
                    SizedBox(height: 20),

                    // Form fields
                    _buildFormFields(controller),
                    SizedBox(height: 20),

                    // Terms and conditions
                    _buildTermsCheckbox(controller),
                    SizedBox(height: 30),

                    // Sign up button
                    _buildSignupButton(controller),
                    SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'already_have_account'.tr,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(0xFF262626),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.LOGIN),
                          child: Text(
                            'login'.tr,
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFFFACD02),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserVendorToggle(NewSignupController controller) {
    return Obx(() {
      // Simple approach: Keep entries order consistent
      // index 0 = Customer, index 1 = Vendor
      // The widget handles RTL layout internally
      final entries = [
        SegmentedButtonSlideEntry(label: 'customer'.tr),
        SegmentedButtonSlideEntry(label: 'vendor'.tr),
      ];

      // selectedEntry: 0 = Customer, 1 = Vendor
      final selectedEntry = controller.isVendor.value ? 1 : 0;

      return Directionality(
        // Force LTR for this widget to ensure consistent behavior
        textDirection: TextDirection.ltr,
        child: Container(
          height: 42,
          child: SegmentedButtonSlide(
            entries: entries,
            selectedEntry: selectedEntry,
            onChange: (index) {
              // index 0 = Customer, index 1 = Vendor
              controller.toggleUserType(index == 1);
            },
            colors: SegmentedButtonSlideColors(
              barColor: Color(0xFFE3E3E3),
              backgroundSelectedColor: Color(0xFFFACD02),
              foregroundSelectedColor: Color(0xFF592E2C),
              foregroundUnselectedColor: Color(0xFF5E5E5E),
              hoverColor: Color(0xFFFACD02),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFormFields(NewSignupController controller) {
    return Obx(() {
      if (controller.isVendor.value) {
        return Column(
          children: [
            _buildInputFieldWithError(
              'english_full_name'.tr,
              'enter_english_full_name'.tr,
              controller.englishFullNameController,
              controller.englishNameError,
            ),
            SizedBox(height: 20),
            _buildInputFieldWithError(
              'arabic_full_name'.tr,
              'enter_arabic_full_name'.tr,
              controller.arabicFullNameController,
              controller.arabicNameError,
            ),
            SizedBox(height: 20),
            _buildInputFieldWithError(
              'email'.tr,
              'enter_your_email'.tr,
              controller.emailController,
              controller.emailError,
            ),
            SizedBox(height: 20),
            _buildPhoneField(controller),
          ],
        );
      } else {
        return Column(
          children: [
            _buildInputFieldWithError(
              'english_full_name'.tr,
              'enter_english_full_name'.tr,
              controller.englishFullNameController,
              controller.englishNameError,
            ),
            SizedBox(height: 20),
            _buildInputFieldWithError(
              'arabic_full_name'.tr,
              'enter_arabic_full_name'.tr,
              controller.arabicFullNameController,
              controller.arabicNameError,
            ),
            SizedBox(height: 20),
            _buildInputFieldWithError(
              'email'.tr,
              'enter_your_email'.tr,
              controller.emailController,
              controller.emailError,
            ),
            SizedBox(height: 20),
            _buildPhoneField(controller),
          ],
        );
      }
    });
  }

  Widget _buildInputField(
      String label, String placeholder, TextEditingController textController,
      {String? errorMessage}) {
    final hasError = errorMessage != null && errorMessage.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: hasError ? Colors.red : Color(0xFF262626),
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
                color: hasError ? Colors.red : Color(0xFFD2D2D2),
                width: hasError ? 2 : 1),
            borderRadius: BorderRadius.circular(10),
            color: hasError ? Colors.red.withOpacity(0.05) : Colors.transparent,
          ),
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFFB7B7B7),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: hasError
                  ? Icon(Icons.error_outline, color: Colors.red, size: 20)
                  : null,
            ),
          ),
        ),
        // Error message with icon
        if (hasError)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInputFieldWithError(String label, String placeholder,
      TextEditingController textController, RxString errorObservable) {
    return Obx(() => _buildInputField(
      label,
      placeholder,
      textController,
      errorMessage: errorObservable.value,
    ));
  }

  Widget _buildPhoneField(NewSignupController controller) {
    return Obx(() {
      final hasError = controller.phoneNumberError.value.isNotEmpty;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'phone_number'.tr,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: hasError ? Colors.red : Color(0xFF262626),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              // Country code container
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hasError ? Colors.red : Color(0xFF262626),
                    width: hasError ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: hasError ? Colors.red.withOpacity(0.05) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xFF006C35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Text(
                          'SA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '+966',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              // Phone number input
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: hasError ? Colors.red : Color(0xFFE3E3E3),
                      width: hasError ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: hasError ? Colors.red.withOpacity(0.05) : Colors.transparent,
                  ),
                  child: TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '50 123 4567',
                      hintStyle: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFFB7B7B7),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: hasError
                          ? Icon(Icons.error_outline, color: Colors.red, size: 20)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Error message with icon
          if (hasError)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      controller.phoneNumberError.value,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTermsCheckbox(NewSignupController controller) {
    return Obx(() => Row(
          children: [
            GestureDetector(
              onTap: () =>
                  controller.toggleAgreeToTerms(!controller.agreeToTerms.value),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF262626), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: controller.agreeToTerms.value
                    ? Icon(Icons.check, size: 16, color: Color(0xFF262626))
                    : null,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'agree'.tr,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF262626),
              ),
            ),
            Text(
              'terms_conditions'.tr,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFFFACD02),
              ),
            ),
          ],
        ));
  }

  Widget _buildSignupButton(NewSignupController controller) {
    return Obx(() => Container(
          // width: 380,
          // height: 50,
          child: ElevatedButton(
            onPressed:
                (controller.agreeToTerms.value && !controller.isLoading.value)
                    ? controller.signup
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (controller.agreeToTerms.value && !controller.isLoading.value)
                      ? AppColors.primaryColor
                      : AppColors.disabledColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    controller.isVendor.value ? 'continue'.tr : 'sign_up'.tr,
                    style: AppTheme.buttonTextStyle.copyWith(
                      color: (controller.agreeToTerms.value &&
                              !controller.isLoading.value)
                          ? AppColors.searchIconColor
                          : AppColors.textLightColor,
                    ),
                  ),
          ),
        ));
  }
}
