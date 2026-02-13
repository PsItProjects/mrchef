import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class StoreInfoSection extends GetView<StoreDetailsController> {
  const StoreInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Store name
          Obx(() => Text(
            controller.storeName.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: AppColors.textDarkColor,
              letterSpacing: -0.3,
            ),
          )),

          const SizedBox(height: 6),

          // Location
          Obx(() => controller.storeLocation.value.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        controller.storeLocation.value,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink()),

          const SizedBox(height: 18),

          // Info chips strip
          _buildInfoStrip(),

          const SizedBox(height: 16),

          // Description
          Obx(() {
            if (controller.storeDescription.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                controller.storeDescription.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            );
          }),

          Divider(color: Colors.grey.shade200, height: 1),
        ],
      ),
    );
  }

  Widget _buildInfoStrip() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              icon: Icons.delivery_dining_outlined,
              value: '${controller.deliveryFee.value.toStringAsFixed(0)} ر.س',
              label: 'delivery_fee_label'.tr,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildInfoItem(
              icon: Icons.timer_outlined,
              value: '${controller.preparationTime.value} ${'minute'.tr}',
              label: 'preparation_time_label'.tr,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildInfoItem(
              icon: Icons.shopping_bag_outlined,
              value: '${controller.minimumOrder.value.toStringAsFixed(0)} ر.س',
              label: 'minimum_order_label'.tr,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textDarkColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade200,
    );
  }
}
