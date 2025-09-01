import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/main_controller.dart';
import 'package:mrsheaf/features/home/pages/cart_screen.dart';
import 'package:mrsheaf/features/home/pages/categories_screen.dart';
import 'package:mrsheaf/features/favorites/pages/favorites_screen.dart';
import 'package:mrsheaf/features/home/pages/home_screen.dart';
import 'package:mrsheaf/features/home/pages/profile_screen.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of screens for each tab
    final List<Widget> screens = [
      const HomeScreen(),
      const CategoriesScreen(),
      const CartScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    // Bottom navigation items with SVG icons
    final List<Map<String, dynamic>> navItems = [
      {
        'icon': 'assets/icons/home_icon.svg',
        'title': 'home'.tr,
        'fallbackIcon': Icons.home,
      },
      {
        'icon': 'assets/icons/category_icon.svg',
        'title': 'categories'.tr,
        'fallbackIcon': Icons.category,
      },
      {
        'icon': 'assets/icons/cart_icon.svg',
        'title': 'cart'.tr,
        'fallbackIcon': Icons.shopping_cart,
      },
      {
        'icon': 'assets/icons/heart_icon.svg',
        'title': 'favorites'.tr,
        'fallbackIcon': Icons.favorite,
      },
      {
        'icon': 'assets/icons/profile_icon.svg',
        'title': 'profile'.tr,
        'fallbackIcon': Icons.person,
      },
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: screens,
          )),
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
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = controller.currentIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.changeTab(index),
                  child: Container(
                    // width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            item['icon'],
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              isSelected
                                ? AppColors.primaryColor
                                : AppColors.lightGreyTextColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        ),
                      ],
                    ),
                  ),
                );
              }),
            )),
          ),
        ),
      ),
    );
  }
}
