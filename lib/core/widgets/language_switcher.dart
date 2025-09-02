import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const LanguageSwitcher({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService.instance;

    return Obx(() {
      final currentLanguage = languageService.currentLanguage;
      final isArabic = currentLanguage == 'ar';

      if (isCompact) {
        return _buildCompactSwitcher(isArabic);
      } else {
        return _buildFullSwitcher(isArabic);
      }
    });
  }

  Widget _buildCompactSwitcher(bool isArabic) {
    return GestureDetector(
      onTap: _toggleLanguage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: iconColor ?? AppColors.textDarkColor,
            ),
            const SizedBox(width: 4),
            Text(
              isArabic ? 'ع' : 'EN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.textDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullSwitcher(bool isArabic) {
    return GestureDetector(
      onTap: _showLanguageDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 18,
              color: iconColor ?? AppColors.textDarkColor,
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                isArabic ? 'العربية' : 'English',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppColors.textDarkColor,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: iconColor ?? AppColors.textDarkColor,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLanguage() {
    final languageService = LanguageService.instance;
    final newLanguage = languageService.isArabic ? 'en' : 'ar';
    languageService.setLanguage(newLanguage);
    Get.updateLocale(Locale(newLanguage));
  }

  void _showLanguageDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TranslationHelper.tr('language'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption('en', 'English', 'English'),
              const SizedBox(height: 12),
              _buildLanguageOption('ar', 'العربية', 'Arabic'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        TranslationHelper.tr('cancel'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String englishName) {
    final languageService = LanguageService.instance;
    final isSelected = languageService.currentLanguage == code;

    return GestureDetector(
      onTap: () {
        languageService.setLanguage(code);
        Get.updateLocale(Locale(code));
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getLanguageColor(code),
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : AppColors.textDarkColor,
                    ),
                  ),
                  if (name != englishName)
                    Text(
                      englishName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(String code) {
    switch (code) {
      case 'ar':
        return Colors.green;
      case 'en':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Extension for easy access
extension LanguageSwitcherExtension on Widget {
  Widget withLanguageSwitcher({
    bool showInAppBar = true,
    bool isCompact = false,
  }) {
    if (!showInAppBar) return this;
    
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: LanguageSwitcher(isCompact: isCompact),
          ),
        ],
      ),
      body: this,
    );
  }
}
