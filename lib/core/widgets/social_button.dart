import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

enum SocialPlatform { facebook, google, apple, twitter }

class SocialButton extends StatelessWidget {
  final SocialPlatform platform;
  final VoidCallback onTap;
  final double size;
  final bool isOutlined;

  const SocialButton({
    super.key,
    required this.platform,
    required this.onTap,
    this.size = 56,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isOutlined ? AppColors.transparent : _getPlatformColor(),
          border: isOutlined 
              ? Border.all(color: _getPlatformColor(), width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: !isOutlined ? [
            BoxShadow(
              color: AppColors.blackShadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Icon(
            _getPlatformIcon(),
            color: isOutlined ? _getPlatformColor() : AppColors.textLightColor,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }

  Color _getPlatformColor() {
    switch (platform) {
      case SocialPlatform.facebook:
        return AppColors.socialFacebookColor;
      case SocialPlatform.google:
        return AppColors.socialGoogleColor;
      case SocialPlatform.apple:
        return AppColors.socialAppleColor;
      case SocialPlatform.twitter:
        return AppColors.socialTwitterColor;
    }
  }

  IconData _getPlatformIcon() {
    switch (platform) {
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.google:
        return Icons.g_mobiledata;
      case SocialPlatform.apple:
        return Icons.apple;
      case SocialPlatform.twitter:
        return Icons.alternate_email;
    }
  }
}

class SocialButtonRow extends StatelessWidget {
  final VoidCallback? onFacebookTap;
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;
  final VoidCallback? onTwitterTap;
  final bool isOutlined;
  final double buttonSize;
  final MainAxisAlignment alignment;

  const SocialButtonRow({
    super.key,
    this.onFacebookTap,
    this.onGoogleTap,
    this.onAppleTap,
    this.onTwitterTap,
    this.isOutlined = false,
    this.buttonSize = 56,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (onFacebookTap != null) {
      buttons.add(SocialButton(
        platform: SocialPlatform.facebook,
        onTap: onFacebookTap!,
        size: buttonSize,
        isOutlined: isOutlined,
      ));
    }

    if (onGoogleTap != null) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 16));
      buttons.add(SocialButton(
        platform: SocialPlatform.google,
        onTap: onGoogleTap!,
        size: buttonSize,
        isOutlined: isOutlined,
      ));
    }

    if (onAppleTap != null) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 16));
      buttons.add(SocialButton(
        platform: SocialPlatform.apple,
        onTap: onAppleTap!,
        size: buttonSize,
        isOutlined: isOutlined,
      ));
    }

    if (onTwitterTap != null) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 16));
      buttons.add(SocialButton(
        platform: SocialPlatform.twitter,
        onTap: onTwitterTap!,
        size: buttonSize,
        isOutlined: isOutlined,
      ));
    }

    return Row(
      mainAxisAlignment: alignment,
      children: buttons,
    );
  }
}

class SocialSignInSection extends StatelessWidget {
  final String title;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;
  final bool isOutlined;

  const SocialSignInSection({
    super.key,
    this.title = 'Or continue with',
    this.onFacebookTap,
    this.onGoogleTap,
    this.onAppleTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: AppTheme.bodyStyle.copyWith(
                  color: AppColors.hintTextColor,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        SocialButtonRow(
          onFacebookTap: onFacebookTap,
          onGoogleTap: onGoogleTap,
          onAppleTap: onAppleTap,
          isOutlined: isOutlined,
        ),
      ],
    );
  }
}
