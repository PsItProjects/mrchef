import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final VoidCallback? onSearchTap;
  final String? iconPath;
  final EdgeInsetsGeometry? padding;
  final double height;
  final double borderRadius;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search products',
    this.onTap,
    this.onSearchTap,
    this.iconPath = 'assets/icons/search_icon.svg',
    this.padding,
    this.height = 52,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.searchBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            children: [
              // Search icon container
              GestureDetector(
                onTap: onSearchTap ?? onTap,
                child: Container(
                  width: height,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Center(
                    child: iconPath != null
                        ? SvgPicture.asset(
                            iconPath!,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              AppColors.searchIconColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : const Icon(
                            Icons.search,
                            size: 24,
                            color: AppColors.searchIconColor,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Search text
              Expanded(
                child: Text(
                  hintText,
                  style: AppTheme.searchTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSearchBarWithFilter extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final EdgeInsetsGeometry? padding;

  const AppSearchBarWithFilter({
    super.key,
    required this.hintText,
    this.onTap,
    this.onFilterTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: AppSearchBar(
              hintText: hintText,
              onTap: onTap,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
          // Filter button
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/filter_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.searchIconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
