import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

enum AppButtonType { primary, secondary, danger, success, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final bool iconFirst;
  final double borderRadius;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.padding,
    this.icon,
    this.iconFirst = true,
    this.borderRadius = 12,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textColor = _getTextColor();
    final effectiveTextStyle = textStyle ?? _getDefaultTextStyle().copyWith(color: textColor);

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        : _buildButtonContent(effectiveTextStyle);

    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonChild,
    );

    if (isFullWidth && width == null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (icon == null) {
      return Text(text, style: textStyle);
    }

    final children = iconFirst
        ? [icon!, const SizedBox(width: 8), Text(text, style: textStyle)]
        : [Text(text, style: textStyle), const SizedBox(width: 8), icon!];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case AppButtonType.primary:
        return AppTheme.primaryButtonStyle.copyWith(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          ),
          padding: padding != null 
              ? MaterialStateProperty.all(padding)
              : null,
        );
      case AppButtonType.secondary:
        return AppTheme.secondaryButtonStyle.copyWith(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          ),
          padding: padding != null 
              ? MaterialStateProperty.all(padding)
              : null,
        );
      case AppButtonType.danger:
        return AppTheme.dangerButtonStyle.copyWith(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          ),
          padding: padding != null 
              ? MaterialStateProperty.all(padding)
              : null,
        );
      case AppButtonType.success:
        return AppTheme.successButtonStyle.copyWith(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          ),
          padding: padding != null 
              ? MaterialStateProperty.all(padding)
              : null,
        );
      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          backgroundColor: AppColors.transparent,
          side: BorderSide(color: AppColors.primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          elevation: 0,
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.searchIconColor;
      case AppButtonType.secondary:
      case AppButtonType.outline:
        return AppColors.primaryColor;
      case AppButtonType.danger:
      case AppButtonType.success:
        return AppColors.textLightColor;
    }
  }

  TextStyle _getDefaultTextStyle() {
    return AppTheme.buttonTextStyle;
  }
}

class AppSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final Widget? icon;

  const AppSmallButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: type,
      isLoading: isLoading,
      icon: icon,
      isFullWidth: false,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 8,
      textStyle: AppTheme.smallButtonTextStyle,
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final iconColor = _getIconColor();

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: type == AppButtonType.outline
            ? Border.all(color: AppColors.primaryColor, width: 2)
            : null,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
        iconSize: size * 0.4,
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.primaryColor;
      case AppButtonType.secondary:
        return AppColors.surfaceColor;
      case AppButtonType.danger:
        return AppColors.errorColor;
      case AppButtonType.success:
        return AppColors.successColor;
      case AppButtonType.outline:
        return AppColors.transparent;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.searchIconColor;
      case AppButtonType.secondary:
      case AppButtonType.outline:
        return AppColors.primaryColor;
      case AppButtonType.danger:
      case AppButtonType.success:
        return AppColors.textLightColor;
    }
  }
}
