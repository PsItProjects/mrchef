import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/my_reviews_controller.dart';

class EmptyReviewsWidget extends GetView<MyReviewsController> {
  const EmptyReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty reviews illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Color(0xFFCCCCCC),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Empty reviews text
          Column(
            children: [
              const Text(
                'No Reviews Yet',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF1C1C1C),
                  letterSpacing: -0.005,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                width: 285,
                child: const Text(
                  'You haven\'t written any reviews yet. Order some food and share your experience!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF5E5E5E),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Go to home page button
          Container(
            width: 380,
            // height: 50,
            child: ElevatedButton(
              onPressed: () => Get.offAllNamed('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF592E2C),
                  letterSpacing: -0.005,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Test button to add sample data
          Container(
            width: 380,
            // height: 50,
            child: ElevatedButton(
              onPressed: controller.addSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF592E2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add Sample Reviews (Test)',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: -0.005,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
