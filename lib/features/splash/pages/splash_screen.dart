import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/splash/controllers/splash_controller.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.splashBackgroundColor, // White background from Figma
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo exactly as shown in Figma
            Image.asset(
              'assets/mr_sheaf_logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            // Tagline exactly as shown in Figma
            const Text(
              'Satisfy your hunger',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.brownTextColor,
              ),
            ),
            const Text(
              'with just a few clicks',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.brownTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
