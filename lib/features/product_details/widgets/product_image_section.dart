import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class ProductImageSection extends GetView<ProductDetailsController> {
  const ProductImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size selector
          Obx(() => Column(
            children: [
              ...(controller.product.value?.sizes ?? ['S', 'M', 'L']).map((size) =>
                Obx(() => GestureDetector(
                  onTap: () => controller.selectSize(size),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: controller.selectedSize.value == size
                          ? const Color(0xFFFCE167) // Yellow background when selected
                          : const Color(0xFFF1F6F9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        size,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: controller.selectedSize.value == size
                              ? const Color(0xFF592E2C)
                              : const Color(0xFFC2CECD),
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ],
          )),
          
          const SizedBox(width: 40),
          
          // Main product image
          Expanded(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6F9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 17,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Obx(() {
                  final images = controller.product.value?.images ?? ['assets/images/pizza_main.png'];
                  final currentIndex = controller.currentImageIndex.value;
                  final imageUrl = images.isNotEmpty && currentIndex < images.length
                      ? images[currentIndex]
                      : 'assets/images/pizza_main.png';

                  print('🖼️ DISPLAYING IMAGE: $imageUrl');
                  print('🖼️ IMAGES LIST: $images');
                  print('🖼️ CURRENT INDEX: $currentIndex');

                  // Check if it's a network image or asset
                  if (imageUrl.startsWith('http')) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ IMAGE LOAD ERROR: $error');
                        print('❌ FAILED URL: $imageUrl');
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
                }),
              ),
            ),
          ),
          
          const SizedBox(width: 40),
          
          // Quantity selector
          Column(
            children: [
              // Plus button
              GestureDetector(
                onTap: controller.increaseQuantity,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE167), // Yellow background
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF262626), // Dark color for yellow background
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quantity display
              Obx(() => Text(
                controller.quantity.value.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF000000),
                ),
              )),
              
              const SizedBox(height: 24),
              
              // Minus button
              GestureDetector(
                onTap: controller.decreaseQuantity,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE167), // Yellow background
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Color(0xFF262626), // Dark color for yellow background
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
