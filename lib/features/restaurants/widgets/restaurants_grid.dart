import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/restaurants/controllers/all_restaurants_controller.dart';
import 'package:mrsheaf/features/restaurants/widgets/restaurant_grid_item.dart';

class RestaurantsGrid extends GetView<AllRestaurantsController> {
  const RestaurantsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final restaurants = controller.filteredRestaurants;
      
      return RefreshIndicator(
        onRefresh: controller.refreshRestaurants,
        color: const Color(0xFFFACD02),
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 182 / 223,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return RestaurantGridItem(
              restaurant: restaurant,
              onTap: () => controller.navigateToRestaurantDetails(restaurant),
            );
          },
        ),
      );
    });
  }
}

