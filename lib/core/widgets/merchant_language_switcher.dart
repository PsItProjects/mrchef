import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/services/merchant_language_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class MerchantLanguageSwitcher extends StatelessWidget {
  final bool showLabel;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? fontSize;
  final EdgeInsets? padding;

  const MerchantLanguageSwitcher({
    super.key,
    this.showLabel = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService.instance;
    
    return Obx(() {
      final isArabic = languageService.isArabic;
      
      return GestureDetector(
        onTap: _toggleLanguage,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: 18,
                color: iconColor ?? AppColors.primaryColor,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'العربية' : 'English',
                  style: TextStyle(
                    fontSize: fontSize ?? 14,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? AppColors.textDarkColor,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.swap_horiz,
                size: 16,
                color: iconColor ?? AppColors.primaryColor,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _toggleLanguage() async {
    try {
      // Try to use MerchantLanguageService if available
      if (Get.isRegistered<MerchantLanguageService>()) {
        final merchantLanguageService = MerchantLanguageService.instance;
        await merchantLanguageService.toggleLanguage();
      } else {
        // Fallback to regular LanguageService
        final languageService = LanguageService.instance;
        final newLanguage = languageService.isArabic ? 'en' : 'ar';
        
        languageService.setLanguage(newLanguage);
        Get.updateLocale(Locale(newLanguage));
        
        ToastService.showSuccess(
          newLanguage == 'ar' 
              ? 'تم تغيير اللغة إلى العربية'
              : 'Language changed to English',
        );
      }
    } catch (e) {
      print('Error toggling language: \$e');
      ToastService.showError('failed_change_language'.tr);
    }
  }
}

// Floating Action Button version for merchants
class MerchantLanguageFAB extends StatelessWidget {
  const MerchantLanguageFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService.instance;
    
    return Obx(() {
      final isArabic = languageService.isArabic;
      
      return FloatingActionButton.small(
        onPressed: _toggleLanguage,
        backgroundColor: AppColors.primaryColor,
        child: Text(
          isArabic ? 'EN' : 'ع',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    });
  }

  void _toggleLanguage() async {
    try {
      // Try to use MerchantLanguageService if available
      if (Get.isRegistered<MerchantLanguageService>()) {
        final merchantLanguageService = MerchantLanguageService.instance;
        await merchantLanguageService.toggleLanguage();
      } else {
        // Fallback to regular LanguageService
        final languageService = LanguageService.instance;
        final newLanguage = languageService.isArabic ? 'en' : 'ar';
        
        languageService.setLanguage(newLanguage);
        Get.updateLocale(Locale(newLanguage));
        
        ToastService.showSuccess(
          newLanguage == 'ar' 
              ? 'تم تغيير اللغة إلى العربية'
              : 'Language changed to English',
        );
      }
    } catch (e) {
      print('Error toggling language: \$e');
      ToastService.showError('failed_change_language'.tr);
    }
  }
}
