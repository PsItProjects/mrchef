import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import '../controllers/otp_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OTPController>();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header with language selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildLanguageSelector(),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // App Logo
                    Image.asset(
                      'assets/mr_sheaf_logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFD2D2D2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Verification title
                    Text(
                      'verification'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xFF262626),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'enter_otp_description'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF5E5E5E),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // OTP input fields
                    _buildOTPFields(controller),

                    const SizedBox(height: 32),

                    // Resend section
                    _buildResendSection(controller),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Verify button at bottom (fixed)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildVerifyButton(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return GestureDetector(
      onTap: () {
        final languageService = Get.find<LanguageService>();
        final newLanguage = languageService.currentLanguage == 'ar' ? 'en' : 'ar';
        languageService.setLanguage(newLanguage);
        Get.updateLocale(Locale(newLanguage, newLanguage == 'ar' ? 'SA' : 'US'));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD2D2D2), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18, color: Color(0xFF262626)),
            const SizedBox(width: 6),
            Obx(() {
              final languageService = Get.find<LanguageService>();
              final isArabic = languageService.currentLanguageRx.value == 'ar';
              return Text(
                isArabic ? 'العربية' : 'English',
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xFF262626),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPFields(OTPController controller) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF262626),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    controller.otpControllers[index].text.isEmpty &&
                    index > 0) {
                  controller.focusNodes[index - 1].requestFocus();
                }
              },
              child: TextField(
                controller: controller.otpControllers[index],
                focusNode: controller.focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF262626),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  controller.onOTPChanged(index, value);
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResendSection(OTPController controller) {
    return Obx(() {
      if (controller.canResend.value) {
        return GestureDetector(
          onTap: controller.isLoading.value ? null : controller.resendOTP,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryColor,
                width: 1,
              ),
            ),
            child: Text(
              'resend_otp'.tr,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        );
      } else {
        return Column(
          children: [
            Text(
              'resending_message_after'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF5E5E5E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '00:${controller.countdown.value.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        );
      }
    });
  }

  Widget _buildVerifyButton(OTPController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.verifyOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF592E2C),
                    ),
                  )
                : Text(
                    'verify'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF592E2C),
                    ),
                  ),
          ),
        ));
  }
}

