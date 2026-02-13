import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/search/controllers/search_controller.dart' as search;
import 'package:mrsheaf/features/search/models/search_filter_model.dart';
import 'package:mrsheaf/features/search/widgets/search_app_bar.dart';
import 'package:mrsheaf/features/search/widgets/search_results_list.dart';
import 'package:mrsheaf/features/search/widgets/search_empty_state.dart';
import 'package:mrsheaf/features/search/widgets/recent_searches_section.dart';
import 'package:mrsheaf/features/search/widgets/search_filter_bottom_sheet.dart';

class SearchScreen extends GetView<search.SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.hideAutocomplete();
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceColor,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Search app bar
              const SearchAppBar(),

              const SizedBox(height: 12),

              // Autocomplete overlay (shows between search bar and content)
              const AutocompleteOverlay(),

              // Search type tabs + filter row
              Obx(() {
                // Only show tabs when autocomplete is hidden
                if (controller.showAutocomplete.value &&
                    controller.autocompleteSuggestions.isNotEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildTabsAndFilters(context);
              }),

              // Active filter chips
              Obx(() {
                if (controller.showAutocomplete.value &&
                    controller.autocompleteSuggestions.isNotEmpty) {
                  return const SizedBox.shrink();
                }
                if (!controller.filters.value.hasActiveFilters) {
                  return const SizedBox.shrink();
                }
                return _buildActiveFilterChips();
              }),

              // Main content
              Expanded(
                child: Obx(() {
                  if (controller.showAutocomplete.value &&
                      controller.autocompleteSuggestions.isNotEmpty) {
                    return const SizedBox.shrink();
                  }

                  // Loading
                  if (controller.isLoading.value &&
                      controller.searchResults.isEmpty) {
                    return _buildLoadingShimmer();
                  }

                  // Results
                  if (controller.searchResults.isNotEmpty) {
                    return Column(
                      children: [
                        // Results count
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                          child: Row(
                            children: [
                              Text(
                                '${controller.totalResults.value} ${'search_results'.tr}',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SearchResultsList(
                            results: controller.searchResults,
                            onLoadMore: () =>
                                controller.search(loadMore: true),
                            hasMore: controller.hasMore.value,
                            searchType: controller.searchType.value,
                          ),
                        ),
                      ],
                    );
                  }

                  // Recent searches / initial state
                  if (controller.searchQuery.value.isEmpty &&
                      !controller.filters.value.hasActiveFilters) {
                    return RecentSearchesSection(
                      recentSearches: controller.recentSearches,
                      onSearchTap: controller.selectRecentSearch,
                      onClearAll: controller.clearRecentSearches,
                      onRemove: controller.removeRecentSearch,
                    );
                  }

                  // Empty state
                  return SearchEmptyState(
                    query: controller.searchQuery.value,
                    onFilterTap: () => _showFiltersBottomSheet(context),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabsAndFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Tabs + filter button row
          Row(
            children: [
              // Products / Restaurants tabs
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildTab('products', 'products'.tr),
                      _buildTab('restaurants', 'restaurants'.tr),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Filter button
              GestureDetector(
                onTap: () => _showFiltersBottomSheet(context),
                child: Obx(() {
                  final count = controller.filters.value.activeFiltersCount;
                  return Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: count > 0
                          ? const LinearGradient(
                              colors: [AppColors.primaryColor, Color(0xFFFFC107)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: count > 0 ? null : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: count > 0
                              ? AppColors.primaryColor.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: count > 0 ? 10 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: count > 0 ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTab(String type, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setSearchType(type),
        child: Obx(() {
          final isSelected = controller.searchType.value == type;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    return Obx(() {
      final f = controller.filters.value;
      final chips = <Widget>[];

      if (f.categoryId != null) {
        final cat = controller.categories.firstWhereOrNull((c) => c.id == f.categoryId);
        chips.add(_filterChip(
          cat?.displayName ?? 'category'.tr,
          () => controller.applyFilters(f.copyWith(clearCategoryId: true)),
        ));
      }
      if (f.foodNationalityId != null) {
        chips.add(_filterChip(
          controller.getFoodNationalityName(f.foodNationalityId!),
          () => controller.applyFilters(f.copyWith(clearFoodNationalityId: true)),
        ));
      }
      if (f.governorateId != null) {
        chips.add(_filterChip(
          controller.getGovernorateName(f.governorateId!),
          () => controller.applyFilters(f.copyWith(clearGovernorateId: true)),
        ));
      }
      if (f.minRating != null) {
        chips.add(_filterChip(
          '⭐ ${f.minRating!.toInt()}+',
          () => controller.applyFilters(f.copyWith(clearMinRating: true)),
        ));
      }
      if (f.minPrice != null || f.maxPrice != null) {
        String priceLabel = 'price_range'.tr;
        if (f.minPrice != null && f.maxPrice != null) {
          priceLabel = '${f.minPrice!.toInt()}-${f.maxPrice!.toInt()} ر.س';
        } else if (f.minPrice != null) {
          priceLabel = '${f.minPrice!.toInt()}+ ر.س';
        } else {
          priceLabel = '≤${f.maxPrice!.toInt()} ر.س';
        }
        chips.add(_filterChip(
          priceLabel,
          () => controller.applyFilters(SearchFilterModelCopy.clearPrice(f)),
        ));
      }
      if (f.isVegetarian == true) {
        chips.add(_filterChip('🥬 ${'vegetarian'.tr}', () =>
            controller.applyFilters(f.copyWith(isVegetarian: false))));
      }
      if (f.isVegan == true) {
        chips.add(_filterChip('🌱 ${'vegan'.tr}', () =>
            controller.applyFilters(f.copyWith(isVegan: false))));
      }
      if (f.isGlutenFree == true) {
        chips.add(_filterChip('🌾 ${'gluten_free'.tr}', () =>
            controller.applyFilters(f.copyWith(isGlutenFree: false))));
      }
      if (f.isSpicy == true) {
        chips.add(_filterChip('🌶️ ${'spicy'.tr}', () =>
            controller.applyFilters(f.copyWith(isSpicy: false))));
      }
      if (f.isFeatured == true) {
        chips.add(_filterChip('⭐ ${'featured_only'.tr}', () =>
            controller.applyFilters(f.copyWith(isFeatured: false))));
      }

      if (chips.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 38,
        margin: const EdgeInsets.only(bottom: 6),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // Clear all minibutton
            GestureDetector(
              onTap: controller.clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close_rounded, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      'clear'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...chips,
          ],
        ),
      );
    });
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Image placeholder
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

/// Helper to clear price from filter (since copyWith can't null out doubles)
class SearchFilterModelCopy {
  static SearchFilterModel clearPrice(SearchFilterModel f) {
    return SearchFilterModel(
      categoryId: f.categoryId,
      restaurantId: f.restaurantId,
      foodNationalityId: f.foodNationalityId,
      governorateId: f.governorateId,
      minPrice: null,
      maxPrice: null,
      minRating: f.minRating,
      isVegetarian: f.isVegetarian,
      isVegan: f.isVegan,
      isGlutenFree: f.isGlutenFree,
      isSpicy: f.isSpicy,
      isFeatured: f.isFeatured,
      maxPrepTime: f.maxPrepTime,
      sortBy: f.sortBy,
      sortOrder: f.sortOrder,
    );
  }
}

