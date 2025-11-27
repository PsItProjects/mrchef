import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';

class MyOrdersTabs extends GetView<MyOrdersController> {
  const MyOrdersTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
      child: Obx(() {
        // Access observable to trigger reactivity
        final selectedIndex = controller.selectedTabIndex.value;
        final tabLabels = controller.tabLabels;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tabLabels.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => controller.switchTab(index),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    tabLabels[index],
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? Colors.white : const Color(0xFF999999),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
