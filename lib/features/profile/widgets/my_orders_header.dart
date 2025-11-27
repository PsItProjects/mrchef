import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';

class MyOrdersHeader extends GetView<MyOrdersController> {
  const MyOrdersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value) {
        // Search mode
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => controller.stopSearch(),
                child: Container(
                  width: 24,
                  height: 24,
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Color(0xFF262626),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Search input
              Expanded(
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => controller.updateSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    color: Color(0xFF262626),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Normal mode
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 24,
                height: 24,
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Color(0xFF262626),
                ),
              ),
            ),

            // Title
            const Text(
              'My Order',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF262626),
              ),
            ),

            // Search button
            GestureDetector(
              onTap: () => controller.startSearch(),
              child: Container(
                width: 24,
                height: 24,
                child: const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF262626),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
