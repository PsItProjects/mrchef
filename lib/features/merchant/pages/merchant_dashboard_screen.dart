import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_main_controller.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_home_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_orders_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_messages_screen.dart';
import 'package:mrsheaf/features/profile/pages/unified_settings_screen.dart';

class MerchantDashboardScreen extends GetView<MerchantMainController> {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of screens for each tab
    final List<Widget> screens = [
      const MerchantHomeScreen(),
      const MerchantOrdersScreen(),
      const MerchantMessagesScreen(),
      const UnifiedSettingsScreen(),
    ];

    // Bottom navigation items with same styling as regular user
    return Obx(() {
      final List<Map<String, dynamic>> navItems = [
        {
          'icon': Icons.home,
          'title': 'merchant_home'.tr,
        },
        {
          'icon': Icons.shopping_cart,
          'title': 'merchant_orders'.tr,
        },
        {
          'icon': Icons.message,
          'title': 'merchant_messages'.tr,
        },
        {
          'icon': Icons.settings,
          'title': 'merchant_settings'.tr,
        },
      ];

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
        bottomNavigationBar: Container(
          height: 98,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 18,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Row(
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = controller.currentIndex.value == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(index),
                      behavior: HitTestBehavior.opaque, // هذا يجعل كامل المنطقة قابلة للضغط
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon
                            Icon(
                              item['icon'],
                              size: 24,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.lightGreyTextColor,
                            ),
                            const SizedBox(height: 4),
                            // Title
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.lightGreyTextColor,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}
