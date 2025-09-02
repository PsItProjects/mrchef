import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
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
          title: TranslationHelper.tr('my_orders'),
          subtitle: controller.orderCountText,
          onTap: controller.navigateToMyOrders,
        )),

        const SizedBox(height: 16),

        // Shipping Addresses
        Obx(() => ProfileMenuItem(
          title: TranslationHelper.tr('shipping_addresses'),
          subtitle: controller.addressCountText,
          onTap: controller.navigateToShippingAddresses,
        )),

        const SizedBox(height: 16),

        // Payment Method
        Obx(() => ProfileMenuItem(
          title: TranslationHelper.tr('payment_methods'),
          subtitle: controller.cardCountText,
          onTap: controller.navigateToPaymentMethods,
        )),

        const SizedBox(height: 16),

        // My reviews
        Obx(() => ProfileMenuItem(
          title: TranslationHelper.tr('my_reviews'),
          subtitle: controller.reviewCountText,
          onTap: controller.navigateToMyReviews,
        )),
        
        const SizedBox(height: 16),
        
        // Setting
        ProfileMenuItem(
          title: 'settings'.tr,
          subtitle: 'notification_password_faq_content'.tr,
          onTap: controller.navigateToSettings,
        ),
        
        const SizedBox(height: 16),
        
        // Log out
        ProfileMenuItem(
          title: 'logout'.tr,
          subtitle: null,
          isLogout: true,
          onTap: controller.logout,
        ),
      ],
    );
  }
}
