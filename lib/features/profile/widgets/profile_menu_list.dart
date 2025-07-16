import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';
import 'package:mrsheaf/features/profile/widgets/profile_menu_item.dart';

class ProfileMenuList extends GetView<ProfileController> {
  const ProfileMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // My Order
        Obx(() => ProfileMenuItem(
          title: 'My Order',
          subtitle: controller.orderCountText,
          onTap: controller.navigateToMyOrders,
        )),
        
        const SizedBox(height: 16),
        
        // Shipping Addresses
        Obx(() => ProfileMenuItem(
          title: 'Shipping Addresses',
          subtitle: controller.addressCountText,
          onTap: controller.navigateToShippingAddresses,
        )),
        
        const SizedBox(height: 16),
        
        // Payment Method
        Obx(() => ProfileMenuItem(
          title: 'Payment Method',
          subtitle: controller.cardCountText,
          onTap: controller.navigateToPaymentMethods,
        )),
        
        const SizedBox(height: 16),
        
        // My reviews
        Obx(() => ProfileMenuItem(
          title: 'My reviews',
          subtitle: controller.reviewCountText,
          onTap: controller.navigateToMyReviews,
        )),
        
        const SizedBox(height: 16),
        
        // Setting
        ProfileMenuItem(
          title: 'Setting',
          subtitle: 'Notification, Password, FAQ, Content',
          onTap: controller.navigateToSettings,
        ),
        
        const SizedBox(height: 16),
        
        // Log out
        ProfileMenuItem(
          title: 'Log out',
          subtitle: null,
          isLogout: true,
          onTap: controller.logout,
        ),
      ],
    );
  }
}
