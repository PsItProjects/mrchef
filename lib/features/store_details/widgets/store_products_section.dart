import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

import '../../home/widgets/product_card.dart';

class StoreProductsSection extends GetView<StoreDetailsController> {
  const StoreProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE3E3E3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'all_product'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: 1.5,
                    color: Color(0xFF262626),
                  ),
                ),

                // Rating section
                Container(
                  // width: 54,
                  // height: 26,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/star_icon.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFACD02),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Obx(() => Text(
                        controller.storeRating.value.toString(),
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.09,
                          color: Color(0xFF262626),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Products grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 182 / 248, // Width / Height from Figma
              ),
              itemCount: controller.storeProducts.length,
              itemBuilder: (context, index) {
                final product = controller.storeProducts[index];


                return ProductCard(
                  product: product,
                  section: 'store',
                );
                return _buildProductCard(product);
              },
            )),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      width: 182,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F9).withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D5F8B).withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 62,
            offset: const Offset(0, 0),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Product image section
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6F9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 17,
                    offset: const Offset(0, -5),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 11,
                    offset: const Offset(0, -4),
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 20,
                    child: Container(
                      width: 120,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(product['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Product info section
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product['name'],
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: -0.64,
                        color: Color(0xFF1A2023),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Price section
                  Row(
                    children: [
                      Text(
                        product['price'].toString(),
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Color(0xFF1A2023),
                        ),
                      ),
                      const Text(
                        '\$',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Color(0xFFF5484A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Add to Cart button
            Container(
              width: 118,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFACD02),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.navigateToProduct(product['id']),
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Text(
                      'add_to_cart'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
