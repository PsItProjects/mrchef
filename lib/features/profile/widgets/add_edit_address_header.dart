import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/add_edit_address_controller.dart';

class AddEditAddressHeader extends GetView<AddEditAddressController> {
  const AddEditAddressHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
          Text(
            controller.screenTitle,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),
          
          // Search button
          GestureDetector(
            onTap: () {
              // TODO: Implement search functionality
              Get.snackbar(
                'Search',
                'Search functionality coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
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
  }
}
