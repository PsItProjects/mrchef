import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/shipping_addresses_controller.dart';

class AddAddressButton extends GetView<ShippingAddressesController> {
  const AddAddressButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: controller.addNewAddress,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.addButtonShadowColor.withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: AppColors.darkTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
