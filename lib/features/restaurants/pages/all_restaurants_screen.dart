import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/restaurants/controllers/all_restaurants_controller.dart';
import 'package:mrsheaf/features/restaurants/widgets/all_restaurants_header.dart';
import 'package:mrsheaf/features/restaurants/widgets/restaurants_filter_chips.dart';
import 'package:mrsheaf/features/restaurants/widgets/restaurants_grid.dart';

class AllRestaurantsScreen extends GetView<AllRestaurantsController> {
  const AllRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header
            const AllRestaurantsHeader(),
            
            const SizedBox(height: 24),
            
            // Filter chips
            const RestaurantsFilterChips(),
            
            const SizedBox(height: 16),
            
            // Restaurants grid
            Expanded(
              child: Obx(() {
                // Show loading indicator
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }
                
                // Show empty state
                if (controller.filteredRestaurants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_restaurants_found'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Show restaurants grid
                return const RestaurantsGrid();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

