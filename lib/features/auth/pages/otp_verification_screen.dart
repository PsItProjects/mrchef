import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
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

    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Status bar

              // Language selector (top right)
              Positioned(
                top: 20,
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
                top: 84,
                left: 164,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD2D2D2), // Gray circle as per Figma
                  ),
                ),
              ),

              // Main content
              Positioned(
                top: 234,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Verification title
                    Text(
                      'Verification',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xFF262626),
                        letterSpacing: -0.01,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Description text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 51),
                      child: Text(
                        'Enter OTP Code We Just Sent you On Your Phone Number',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.6,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // OTP input fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFF262626), width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: TextField(
                                controller: controller.otpControllers[index],
                                focusNode: controller.focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  color: Color(0xFF262626),
                                  letterSpacing: -0.01,
                                  height: 1.5,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                onChanged: (value) {
                                  controller.onOTPChanged(index, value);
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 80),

                    // Verify button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        // width: 380,
                        // height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  controller.verifyOTP();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF592E2C),
                                )
                              : const Text(
                                  'Verify',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(0xFF592E2C),
                                    letterSpacing: -0.005,
                                    height: 1.45,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Resend message section (bottom)
              Positioned(
                bottom: 132,
                left: 0,
                right: 0,
                child: Obx(() => Column(
                  children: [
                    if (!controller.canResend.value) ...[
                      Text(
                        'Resending Message after',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFF5E5E5E),
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '00:${controller.countdown.value.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF5E5E5E),
                          height: 1.6,
                        ),
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: controller.isLoading.value ? null : controller.resendOTP,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: controller.isLoading.value
                                ? Colors.grey.withValues(alpha: 0.3)
                                : AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller.isLoading.value
                                  ? Colors.grey
                                  : AppColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                  ),
                                )
                              : Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                )),
              ),

              // Navigation bar (bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 28,
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Color(0xFF262626),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
