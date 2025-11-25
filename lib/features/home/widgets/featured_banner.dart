import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FeaturedBanner extends GetView<HomeController> {
  final PageController _pageController = PageController(initialPage: 0);

  // 2. List of image URLs
   final  List<String> _imageUrls = [
    'https://picsum.photos/200',
    'https://picsum.photos/200',
    'https://picsum.photos/200',
    'https://picsum.photos/200',

  ];

  FeaturedBanner({super.key});

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
            clipBehavior:Clip.antiAlias ,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.kitchenGradientStart.withOpacity(0.8),
                  AppColors.kitchenGradientStart.withOpacity(0.6),
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [

                // 3. PageView for images
                SizedBox(
                  // height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        _imageUrls[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                // 4. Dot Indicator positioned at the bottom center
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _pageController, // The controller
                      count: _imageUrls.length, // Total number of dots
                      effect: const ExpandingDotsEffect(
                        activeDotColor: AppColors.primaryColor,
                        dotColor: Colors.grey,
                        dotHeight: 10,
                        dotWidth: 10,
                        spacing: 8.0,
                      ),
                    ),
                  ),
                ),
                // Background image

              ],
            ),
          ),
          
          // const SizedBox(height: 16),
          //
          // // Carousel indicators
          // Obx(() => Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: List.generate(
          //     3, // Number of banner slides
          //     (index) => Container(
          //       margin: const EdgeInsets.symmetric(horizontal: 5),
          //       width: index == controller.currentBannerIndex.value ? 12 : 8,
          //       height: index == controller.currentBannerIndex.value ? 12 : 8,
          //       decoration: BoxDecoration(
          //         color: index == controller.currentBannerIndex.value
          //             ? AppColors.primaryColor
          //             : const Color(0xFFFEF0B4),
          //         shape: BoxShape.circle,
          //       ),
          //     ),
          //   ),
          // )),
        ],
      ),
    );
  }
}
