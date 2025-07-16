import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/shipping_addresses_controller.dart';
import 'package:mrsheaf/features/profile/widgets/shipping_addresses_header.dart';
import 'package:mrsheaf/features/profile/widgets/addresses_list.dart';
import 'package:mrsheaf/features/profile/widgets/empty_addresses_widget.dart';
import 'package:mrsheaf/features/profile/widgets/add_address_button.dart';

class ShippingAddressesScreen extends GetView<ShippingAddressesController> {
  const ShippingAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const ShippingAddressesHeader(),
            
            // Content
            Expanded(
              child: Obx(() {
                if (!controller.hasAddresses) {
                  return const EmptyAddressesWidget();
                } else {
                  return const AddressesList();
                }
              }),
            ),
            
            // Add address button (floating)
            const AddAddressButton(),
          ],
        ),
      ),
    );
  }
}
