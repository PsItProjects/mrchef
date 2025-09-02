import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chat icon
          GestureDetector(
            onTap: controller.onChatTap,
            child: SvgPicture.asset(
              'assets/icons/chat_icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF262626), // Dark color from Figma
                BlendMode.srcIn,
              ),
            ),
          ),
          
          // Home title
          Text(
            'home'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textDarkColor,
            ),
          ),
          
          // Notification icon
          GestureDetector(
            onTap: controller.onNotificationTap,
            child: SvgPicture.asset(
              'assets/icons/notification_icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF262626), // Dark color from Figma
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
