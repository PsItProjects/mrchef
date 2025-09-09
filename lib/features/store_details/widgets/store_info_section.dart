import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class StoreInfoSection extends GetView<StoreDetailsController> {
  const StoreInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Store name and location
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => Text(
                controller.storeName.value,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  letterSpacing: -0.24,
                  color: Color(0xFF262626),
                ),
              )),
              
              const SizedBox(height: 4),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/location.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF5E5E5E),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                    controller.storeLocation.value,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF5E5E5E),
                    ),
                  )),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Store description
          Obx(() => Text(
            controller.storeDescription.value,
            style: const TextStyle(
              fontFamily: 'Givonic',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.35,
              color: Color(0xFF282828),
            ),
          )),

          const SizedBox(height: 16),

          // Store stats (Rating, Reviews, Products)
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rating
              _buildStatItem(
                icon: Icons.star,
                iconColor: Colors.amber,
                value: controller.storeRating.value.toStringAsFixed(1),
                label: 'التقييم',
              ),

              // Reviews
              _buildStatItem(
                icon: Icons.reviews,
                iconColor: AppColors.primaryColor,
                value: controller.reviewsCount.value.toString(),
                label: 'التقييمات',
              ),

              // Products
              _buildStatItem(
                icon: Icons.restaurant_menu,
                iconColor: AppColors.primaryColor,
                value: controller.totalProducts.value.toString(),
                label: 'المنتجات',
              ),
            ],
          )),

          const SizedBox(height: 16),

          // Delivery info
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Delivery fee
                _buildDeliveryInfo(
                  icon: Icons.delivery_dining,
                  title: 'رسوم التوصيل',
                  value: '${controller.deliveryFee.value.toStringAsFixed(0)} ر.س',
                ),

                // Minimum order
                _buildDeliveryInfo(
                  icon: Icons.shopping_cart,
                  title: 'أقل طلب',
                  value: '${controller.minimumOrder.value.toStringAsFixed(0)} ر.س',
                ),

                // Preparation time
                _buildDeliveryInfo(
                  icon: Icons.timer,
                  title: 'وقت التحضير',
                  value: '${controller.preparationTime.value} دقيقة',
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Color(0xFF5E5E5E),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: Color(0xFF5E5E5E),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF262626),
          ),
        ),
      ],
    );
  }
}
