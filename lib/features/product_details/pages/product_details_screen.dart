import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';
import 'package:mrsheaf/features/product_details/widgets/product_header.dart';
import 'package:mrsheaf/features/product_details/widgets/product_image_section.dart';
import 'package:mrsheaf/features/product_details/widgets/product_images_carousel.dart';
import 'package:mrsheaf/features/product_details/widgets/product_info_section.dart';
import 'package:mrsheaf/features/product_details/widgets/additional_options_section.dart';
import 'package:mrsheaf/features/product_details/widgets/comment_input_section.dart';
import 'package:mrsheaf/features/product_details/widgets/add_to_cart_section.dart';

class ProductDetailsScreen extends GetView<ProductDetailsController> {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Background color from Figma
      body: Obx(() {
        if (controller.isLoadingProduct.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.product.value == null) {
          return const Center(
            child: Text('Product not found'),
          );
        }

        return Column(
          children: [
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60), // Status bar space
                  
                  // Header with back and favorite buttons
                  const ProductHeader(),
                  
                  const SizedBox(height: 32),
                  
                  // Product image section with size and quantity selectors
                  const ProductImageSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Product images carousel
                  const ProductImagesCarousel(),
                  
                  const SizedBox(height: 32),
                  
                  // Product info section
                  const ProductInfoSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Additional options section
                  const AdditionalOptionsSection(),

                  const SizedBox(height: 24),

                  // Comment input section
                  const CommentInputSection(),

                  const SizedBox(height: 100), // Space for bottom section
                ],
              ),
            ),
          ),
          
          // Add to cart section (fixed at bottom)
          const AddToCartSection(),
          ],
        );
      }),
    );
  }
}
