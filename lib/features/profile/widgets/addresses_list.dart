import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/shipping_addresses_controller.dart';
import 'package:mrsheaf/features/profile/widgets/address_item_widget.dart';

class AddressesList extends GetView<ShippingAddressesController> {
  const AddressesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: controller.addresses.length,
        itemBuilder: (context, index) {
          final address = controller.addresses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AddressItemWidget(
              address: address,
              onEdit: () => controller.editAddress(address),
              onDelete: () => controller.deleteAddress(address),
              onSetDefault: () => controller.setDefaultAddress(address),
            ),
          );
        },
      )),
    );
  }
}
