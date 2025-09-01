import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/widgets/app_animations.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;

  const AppLoading({
    super.key,
    this.message,
    this.size = 40,
    this.color,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primaryColor,
              ),
              strokeWidth: 3,
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            FadeInAnimation(
              child: Text(
                message!,
                style: AppTheme.bodyStyle.copyWith(
                  color: AppColors.hintTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppSkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const AppSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ShimmerLoading(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.greyColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Product image skeleton
          AppSkeletonLoader(
            width: 120,
            height: 120,
            borderRadius: 60,
          ),
          const SizedBox(height: 16),
          // Product name skeleton
          AppSkeletonLoader(
            width: 140,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 8),
          // Product description skeleton
          AppSkeletonLoader(
            width: 100,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 12),
          // Price skeleton
          AppSkeletonLoader(
            width: 80,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 12),
          // Button skeleton
          AppSkeletonLoader(
            width: double.infinity,
            height: 26,
            borderRadius: 8,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class KitchenCardSkeleton extends StatelessWidget {
  const KitchenCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      height: 223,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppColors.greyColor.withOpacity(0.2),
      ),
      child: ShimmerLoading(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: AppColors.greyColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

class ListTileSkeleton extends StatelessWidget {
  final bool showLeading;
  final bool showTrailing;

  const ListTileSkeleton({
    super.key,
    this.showLeading = true,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showLeading) ...[
            AppSkeletonLoader(
              width: 48,
              height: 48,
              borderRadius: 24,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLoader(
                  width: double.infinity,
                  height: 16,
                ),
                const SizedBox(height: 8),
                AppSkeletonLoader(
                  width: 200,
                  height: 12,
                ),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 16),
            AppSkeletonLoader(
              width: 24,
              height: 24,
              borderRadius: 12,
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? overlayColor;

  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? AppColors.blackShadowColor.withOpacity(0.5),
            child: AppLoading(
              message: loadingMessage,
            ),
          ),
      ],
    );
  }
}

class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primaryColor,
      backgroundColor: AppColors.backgroundColor,
      child: child,
    );
  }
}

class LoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final String? message;

  const LoadMoreIndicator({
    super.key,
    required this.isLoading,
    this.onLoadMore,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && onLoadMore == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? AppLoading(
                size: 24,
                message: message ?? 'Loading more...',
                showMessage: false,
              )
            : GestureDetector(
                onTap: onLoadMore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Load More',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppColors.searchIconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
