import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/widgets/app_layout.dart';
import 'package:mrsheaf/core/widgets/app_button.dart';
import 'package:mrsheaf/features/profile/controllers/shipping_addresses_controller.dart';

class EmptyAddressesWidget extends GetView<ShippingAddressesController> {
  const EmptyAddressesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.location_on_outlined,
      title: 'no_addresses_added'.tr,
      subtitle: 'add_delivery_address_message'.tr,
      action: AppButton(
        text: 'add_address'.tr,
        onPressed: controller.addNewAddress,
        isFullWidth: false,
        width: 200,
      ),
    );
  }
}
