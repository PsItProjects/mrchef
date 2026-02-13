import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const StoreDetailsHeader(),
                    const StoreInfoSection(),
                    const StoreActionsSection(),
                    const StoreProductsSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              Obx(() => controller.isBottomSheetVisible.value
                  ? const StoreInfoBottomSheet()
                  : const SizedBox.shrink()),
            ],
          );
        }),
      ),
    );
  }
}
