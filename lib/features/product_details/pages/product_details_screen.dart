import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';
import 'package:mrsheaf/features/product_details/widgets/product_header.dart';
import 'package:mrsheaf/features/product_details/widgets/product_image_section.dart';
import 'package:mrsheaf/features/product_details/widgets/product_info_section.dart';
import 'package:mrsheaf/features/product_details/widgets/size_selection_section.dart';
import 'package:mrsheaf/features/product_details/widgets/additional_options_section.dart';
import 'package:mrsheaf/features/product_details/widgets/add_to_cart_section.dart';
import 'package:mrsheaf/features/product_details/widgets/reviews_preview_section.dart';
import 'package:mrsheaf/features/product_details/widgets/product_details_shimmer.dart';

class ProductDetailsScreen extends GetView<ProductDetailsController> {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoadingProduct.value) {
          return const ProductDetailsShimmer();
        }

        if (controller.product.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'product_not_found'.tr,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: controller.goBack,
                  child: Text(
                    'go_back'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Hero image with overlaid header
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        const ProductImageSection(),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 0,
                          right: 0,
                          child: const ProductHeader(),
                        ),
                      ],
                    ),
                  ),

                  // Product info
                  const SliverToBoxAdapter(child: ProductInfoSection()),

                  // Divider
                  SliverToBoxAdapter(child: _buildDivider()),

                  // Size selection
                  const SliverToBoxAdapter(child: SizeSelectionSection()),

                  // Divider (conditional)
                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (controller.product.value?.rawSizes.isEmpty ?? true) {
                        return const SizedBox.shrink();
                      }
                      return _buildDivider();
                    }),
                  ),

                  // Additional options
                  const SliverToBoxAdapter(child: AdditionalOptionsSection()),

                  // Divider before reviews
                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (controller.additionalOptions.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildDivider();
                    }),
                  ),

                  // Reviews preview section
                  const SliverToBoxAdapter(child: ReviewsPreviewSection()),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),

            // Fixed bottom bar
            const AddToCartSection(),
          ],
        );
      }),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFF0F0F0),
    );
  }
}
