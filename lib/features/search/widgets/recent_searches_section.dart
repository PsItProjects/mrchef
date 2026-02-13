import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class RecentSearchesSection extends StatelessWidget {
  final RxList<String> recentSearches;
  final Function(String) onSearchTap;
  final VoidCallback onClearAll;
  final Function(String)? onRemove;

  const RecentSearchesSection({
    super.key,
    required this.recentSearches,
    required this.onSearchTap,
    required this.onClearAll,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (recentSearches.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 40,
                    color: AppColors.primaryColor.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'start_searching'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.darkTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'search_for_products'.tr,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(
                      'recent_searches'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onClearAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'clear_all'.tr,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.red[400],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Recent searches list
            ...recentSearches.map((query) {
              return Dismissible(
                key: Key(query),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => onRemove?.call(query),
                background: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_outline_rounded, color: Colors.red[400], size: 20),
                ),
                child: GestureDetector(
                  onTap: () => onSearchTap(query),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            query,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.darkTextColor,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.north_west_rounded,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

