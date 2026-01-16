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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'filters'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF262626),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey[200], height: 1),

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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Clear all button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          controller.clearFilters();
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'clear_all'.tr,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Apply button
                  Expanded(
                    flex: 2,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          controller.applyFilters(controller.filters.value);
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'apply'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return const Center(
          child: SizedBox(
            height: 40,
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 2,
            ),
          ),
        );
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: controller.categories.map((category) {
          final isSelected = controller.filters.value.categoryId == category.id;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.updateFilter(
                categoryId: isSelected ? null : category.id,
              ),
              borderRadius: BorderRadius.circular(25),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category.displayName,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF262626),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPriceRangeFilter(SearchFilterModel filters) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPriceInput(
              'min'.tr,
              filters.minPrice?.toString() ?? '',
              (value) {
                final price = double.tryParse(value);
                controller.updateFilter(minPrice: price);
              },
              Icons.arrow_downward_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Expanded(
            child: _buildPriceInput(
              'max'.tr,
              filters.maxPrice?.toString() ?? '',
              (value) {
                final price = double.tryParse(value);
                controller.updateFilter(maxPrice: price);
              },
              Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput(String label, String value, Function(String) onChanged, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primaryColor),
        suffixText: 'ر.س',
        suffixStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 12,
          color: Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      controller: TextEditingController(text: value),
    );
  }

  Widget _buildRatingFilter(SearchFilterModel filters) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [1, 2, 3, 4, 5].map((rating) {
          final isSelected = filters.minRating == rating.toDouble();
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: rating == 1 ? 0 : 4,
                right: rating == 5 ? 0 : 4,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.updateFilter(
                    minRating: isSelected ? null : rating.toDouble(),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 24,
                          color: isSelected ? Colors.white : const Color(0xFFFFB800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$rating+',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isSelected ? Colors.white : const Color(0xFF262626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDietaryOptions(SearchFilterModel filters) {
    return Row(
      children: [
        Expanded(
          child: _buildCheckboxOption(
            'vegetarian'.tr,
            filters.isVegetarian ?? false,
            (value) => controller.updateFilter(isVegetarian: value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCheckboxOption(
            'spicy'.tr,
            filters.isSpicy ?? false,
            (value) => controller.updateFilter(isSpicy: value),
          ),
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
              color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primaryColor : Colors.grey[400],
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  option['label']!,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                    color: isSelected ? AppColors.primaryColor : const Color(0xFF262626),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: value ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value ? AppColors.primaryColor : Colors.grey[300]!,
              width: value ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? AppColors.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value ? AppColors.primaryColor : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  color: value ? AppColors.primaryColor : const Color(0xFF262626),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


