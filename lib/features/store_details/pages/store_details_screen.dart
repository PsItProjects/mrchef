import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';
import 'package:mrsheaf/features/store_details/widgets/store_details_header.dart';
import 'package:mrsheaf/features/store_details/widgets/store_info_section.dart';
import 'package:mrsheaf/features/store_details/widgets/store_actions_section.dart';
import 'package:mrsheaf/features/store_details/widgets/store_products_section.dart';
import 'package:mrsheaf/features/store_details/widgets/store_info_bottom_sheet.dart';

class StoreDetailsScreen extends GetView<StoreDetailsController> {
  const StoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Background color from Figma
      body: Obx(() {
        // Show loading indicator while data is being fetched
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFACD02),
            ),
          );
        }

        return Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Store header with image and navigation
                  const StoreDetailsHeader(),
                  
                  // Store information section
                  const StoreInfoSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Store actions (Message and More buttons)
                  const StoreActionsSection(),
                  
                  const SizedBox(height: 16),
                  
                  // All Products section
                  const StoreProductsSection(),
                  
                  // const SizedBox(height: 100), // Bottom padding for safe area
                ],
              ),
            ),
            
            // Bottom sheet overlay
            Obx(() => controller.isBottomSheetVisible.value
                ? const StoreInfoBottomSheet()
                : const SizedBox.shrink()),
          ],
        );
      }),
    );
  }
}
