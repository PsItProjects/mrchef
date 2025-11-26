import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/search/controllers/search_controller.dart' as search;
import 'package:mrsheaf/features/search/models/search_filter_model.dart';

class SearchFilterBottomSheet extends GetView<search.SearchController> {
  const SearchFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'filters'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF262626),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),

          // Filters content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                final filters = controller.filters.value;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category filter
                    if (controller.categories.isNotEmpty) ...[
                      _buildSectionTitle('category'.tr),
                      const SizedBox(height: 12),
                      _buildCategoryFilter(),
                      const SizedBox(height: 24),
                    ],

                    // Price range filter
                    _buildSectionTitle('price_range'.tr),
                    const SizedBox(height: 12),
                    _buildPriceRangeFilter(filters),
                    const SizedBox(height: 24),

                    // Rating filter
                    _buildSectionTitle('minimum_rating'.tr),
                    const SizedBox(height: 12),
                    _buildRatingFilter(filters),
                    const SizedBox(height: 24),

                    // Dietary options
                    _buildSectionTitle('dietary_options'.tr),
                    const SizedBox(height: 12),
                    _buildDietaryOptions(filters),
                    const SizedBox(height: 24),

                    // Sort options
                    _buildSectionTitle('sort_by'.tr),
                    const SizedBox(height: 12),
                    _buildSortOptions(filters),
                    const SizedBox(height: 24),

                    // Featured products
                    _buildCheckboxOption(
                      'featured_products'.tr,
                      filters.isFeatured ?? false,
                      (value) => controller.updateFilter(isFeatured: value),
                    ),
                  ],
                );
              }),
            ),
          ),

          // Footer buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                // Clear all button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Center(
                        child: Text(
                          'clear_all'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Apply button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.applyFilters(controller.filters.value);
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'apply'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Color(0xFF262626),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.categories.map((category) {
          final isSelected = controller.filters.value.categoryId == category.id;
          return GestureDetector(
            onTap: () => controller.updateFilter(
              categoryId: isSelected ? null : category.id,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                ),
              ),
              child: Text(
                category.displayName,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isSelected ? Colors.white : const Color(0xFF262626),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPriceRangeFilter(SearchFilterModel filters) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                'min'.tr,
                filters.minPrice?.toString() ?? '',
                (value) {
                  final price = double.tryParse(value);
                  controller.updateFilter(minPrice: price);
                },
              ),
            ),
            const SizedBox(width: 12),
            const Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceInput(
                'max'.tr,
                filters.maxPrice?.toString() ?? '',
                (value) {
                  final price = double.tryParse(value);
                  controller.updateFilter(maxPrice: price);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInput(String label, String value, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      controller: TextEditingController(text: value),
    );
  }

  Widget _buildRatingFilter(SearchFilterModel filters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [1, 2, 3, 4, 5].map((rating) {
        final isSelected = filters.minRating == rating.toDouble();
        return GestureDetector(
          onTap: () => controller.updateFilter(
            minRating: isSelected ? null : rating.toDouble(),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '$rating',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isSelected ? Colors.white : Color(0xFF262626),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.star,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primaryColor,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDietaryOptions(SearchFilterModel filters) {
    return Column(
      children: [
        _buildCheckboxOption(
          'vegetarian'.tr,
          filters.isVegetarian ?? false,
          (value) => controller.updateFilter(isVegetarian: value),
        ),
        const SizedBox(height: 12),
        _buildCheckboxOption(
          'spicy'.tr,
          filters.isSpicy ?? false,
          (value) => controller.updateFilter(isSpicy: value),
        ),
      ],
    );
  }

  Widget _buildSortOptions(SearchFilterModel filters) {
    final sortOptions = [
      {'value': 'price_asc', 'label': 'price_low_to_high'.tr},
      {'value': 'price_desc', 'label': 'price_high_to_low'.tr},
      {'value': 'rating_desc', 'label': 'highest_rated'.tr},
      {'value': 'name_asc', 'label': 'name_a_to_z'.tr},
    ];

    return Column(
      children: sortOptions.map((option) {
        final isSelected = filters.sortBy == option['value']?.split('_')[0] &&
            filters.sortOrder == option['value']?.split('_')[1];

        return GestureDetector(
          onTap: () {
            final parts = option['value']!.split('_');
            controller.updateFilter(
              sortBy: parts[0],
              sortOrder: parts[1],
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primaryColor : Colors.grey[400],
                ),
                const SizedBox(width: 12),
                Text(
                  option['label']!,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isSelected ? AppColors.primaryColor : Color(0xFF262626),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxOption(String label, bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? AppColors.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? AppColors.primaryColor : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: value ? AppColors.primaryColor : Color(0xFF262626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


