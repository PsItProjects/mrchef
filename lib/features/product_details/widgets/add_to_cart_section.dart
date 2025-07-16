import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class AddToCartSection extends GetView<ProductDetailsController> {
  const AddToCartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Divider line
              Container(
                height: 1,
                color: const Color(0xFFE3E3E3),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              
              // Two buttons: Go to Store and Add to Cart
              Row(
                children: [
                  // Go to Store button
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.goToStore,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Go to Store',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF592E2C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Add to Cart button
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.addToCart,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF592E2C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
