import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';

class CategoriesHeader extends GetView<CategoriesController> {
  const CategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chat icon
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'Chat',
                'Chat functionality coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: SvgPicture.asset(
              'assets/icons/chat_icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF262626),
                BlendMode.srcIn,
              ),
            ),
          ),
          
          // Categories title
          const Text(
            'Categories',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),
          
          // Notification icon
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'Notifications',
                'Notifications functionality coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: SvgPicture.asset(
              'assets/icons/notification_icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF262626),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
