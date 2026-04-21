import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/favorites/pages/favorites_screen.dart';
import 'package:mrsheaf/features/home/controllers/main_controller.dart';
import 'package:mrsheaf/features/home/pages/cart_screen.dart';
import 'package:mrsheaf/features/home/pages/categories_screen.dart';
import 'package:mrsheaf/features/home/pages/home_screen.dart';
import 'package:mrsheaf/features/home/pages/profile_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_home_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_messages_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_orders_screen.dart';
import 'package:mrsheaf/features/profile/pages/unified_settings_screen.dart';

/// Unified role-aware shell.
/// Renders customer tabs (5) when in customer mode and merchant tabs (4) when
/// in merchant mode. Switching role rebuilds the shell IN PLACE — no route
/// navigation, no Get.offAllNamed, so the bottom nav and settings tab stay
/// perfectly synchronized and there is no freeze.
class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isMerchant = _isMerchantMode();
        final screens = isMerchant ? _merchantScreens : _customerScreens;
        final idx = controller.currentIndex.value
            .clamp(0, screens.length - 1)
            .toInt();
        return IndexedStack(
          // Force full rebuild when role flips so widgets dispose cleanly.
          key: ValueKey(isMerchant ? 'merchant-shell' : 'customer-shell'),
          index: idx,
          children: screens,
        );
      }),
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
            child: Obx(() {
              final isMerchant = _isMerchantMode();
              final navItems = isMerchant ? _merchantNavItems() : _customerNavItems();
              final maxIdx = navItems.length - 1;
              final selected = controller.currentIndex.value
                  .clamp(0, maxIdx)
                  .toInt();
              return Row(
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = selected == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(index),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: item['icon'] is String
                                ? _buildSvgNavIcon(
                                    item['icon'] as String,
                                    item['fallbackIcon'] as IconData,
                                    isSelected
                                        ? AppColors.primaryColor
                                        : AppColors.lightGreyTextColor,
                                  )
                                : Icon(
                                    item['icon'] as IconData,
                                    size: 24,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : AppColors.lightGreyTextColor,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['title'] as String,
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
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Customer 5-tab list — Settings is always the LAST tab.
  static const List<Widget> _customerScreens = [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(),
    FavoritesScreen(),
    ProfileScreen(), // wraps UnifiedSettingsScreen
  ];

  // Merchant 4-tab list — Settings is always the LAST tab.
  static const List<Widget> _merchantScreens = [
    MerchantHomeScreen(),
    MerchantOrdersScreen(),
    MerchantMessagesScreen(),
    UnifiedSettingsScreen(),
  ];

  List<Map<String, dynamic>> _customerNavItems() => [
        {
          'icon': 'assets/icons/home_icon.svg',
          'title': 'home'.tr,
          'fallbackIcon': Icons.home_outlined,
        },
        {
          'icon': 'assets/icons/category_icon.svg',
          'title': 'categories'.tr,
          'fallbackIcon': Icons.category_outlined,
        },
        {
          'icon': 'assets/icons/cart_icon.svg',
          'title': 'cart'.tr,
          'fallbackIcon': Icons.shopping_cart_outlined,
        },
        {
          'icon': 'assets/icons/heart_icon.svg',
          'title': 'favorites'.tr,
          'fallbackIcon': Icons.favorite_outline,
        },
        {
          'icon': 'assets/icons/settings_icon.svg',
          'title': 'profile'.tr,
          'fallbackIcon': Icons.settings_outlined,
        },
      ];

  List<Map<String, dynamic>> _merchantNavItems() => [
        {'icon': Icons.home, 'title': 'merchant_home'.tr},
        {'icon': Icons.shopping_cart, 'title': 'merchant_orders'.tr},
        {'icon': Icons.message, 'title': 'merchant_messages'.tr},
        {'icon': Icons.settings, 'title': 'merchant_settings'.tr},
      ];

  /// Source of truth for shell role. Reads ProfileSwitchService when ready,
  /// falls back to AuthService.userType for the very first frame after login.
  bool _isMerchantMode() {
    try {
      if (Get.isRegistered<ProfileSwitchService>()) {
        final s = Get.find<ProfileSwitchService>().accountStatus.value;
        if (s != null) return s.isMerchantMode;
      }
    } catch (_) {}
    try {
      return Get.find<AuthService>().userType.value == 'merchant';
    } catch (_) {}
    return false;
  }

  Widget _buildSvgNavIcon(String svgPath, IconData fallbackIcon, Color color) {
    return SvgPicture.asset(
      svgPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (context) => Icon(
        fallbackIcon,
        size: 24,
        color: color,
      ),
    );
  }
}
