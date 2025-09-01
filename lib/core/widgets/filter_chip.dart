import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class AppFilterChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? textColor;

  const AppFilterChip({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
    this.onRemove,
    this.padding,
    this.borderRadius = 10,
    this.selectedColor,
    this.unselectedColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = text.length > 10 ? '${text.substring(0, 10)}....' : text;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? (selectedColor ?? AppColors.primaryColor)
              : (unselectedColor ?? AppColors.lightGreyTextColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayText,
              style: AppTheme.smallButtonTextStyle.copyWith(
                fontSize: 14,
                color: textColor ?? (isSelected 
                    ? AppColors.searchIconColor 
                    : AppColors.textLightColor),
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 18,
                  height: 18,
                  child: SvgPicture.asset(
                    'assets/icons/close_icon.svg',
                    width: 10.5,
                    height: 10.5,
                    colorFilter: ColorFilter.mode(
                      textColor ?? (isSelected 
                          ? AppColors.searchIconColor 
                          : AppColors.textLightColor),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CategoryFilterChip extends StatelessWidget {
  final String name;
  final String? imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.name,
    this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryColor 
              : AppColors.lightGreyColor,
          borderRadius: BorderRadius.circular(87),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackShadowColor.withOpacity(0.2),
              blurRadius: 2.45,
            ),
            BoxShadow(
              color: AppColors.blackShadowColor.withOpacity(0.1),
              blurRadius: 4.91,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon/image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.greyColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackShadowColor.withOpacity(0.25),
                    blurRadius: 0.49,
                    offset: const Offset(0, 0.61),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath ?? 'assets/images/pizza_main.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Category name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name,
                style: AppTheme.tabTextStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
                  color: isSelected
                      ? AppColors.searchIconColor
                      : AppColors.darkTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
