import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';

class FeaturedBanner extends GetView<HomeController> {
  const FeaturedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Main banner container
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFBA8D13).withOpacity(0.8),
                  const Color(0xFFBA8D13).withOpacity(0.6),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/banner_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Food image overlay
                Positioned(
                  right: 0,
                  top: 30,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.asset(
                      'assets/images/banner_food.png',
                      width: 311,
                      height: 188,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Content overlay
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF0B4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Taste the best foods in our group of stores',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: AppColors.primaryColor,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Carousel indicators
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3, // Number of banner slides
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: index == controller.currentBannerIndex.value ? 12 : 8,
                height: index == controller.currentBannerIndex.value ? 12 : 8,
                decoration: BoxDecoration(
                  color: index == controller.currentBannerIndex.value
                      ? AppColors.primaryColor
                      : const Color(0xFFFEF0B4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
