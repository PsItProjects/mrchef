import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class CircularIconButton extends StatelessWidget {
  final String? iconPath;
  final IconData? iconData;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final List<BoxShadow>? boxShadow;

  const CircularIconButton({
    super.key,
    this.iconPath,
    this.iconData,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
    this.iconSize = 24,
    this.boxShadow,
  }) : assert(iconPath != null || iconData != null, 'Either iconPath or iconData must be provided');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.favoriteButtonColor,
          shape: BoxShape.circle,
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: AppColors.blackShadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: iconPath != null
              ? SvgPicture.asset(
                  iconPath!,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: iconColor != null
                      ? ColorFilter.mode(
                          iconColor!,
                          BlendMode.srcIn,
                        )
                      : null,
                )
              : Icon(
                  iconData!,
                  size: iconSize,
                  color: iconColor ?? AppColors.darkTextColor,
                ),
        ),
      ),
    );
  }
}
