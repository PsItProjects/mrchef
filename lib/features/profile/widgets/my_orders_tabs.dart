import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';

class MyOrdersTabs extends GetView<MyOrdersController> {
  const MyOrdersTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Delivered tab
          Obx(() => GestureDetector(
            onTap: () => controller.switchTab(0),
            child: Column(
              children: [
                Text(
                  'Delivered',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: controller.isDeliveredTabSelected 
                        ? FontWeight.w700 
                        : FontWeight.w600,
                    fontSize: 18,
                    color: controller.isDeliveredTabSelected 
                        ? AppColors.primaryColor 
                        : const Color(0xFF999999),
                    letterSpacing: -0.005,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isDeliveredTabSelected 
                        ? AppColors.primaryColor 
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          )),
          
          // Processing tab
          Obx(() => GestureDetector(
            onTap: () => controller.switchTab(1),
            child: Text(
              'Processing',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: controller.isProcessingTabSelected 
                    ? FontWeight.w700 
                    : FontWeight.w600,
                fontSize: 18,
                color: controller.isProcessingTabSelected 
                    ? AppColors.primaryColor 
                    : const Color(0xFF999999),
                letterSpacing: -0.005,
              ),
            ),
          )),
          
          // Canceled tab
          Obx(() => GestureDetector(
            onTap: () => controller.switchTab(2),
            child: Text(
              'Canceled',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: controller.isCanceledTabSelected 
                    ? FontWeight.w700 
                    : FontWeight.w600,
                fontSize: 18,
                color: controller.isCanceledTabSelected 
                    ? AppColors.primaryColor 
                    : const Color(0xFF999999),
                letterSpacing: -0.005,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
