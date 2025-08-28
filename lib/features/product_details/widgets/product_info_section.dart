import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class ProductInfoSection extends GetView<ProductDetailsController> {
  const ProductInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Obx(() => Text(
            controller.product.value?.name ?? 'Loading...',
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(0xFF262626),
              letterSpacing: -0.01,
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Rating and price section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating (clickable)
              GestureDetector(
                onTap: controller.showReviews,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/star_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.formattedRating} ${controller.formattedReviewCount}',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF262626),
                        letterSpacing: -0.005,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price
              Obx(() => Row(
                children: [
                  if (controller.product.value?.originalPrice != null) ...[
                    Text(
                      '${controller.product.value!.originalPrice!.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF999999),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Color(0xFFEB5757),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '${controller.totalPrice.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Color(0xFF262626),
                      letterSpacing: -0.01,
                    ),
                  ),
                ],
              )),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              // Message store
              Expanded(
                child: GestureDetector(
                  onTap: controller.messageStore,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/chat_small_icon.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF262626),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Message the store',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Share with friend
              Expanded(
                child: GestureDetector(
                  onTap: controller.shareWithFriend,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/send_icon.svg',
                        width: 20,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF212121),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Share with a friend',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Product code
          Obx(() => Text(
            'Product code: ${controller.product.value?.productCode ?? 'Loading...'}',
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF262626),
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Description
          Obx(() => Text(
            controller.product.value?.description ?? 'Loading description...',
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF5E5E5E),
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          )),
        ],
      ),
    );
  }
}
