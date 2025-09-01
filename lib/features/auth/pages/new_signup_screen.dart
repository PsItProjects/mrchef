import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/auth/controllers/new_signup_controller.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:segmented_button_slide/segmented_button_slide.dart';

class NewSignupScreen extends StatelessWidget {
  const NewSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewSignupController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Status bar

            // Back button
            Positioned(
              top: 10,
              left: 24,
              child: GestureDetector(
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
            ),

            // Language selector (top right)
            Positioned(
              top: 10,
              right: 24,
              child: Container(
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
            ),

            // Gray circle (background decoration)
            Positioned(
              top: 30,
              left: 164,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD2D2D2),
                ),
              ),
            ),

            // Main content
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Title
                  Text(
                    'Let\'s get started !',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Color(0xFF262626),
                      letterSpacing: -0.01,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 60),

                  // Form content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // User/Vendor toggle
                        _buildUserVendorToggle(controller),
                        SizedBox(height: 20),

                        // Form fields
                        Obx(() => _buildFormFields(controller)),
                        SizedBox(height: 20),

                        // Terms and conditions
                        _buildTermsCheckbox(controller),
                        SizedBox(height: 50),

                        // Sign up button
                        _buildSignupButton(controller),
                        SizedBox(height: 24),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account ? ',
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
                                'Login',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserVendorToggle(NewSignupController controller) {
    return Obx(() => Container(
          height: 42,
          child: SegmentedButtonSlide(
            entries: const [
              SegmentedButtonSlideEntry(label: 'User'),
              SegmentedButtonSlideEntry(label: 'Vendor'),
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
    if (controller.isVendor.value) {
      return Column(
        children: [
          _buildInputField('English Full Name', 'Enter your English Full name',
              controller.englishFullNameController),
          SizedBox(height: 20),
          _buildInputField('Arabic Full Name', 'Enter your Arabic Full name',
              controller.arabicFullNameController),
          SizedBox(height: 20),
          _buildInputField(
              'Email', 'Enter your email', controller.emailController),
          SizedBox(height: 20),
          _buildPhoneField(controller),
        ],
      );
    } else {
      return Column(
        children: [
          _buildInputField('Full Name', 'Enter your Full name',
              controller.fullNameController),
          SizedBox(height: 20),
          _buildInputField(
              'Email', 'Enter your email', controller.emailController),
          SizedBox(height: 20),
          _buildPhoneField(controller),
        ],
      );
    }
  }

  Widget _buildInputField(
      String label, String placeholder, TextEditingController textController) {
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
            border: Border.all(color: Color(0xFFD2D2D2), width: 1),
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
      ],
    );
  }

  Widget _buildPhoneField(NewSignupController controller) {
    return Column(
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
                  border: Border.all(color: Color(0xFFE3E3E3), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: controller.phoneController,
                  decoration: InputDecoration(
                    hintText: '00 000 0000',
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
      ],
    );
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
            onPressed: controller.agreeToTerms.value ? controller.signup : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.agreeToTerms.value
                  ? AppColors.primaryColor
                  : AppColors.disabledColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              controller.isVendor.value ? 'Continue' : 'Sign Up',
              style: AppTheme.buttonTextStyle.copyWith(
                color: controller.agreeToTerms.value
                    ? AppColors.searchIconColor
                    : AppColors.textLightColor,
              ),
            ),
          ),
        ));
  }
}
