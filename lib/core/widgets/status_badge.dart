import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

enum StatusType { success, error, warning, info }

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
    this.padding,
    this.borderRadius = 8,
  });

  Color get backgroundColor {
    switch (type) {
      case StatusType.success:
        return AppColors.successColor;
      case StatusType.error:
        return AppColors.errorColor;
      case StatusType.warning:
        return AppColors.warningColor;
      case StatusType.info:
        return AppColors.primaryColor;
    }
  }

  Color get textColor {
    switch (type) {
      case StatusType.success:
        return AppColors.textLightColor;
      case StatusType.error:
        return AppColors.textLightColor;
      case StatusType.warning:
        return AppColors.searchIconColor;
      case StatusType.info:
        return AppColors.searchIconColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: AppTheme.statusTextStyle.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}

class TabIndicator extends StatelessWidget {
  final bool isSelected;
  final double size;
  final Color? selectedColor;

  const TabIndicator({
    super.key,
    required this.isSelected,
    this.size = 8,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected 
            ? (selectedColor ?? AppColors.primaryColor) 
            : AppColors.transparent,
      ),
    );
  }
}
