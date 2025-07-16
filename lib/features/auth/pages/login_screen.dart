import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/auth/controllers/login_controller.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneNumberValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber() {
    setState(() {
      // Check if phone number has at least 9 digits (Saudi phone numbers)
      String phoneNumber = _phoneController.text.replaceAll(' ', '');
      _isPhoneNumberValid = phoneNumber.length >= 9;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(LoginController());
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
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

            // Yellow circle (background decoration)
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
                  // Welcome text
                  Text(
                    'Welcome Back 👋',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Color(0xFF262626),
                      letterSpacing: -0.01,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 70),

                  // Phone number input section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label
                        Text(
                          'Phone Number',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF262626),
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Phone input row
                        Row(
                          children: [
                            // Country code container
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFF262626), width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Saudi flag icon
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        color: Color(
                                            0xFF006C35), // Saudi flag green
                                        child: Center(
                                          child: Text(
                                            '🇸🇦',
                                            style: TextStyle(fontSize: 16),
                                          ),
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
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFFE3E3E3), width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xFF1C1C1C),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '00 000 0000',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Color(0xFFB7B7B7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  onChanged: (value) {
                                    // Auto-format phone number with spaces
                                    String formatted =
                                        _formatPhoneNumber(value);
                                    if (formatted != value) {
                                      _phoneController.value = TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(
                                            offset: formatted.length),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 54),

                  // Login button and fingerprint
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Login button
                        Expanded(
                          child: Container(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isPhoneNumberValid
                                  ? () {
                                      // Navigate to OTP screen only if phone number is valid
                                      Get.toNamed(AppRoutes.OTP_VERIFICATION);
                                    }
                                  : null, // Disable button if phone number is invalid
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPhoneNumberValid
                                    ? AppColors
                                        .primaryColor // Yellow when enabled
                                    : Color(0xFFD2D2D2), // Gray when disabled
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: _isPhoneNumberValid
                                      ? Color(
                                          0xFF592E2C) // Dark brown when enabled
                                      : Colors.white, // White when disabled
                                  letterSpacing: -0.005,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),

                        // Fingerprint button
                        Container(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.primaryColor, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.fingerprint,
                            color: AppColors.primaryColor,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section
            Positioned(
              bottom: 102,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account ?',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFF262626),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.SIGNUP),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primaryColor,
                        height: 1.6,
                      ),
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

  String _formatPhoneNumber(String value) {
    // Remove all non-digit characters
    String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 9 digits (Saudi phone number format)
    if (digitsOnly.length > 9) {
      digitsOnly = digitsOnly.substring(0, 9);
    }

    // Format as XX XXX XXXX
    if (digitsOnly.length <= 2) {
      return digitsOnly;
    } else if (digitsOnly.length <= 5) {
      return '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2)}';
    } else {
      return '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 5)} ${digitsOnly.substring(5)}';
    }
  }
}
