import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class SearchEmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onFilterTap;

  const SearchEmptyState({
    super.key,
    required this.query,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 44,
                color: Colors.grey[400],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'no_results_found'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.darkTextColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            if (query.isNotEmpty)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  children: [
                    TextSpan(text: '${'searched_for'.tr} "'),
                    TextSpan(
                      text: query,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: '"'),
                  ],
                ),
              ),

            const SizedBox(height: 6),

            Text(
              'try_different_keywords'.tr,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // Filter button
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, Color(0xFFFFC107)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'try_filters'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

