import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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

                    // Language selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFD2D2D2), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language, size: 18, color: Color(0xFF262626)),
                          SizedBox(width: 4),
                          Text(
                            'English',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF262626),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              size: 10, color: Color(0xFF262626)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Gray circle (background decoration)
              SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD2D2D2),
                ),
              ),

              SizedBox(height: 30),

              // Title
              Text(
                TranslationHelper.tr('get_started'),
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
                          TranslationHelper.tr('already_have_account'),
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
                            TranslationHelper.tr('login'),
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
    return Obx(() => Container(
          height: 42,
          child: SegmentedButtonSlide(
            entries: [
              SegmentedButtonSlideEntry(label: TranslationHelper.tr('customer')),
              SegmentedButtonSlideEntry(label: TranslationHelper.tr('vendor')),
            ],
            selectedEntry: controller.isVendor.value ? 1 : 0,
            onChange: (index) => controller.toggleUserType(index == 1),
            colors: SegmentedButtonSlideColors(
              barColor: Color(0xFFE3E3E3),
              backgroundSelectedColor: Color(0xFFFACD02),
              foregroundSelectedColor: Color(0xFF592E2C),
              foregroundUnselectedColor: Color(0xFF5E5E5E),
              hoverColor: Color(0xFFFACD02),
            ),
            // slideCurve: Curves.easeInOut,
            // animationDuration: Duration(milliseconds: 200),
            // height: 42,
            // padding: EdgeInsets.all(2),
            // borderRadius: BorderRadius.circular(10),
            // selectedTextStyle: TextStyle(
            //   fontFamily: 'Lato',
            //   fontWeight: FontWeight.w700,
            //   fontSize: 16,
            //   color: Color(0xFF592E2C),
            // ),
            // unselectedTextStyle: TextStyle(
            //   fontFamily: 'Lato',
            //   fontWeight: FontWeight.w600,
            //   fontSize: 16,
            //   color: Color(0xFF5E5E5E),
            // ),
          ),
        ));
  }

  Widget _buildFormFields(NewSignupController controller) {
    return Obx(() {
      if (controller.isVendor.value) {
        return Column(
          children: [
            _buildInputFieldWithError(
              'English Full Name',
              'Enter your English Full name',
              controller.englishFullNameController,
              controller.englishNameError,
            ),
            SizedBox(height: 20),
            _buildInputFieldWithError(
              'Arabic Full Name',
              'Enter your Arabic Full name',
              controller.arabicFullNameController,
              controller.arabicNameError,
            ),
            SizedBox(height: 20),
            _buildInputFieldWithError(
              'Email',
              'Enter your email',
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
            _buildInputField(
              'Full Name',
              'Enter your Full name',
              controller.fullNameController,
            ),
            SizedBox(height: 20),
            _buildInputFieldWithError(
              'Email',
              'Enter your email',
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
      String label, String placeholder, TextEditingController textController, {String? errorMessage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: errorMessage != null && errorMessage.isNotEmpty
                  ? Colors.red
                  : Color(0xFFD2D2D2),
              width: 1
            ),
            borderRadius: BorderRadius.circular(10),
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
            ),
          ),
        ),
        // Error message
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'Lato',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputFieldWithError(
      String label, String placeholder, TextEditingController textController, RxString errorObservable) {
    return GetBuilder<NewSignupController>(
      builder: (controller) => _buildInputField(
        label,
        placeholder,
        textController,
        errorMessage: errorObservable.value,
      ),
    );
  }

  Widget _buildPhoneField(NewSignupController controller) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
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
                border: Border.all(color: Color(0xFF262626), width: 1),
                borderRadius: BorderRadius.circular(10),
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
                    color: controller.phoneNumberError.value.isNotEmpty
                        ? Colors.red
                        : Color(0xFFE3E3E3),
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(10),
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
                  ),
                ),
              ),
            ),
          ],
        ),
        // Error message
        if (controller.phoneNumberError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              controller.phoneNumberError.value,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'Lato',
              ),
            ),
          ),
      ],
    ));
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
              'Agree ',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF262626),
              ),
            ),
            Text(
              'Terms & Conditions',
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
            onPressed: (controller.agreeToTerms.value && !controller.isLoading.value)
                ? controller.signup
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: (controller.agreeToTerms.value && !controller.isLoading.value)
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
                    controller.isVendor.value ? TranslationHelper.tr('continue') : TranslationHelper.tr('sign_up'),
                    style: AppTheme.buttonTextStyle.copyWith(
                      color: (controller.agreeToTerms.value && !controller.isLoading.value)
                          ? AppColors.searchIconColor
                          : AppColors.textLightColor,
                    ),
                  ),
          ),
        ));
  }
}
