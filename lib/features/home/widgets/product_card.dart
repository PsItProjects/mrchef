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
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.PRODUCT_DETAILS,
        arguments: {'productId': product['id'] ?? 1},
      ),
      child: Container(
      width: 182,
      // height: 240, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(right: 16),
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
              width: 120,
              height: 120,
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
                    top: 15,
                    left: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: () {
                        final imageUrl = product['primary_image'] as String? ?? '';
                        if (imageUrl.startsWith('http')) {
                          return Image.network(
                            imageUrl,
                            width: 100,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/burger.png',
                                width: 100,
                                height: 90,
                                fit: BoxFit.cover,
                              );
                            },
                          );
                        } else {
                          return Image.asset(
                            imageUrl.isNotEmpty ? imageUrl : 'assets/images/burger.png',
                            width: 100,
                            height: 90,
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
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFF1A2023),
                              letterSpacing: -0.04,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyHelper.formatPrice(double.tryParse('${product['price'] ?? 16}') ?? 16.0),
                            style: AppTheme.priceTextStyle,
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
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF592E2C),
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
