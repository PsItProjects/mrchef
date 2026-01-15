import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';

class ProductCard extends GetView<HomeController> {
  final Map<String, dynamic> product;
  final String section;

  const ProductCard({
    super.key,
    required this.product,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this card is in a horizontal list (has margin) or grid (no margin)
    final bool isInHorizontalList = section != 'search';

    return GestureDetector(
      onTap: () {
        final productId = product['id'];
        print('👆 PRODUCT CARD: Clicked on product!');
        print('   Product Data: ${product.toString()}');
        print('   Product ID: $productId');
        print('   Product Name: ${product['name']}');
        
        if (productId == null) {
          Get.snackbar(
            'خطأ',
            'معرف المنتج غير صحيح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        print('➡️ PRODUCT CARD: Navigating to product details with ID: $productId');
        Get.toNamed(
          AppRoutes.PRODUCT_DETAILS,
          arguments: {'productId': productId},
        );
      },
      child: Container(
      width: isInHorizontalList ? 182 : null, // Full width in grid
      height: isInHorizontalList ? 240 : null, // Auto height in grid
      margin: isInHorizontalList ? const EdgeInsets.only(right: 16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image with background circle
            Container(
              width: isInHorizontalList ? 120 : 110,
              height: isInHorizontalList ? 120 : 110,
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundColor.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackShadowColor.withOpacity(0.1),
                    blurRadius: 17,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Product image
                  Positioned(
                    top: isInHorizontalList ? 15 : 10,
                    left: isInHorizontalList ? 10 : 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: () {
                        // Try both 'image' and 'primary_image' keys
                        final imageUrl = (product['image'] ?? product['primary_image'] ?? '') as String;
                        final imageSize = isInHorizontalList ? 100.0 : 90.0;
                        final imageHeight = isInHorizontalList ? 90.0 : 85.0;

                        if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
                          return Image.network(
                            imageUrl,
                            width: imageSize,
                            height: imageHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/burger.png',
                                width: imageSize,
                                height: imageHeight,
                                fit: BoxFit.cover,
                              );
                            },
                          );
                        } else {
                          return Image.asset(
                            imageUrl.isNotEmpty ? imageUrl : 'assets/images/burger.png',
                            width: imageSize,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          );
                        }
                      }(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product name and price
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product['name'] ?? 'Special beef burger',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              fontSize: isInHorizontalList ? 12 : 13,
                              color: const Color(0xFF1A2023),
                              letterSpacing: -0.04,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyHelper.formatPrice(double.tryParse('${product['price'] ?? 16}') ?? 16.0),
                            style: AppTheme.priceTextStyle.copyWith(
                              fontSize: isInHorizontalList ? 14 : 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Add to Cart button
                    GestureDetector(
                      onTap: () => controller.addToCart(product['id']),
                      child: Container(
                        width: double.infinity,
                        height: isInHorizontalList ? 26 : 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: isInHorizontalList ? 10 : 11,
                              color: const Color(0xFF592E2C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
