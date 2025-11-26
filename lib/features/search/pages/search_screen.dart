import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/search/controllers/search_controller.dart' as search;
import 'package:mrsheaf/features/search/widgets/search_app_bar.dart';
import 'package:mrsheaf/features/search/widgets/search_results_list.dart';
import 'package:mrsheaf/features/search/widgets/search_empty_state.dart';
import 'package:mrsheaf/features/search/widgets/recent_searches_section.dart';
import 'package:mrsheaf/features/search/widgets/search_filter_button.dart';
import 'package:mrsheaf/features/search/widgets/search_filter_bottom_sheet.dart';

class SearchScreen extends GetView<search.SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Search app bar with back button and search input
            const SearchAppBar(),
            
            const SizedBox(height: 16),
            
            // Filter button (if there are active filters)
            Obx(() {
              if (controller.filters.value.hasActiveFilters) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: SearchFilterButton(
                          activeFiltersCount: controller.filters.value.activeFiltersCount,
                          onTap: () => _showFiltersBottomSheet(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Clear filters button
                      GestureDetector(
                        onTap: controller.clearFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE3E3E3)),
                          ),
                          child: Text(
                            'clear'.tr,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            Obx(() {
              if (controller.filters.value.hasActiveFilters) {
                return const SizedBox(height: 16);
              }
              return const SizedBox.shrink();
            }),
            
            // Main content
            Expanded(
              child: Obx(() {
                // Show loading indicator
                if (controller.isLoading.value && controller.searchResults.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }
                
                // Show search results
                if (controller.searchResults.isNotEmpty) {
                  return SearchResultsList(
                    results: controller.searchResults,
                    onLoadMore: () => controller.search(loadMore: true),
                    hasMore: controller.hasMore.value,
                  );
                }
                
                // Show recent searches or empty state
                if (controller.searchQuery.value.isEmpty) {
                  return RecentSearchesSection(
                    recentSearches: controller.recentSearches,
                    onSearchTap: controller.selectRecentSearch,
                    onClearAll: controller.clearRecentSearches,
                  );
                }
                
                // Show empty state (no results)
                return SearchEmptyState(
                  query: controller.searchQuery.value,
                  onFilterTap: () => _showFiltersBottomSheet(context),
                );
              }),
            ),
          ],
        ),
      ),
      // Floating filter button (always visible)
      floatingActionButton: Obx(() {
        if (controller.searchQuery.value.isNotEmpty) {
          return FloatingActionButton(
            onPressed: () => _showFiltersBottomSheet(context),
            backgroundColor: AppColors.primaryColor,
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.filter_list,
                    color: Colors.white,
                  ),
                ),
                if (controller.filters.value.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${controller.filters.value.activeFiltersCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    Get.bottomSheet(
      const SearchFilterBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

