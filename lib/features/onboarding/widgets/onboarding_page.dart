import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration with circular background exactly like Figma
          Container(
            width: screenHeight * 0.35, // 35% of screen height
            height: screenHeight * 0.35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor
                  .withAlpha(30), // Light yellow background
            ),
            child: Center(
              child: Image.asset(
                image,
                height: screenHeight * 0.25, // 25% of screen height
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05), // 5% of screen height
          Text(
            title.tr,
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.02), // 2% of screen height
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              description.tr,
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
