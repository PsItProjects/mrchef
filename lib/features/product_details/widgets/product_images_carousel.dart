import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class ProductImagesCarousel extends GetView<ProductDetailsController> {
  const ProductImagesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Obx(() {
        final images = controller.product.value?.images ?? ['assets/images/pizza_main.png'];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
          (index) => GestureDetector(
            onTap: () => controller.changeImage(index),
            child: Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: controller.currentImageIndex.value == index
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: () {
                  final imageUrl = images[index];
                  if (imageUrl.startsWith('http')) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/pizza_main.png',
                          fit: BoxFit.cover,
                        );
                      },
                    );
                  } else {
                    return Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                    );
                  }
                }(),
              ),
            ),
          ),
        );
      }),
    );
  }
}
