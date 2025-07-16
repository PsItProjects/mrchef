import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';

class EmptyOrdersWidget extends GetView<MyOrdersController> {
  const EmptyOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty orders illustration
          Container(
            width: 380,
            height: 299.73,
            child: Image.asset(
              'assets/images/empty_orders_illustration.png',
              fit: BoxFit.contain,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Empty orders text
          Column(
            children: [
              const Text(
                'Your Order History is Emty',
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
                width: 274,
                child: const Text(
                  'You don\'t an active order at the time, Go home to shopping.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Go to home page button
          Container(
            width: 380,
            // height: 50,
            child: ElevatedButton(
              onPressed: controller.goToHomePage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Go to home page',
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
                'Add Sample Orders (Test)',
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
