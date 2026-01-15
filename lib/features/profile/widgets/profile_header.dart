import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/widgets/language_switcher.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chat icon (as per Figma)
          GestureDetector(
            onTap: () {
              Get.toNamed('/conversations');
            },
            child: Container(
              width: 24,
              height: 24,
              child: Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: const Color(0xFF262626),
              ),
            ),
          ),
          
          // Title
          Text(
            TranslationHelper.tr('settings'),
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),
          
          // Language switcher
          const LanguageSwitcher(
            isCompact: true,
            showLabel: false,
          ),
        ],
      ),
    );
  }
}
