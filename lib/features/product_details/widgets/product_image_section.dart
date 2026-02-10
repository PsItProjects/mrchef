import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';
import 'package:mrsheaf/features/product_details/widgets/image_viewer_modal.dart';

class ProductImageSection extends GetView<ProductDetailsController> {
  const ProductImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = controller.product.value?.images ??
          ['https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop'];
      final hasMultipleImages = images.length > 1;

      return SizedBox(
        height: 340,
        child: Stack(
          children: [
            // Full-width image carousel — tap to open viewer
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) => controller.changeImage(index),
              itemBuilder: (context, index) {
                final imageUrl = images[index];
                return GestureDetector(
                  onTap: () {
                    ImageViewerModal.show(
                      context,
                      images: images,
                      initialIndex: controller.currentImageIndex.value,
                    );
                  },
                  child: _buildImage(imageUrl),
                );
              },
            ),

            // Bottom gradient overlay for smooth transition to content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.8),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tap-to-zoom button (on top of gradient)
            Positioned(
              bottom: 36,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  ImageViewerModal.show(
                    context,
                    images: images,
                    initialIndex: controller.currentImageIndex.value,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Icon(Icons.touch_app_rounded, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
            ),

            // Page indicator dots
            if (hasMultipleImages)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: controller.currentImageIndex.value == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: controller.currentImageIndex.value == index
                            ? AppColors.primaryColor
                            : Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),

            // Image counter badge
            if (hasMultipleImages)
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${controller.currentImageIndex.value + 1}/${images.length}',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF5F5F5),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primaryColor,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF5F5F5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_rounded, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    'image_not_available'.tr,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
  }
}
