import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/restaurants/controllers/all_restaurants_controller.dart';

class RestaurantsFilterChips extends GetView<AllRestaurantsController> {
  const RestaurantsFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 24),
      child: Obx(() {
        final selectedIndex = controller.selectedFilterIndex.value;
        final filterLabels = controller.filterLabels;
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filterLabels.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => controller.switchFilter(index),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    filterLabels[index],
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? const Color(0xFF592E2C) : const Color(0xFF999999),
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

