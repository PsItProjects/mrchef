import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';

class EmptyCartWidget extends GetView<CartController> {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty cart illustration
          Container(
            width: 426,
            height: 336,
            child: Image.asset(
              'assets/images/empty_cart_illustration.png',
              fit: BoxFit.contain,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Empty cart text
          Column(
            children: [
              Text(
                'cart_empty'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF262626),
                  letterSpacing: -0.005,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'add_items_to_cart'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF5E5E5E),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Go to Home page button
          Container(
            // width: 380,
            // height: 50,
            padding: EdgeInsets.symmetric(horizontal: 20),

            child: ElevatedButton(
              onPressed: controller.goToHomePage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'continue_shopping'.tr,
                style: const TextStyle(
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


        ],
      ),
    );
  }
}
