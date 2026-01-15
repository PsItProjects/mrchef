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
              Text(
                'no_reviews_yet'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF1C1C1C),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: 285,
                child: Text(
                  'no_reviews_message'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0xFF5E5E5E),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Go to home page button
          SizedBox(
            width: 380,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Get.offAllNamed('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'start_shopping'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.3,
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
