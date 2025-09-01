import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/theme_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/widgets/circular_icon_button.dart';

class ThemeToggleButton extends StatelessWidget {
  final double? size;
  final Color? lightModeColor;
  final Color? darkModeColor;

  const ThemeToggleButton({
    super.key,
    this.size,
    this.lightModeColor,
    this.darkModeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      init: ThemeService.instance,
      builder: (themeService) {
        return Obx(() => CircularIconButton(
          iconData: themeService.isDarkMode 
              ? Icons.light_mode 
              : Icons.dark_mode,
          onTap: themeService.toggleTheme,
          size: size ?? 48,
          backgroundColor: themeService.isDarkMode
              ? (darkModeColor ?? AppColors.darkSurfaceColor)
              : (lightModeColor ?? AppColors.surfaceColor),
          iconColor: themeService.isDarkMode
              ? AppColors.primaryColor
              : AppColors.secondaryColor,
        ));
      },
    );
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      init: ThemeService.instance,
      builder: (themeService) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackShadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Mode',
                style: AppTheme.subheadingStyle.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => Column(
                children: [
                  _buildThemeOption(
                    context,
                    'Light',
                    Icons.light_mode,
                    ThemeMode.light,
                    themeService.themeMode == ThemeMode.light,
                    () => themeService.setLightTheme(),
                  ),
                  const SizedBox(height: 8),
                  _buildThemeOption(
                    context,
                    'Dark',
                    Icons.dark_mode,
                    ThemeMode.dark,
                    themeService.themeMode == ThemeMode.dark,
                    () => themeService.setDarkTheme(),
                  ),
                  const SizedBox(height: 8),
                  _buildThemeOption(
                    context,
                    'System',
                    Icons.settings,
                    ThemeMode.system,
                    themeService.themeMode == ThemeMode.system,
                    () => themeService.setSystemTheme(),
                  ),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? AppColors.primaryColor
                  : Theme.of(context).iconTheme.color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTheme.bodyStyle.copyWith(
                color: isSelected 
                    ? AppColors.primaryColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
