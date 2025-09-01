import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius = 32,
    this.boxShadow,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultShadow = [
      BoxShadow(
        color: AppColors.shadowColor.withOpacity(0.2),
        blurRadius: 14,
        offset: const Offset(0, 0),
      ),
    ];

    Widget cardWidget = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.cardBackgroundColor.withOpacity(0.1)) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? defaultShadow,
      ),
      child: padding != null
          ? Padding(
              padding: padding!,
              child: child,
            )
          : child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

class KitchenGradientCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const KitchenGradientCard({
    super.key,
    required this.child,
    this.width = 182,
    this.height = 223,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: width,
      height: height,
      margin: margin,
      onTap: onTap,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.kitchenGradientStart.withOpacity(0.8),
          AppColors.kitchenGradientEnd.withOpacity(0.9),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowColor.withOpacity(0.2),
          blurRadius: 14,
          offset: const Offset(0, 0),
        ),
        BoxShadow(
          color: AppColors.blackShadowColor.withOpacity(0.03),
          blurRadius: 62,
          offset: const Offset(0, 0),
          spreadRadius: 0,
          blurStyle: BlurStyle.inner,
        ),
      ],
      child: child,
    );
  }
}
