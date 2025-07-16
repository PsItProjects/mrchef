import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

class FinalOnboardingScreen extends StatelessWidget {
  const FinalOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // White background as per Figma
      body: SafeArea(
        child: Stack(
          children: [
            // Large yellow background circle (top-left, partially visible)
            Positioned(
              top: (-screenHeight * 0.28) - 50,
              left: -screenWidth * 0.4,
              child: Container(
                width: screenWidth * 2.03,
                height: screenWidth * 2.03,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFCE167), // Light yellow from Figma
                ),
              ),
            ),
            // White circle with border (middle area)
            Positioned(
              top: (screenHeight * 0.23),
              left: -screenWidth * 0.245,
              child: Container(
                width: screenWidth * 0.92,
                height: screenWidth * 0.92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: Color(0xFFFFFAE6), // Light cream border
                    width: 20,
                  ),
                ),
              ),
            ),
            // Cucumber image (exact position from Figma)
            Positioned(
              top: screenHeight * 0.04,
              left: screenWidth * 0.33,
              child: Image.asset(
                'assets/cucumber_image.png',
                width: screenWidth * 1.02,
                height: screenHeight * 0.47,
                fit: BoxFit.contain,
              ),
            ),
            // Large background rectangle (behind vegetables)
            Positioned(
              top: screenHeight * 0.35,
              left: -screenWidth * 0.44,
              child: Container(
                width: screenWidth * 1.79,
                height: screenHeight * 0.83,
                color: Colors.transparent, // Invisible container for layout
              ),
            ),
            // White circle with gradient border (lower area)
            Positioned(
              top: -screenHeight * 0.013,
              left: screenWidth * 0.315,
              child: Container(
                width: screenWidth * 1.02,
                height: screenWidth * 1.02,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.white,
                    width: 20,
                  ),
                ),
              ),
            ),
            // Light cream circle (background accent)
            Positioned(
              top: screenHeight * 0.245,
              left: screenWidth * 0.318,
              child: Container(
                width: screenWidth * 0.72,
                height: screenWidth * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFFAE6), // Light cream
                ),
              ),
            ),
            // Lettuce image (exact position from Figma)
            Positioned(
              top: screenHeight * 0.14,
              left: -screenWidth * 0.42,
              child: Image.asset(
                'assets/lettuce_image.png',
                width: screenWidth * 1.23,
                height: screenHeight * 0.57,
                fit: BoxFit.contain,
              ),
            ),
            // Green blur circle (accent element)

            // Status bar (top of screen)

            // Language selector at top right (exactly as in Figma)
            Positioned(
              top: 68,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE3E3E3), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      child:
                          Icon(Icons.language, size: 16, color: Colors.white),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'English',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 10, color: Colors.white),
                  ],
                ),
              ),
            ),

            // MrSheaf logo (exact position from Figma)
            Positioned(
              top: 26,
              left: 9,
              child: Image.asset(
                'assets/mr_sheaf_logo.png',
                width: 205,
                height: 236.3,
                fit: BoxFit.contain,
              ),
            ),

            // Bottom content area (exactly as in Figma)
            Positioned(
              bottom: 0,
              left: 24,
              right: 24,
              child: Container(
                width: 380,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ready to Start?',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            color: Color(0xFF693E28), // Brown color from Figma
                            letterSpacing: -0.01,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Join now and embark on your journey with delightful flavors and a diverse selection!',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF999999), // Grey color from Figma
                            letterSpacing: -0.005,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),

                    // Buttons (exactly as in Figma)
                    Column(
                      children: [
                        // Login button
                        Container(
                          width: 380,
                          // height: 50,
                          child: ElevatedButton(
                            onPressed: () => Get.toNamed(AppRoutes.LOGIN),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFFFACD02), // Yellow from Figma
                              foregroundColor:
                                  Color(0xFF592E2C), // Dark brown from Figma
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
                                letterSpacing: -0.005,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Sign up button
                        Container(
                          width: 380,
                          // height: 50,
                          child: OutlinedButton(
                            onPressed: () => Get.toNamed(AppRoutes.SIGNUP),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Color(0xFFFACD02), // Yellow from Figma
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color: Color(0xFFFACD02), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: -0.005,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40), // Bottom padding
                  ],
                ),
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
