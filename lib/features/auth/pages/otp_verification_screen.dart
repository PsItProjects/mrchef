import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            border:
                                Border.all(color: Color(0xFF262626), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
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
                                if (value.isNotEmpty && index < 3) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
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
                        onPressed: () {
                          // Handle verification
                          Get.toNamed(AppRoutes.HOME);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
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
              child: Column(
                children: [
                  Text(
                    'Resending Message after ',
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
                    '01:00',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF5E5E5E),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
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
  }
}
