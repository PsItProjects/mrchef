import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/search/controllers/search_controller.dart' as search;
import 'package:mrsheaf/features/search/models/search_filter_model.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({super.key});

  @override
  State<SearchFilterBottomSheet> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  final search.SearchController controller = Get.find<search.SearchController>();

  // Local mutable copy of filters
  late SearchFilterModel _tempFilters;
  late TextEditingController _minPriceCtrl;
  late TextEditingController _maxPriceCtrl;

  @override
  void initState() {
    super.initState();
    _tempFilters = controller.filters.value;
    _minPriceCtrl = TextEditingController(
      text: _tempFilters.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceCtrl = TextEditingController(
      text: _tempFilters.maxPrice?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  void _updateTemp(SearchFilterModel Function(SearchFilterModel) updater) {
    setState(() {
      _tempFilters = updater(_tempFilters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.15),
                            AppColors.primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'filters'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                        if (_tempFilters.activeFiltersCount > 0)
                          Text(
                            '${_tempFilters.activeFiltersCount} ${'active_filters'.tr}',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.primaryColor.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
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

          Divider(color: Colors.grey[100], height: 1),

          // Filters content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category ──
                  if (controller.categories.isNotEmpty) ...[
                    _buildSectionTitle('category'.tr, Icons.category_rounded),
                    const SizedBox(height: 12),
                    _buildCategoryFilter(),
                    const SizedBox(height: 24),
                  ],

                  // ── Food Nationality / Cuisine ──
                  if (controller.foodNationalities.isNotEmpty) ...[
                    _buildSectionTitle('food_nationality'.tr, Icons.public_rounded),
                    const SizedBox(height: 12),
                    _buildFoodNationalityFilter(),
                    const SizedBox(height: 24),
                  ],

                  // ── Governorate ──
                  if (controller.governorates.isNotEmpty) ...[
                    _buildSectionTitle('governorate'.tr, Icons.location_on_rounded),
                    const SizedBox(height: 12),
                    _buildGovernorateFilter(),
                    const SizedBox(height: 24),
                  ],

                  // ── Price Range ──
                  _buildSectionTitle('price_range'.tr, Icons.payments_rounded),
                  const SizedBox(height: 12),
                  _buildPriceRangeFilter(),
                  const SizedBox(height: 24),

                  // ── Rating ──
                  _buildSectionTitle('minimum_rating'.tr, Icons.star_rounded),
                  const SizedBox(height: 12),
                  _buildRatingFilter(),
                  const SizedBox(height: 24),

                  // ── Dietary Options ──
                  _buildSectionTitle('dietary_options'.tr, Icons.eco_rounded),
                  const SizedBox(height: 12),
                  _buildDietaryOptions(),
                  const SizedBox(height: 24),

                  // ── Prep Time ──
                  _buildSectionTitle('prep_time'.tr, Icons.timer_rounded),
                  const SizedBox(height: 12),
                  _buildPrepTimeFilter(),
                  const SizedBox(height: 24),

                  // ── Sort ──
                  _buildSectionTitle('sort_by'.tr, Icons.sort_rounded),
                  const SizedBox(height: 12),
                  _buildSortOptions(),
                  const SizedBox(height: 24),

                  // ── Featured ──
                  _buildToggleOption(
                    'featured_only'.tr,
                    Icons.star_border_rounded,
                    _tempFilters.isFeatured ?? false,
                    (v) => _updateTemp((f) => SearchFilterModel(
                      categoryId: f.categoryId,
                      restaurantId: f.restaurantId,
                      foodNationalityId: f.foodNationalityId,
                      governorateId: f.governorateId,
                      minPrice: f.minPrice,
                      maxPrice: f.maxPrice,
                      minRating: f.minRating,
                      isVegetarian: f.isVegetarian,
                      isVegan: f.isVegan,
                      isGlutenFree: f.isGlutenFree,
                      isSpicy: f.isSpicy,
                      isFeatured: v ? true : null,
                      maxPrepTime: f.maxPrepTime,
                      sortBy: f.sortBy,
                      sortOrder: f.sortOrder,
                    )),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Footer buttons
          _buildFooter(),
        ],
      ),
    );
  }

  // ─── SECTION TITLE ────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.darkTextColor,
          ),
        ),
      ],
    );
  }

  // ─── CATEGORY CHIPS ───────────────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.categories.map((category) {
        final isSelected = _tempFilters.categoryId == category.id;
        return _buildSelectableChip(
          label: category.displayName,
          isSelected: isSelected,
          onTap: () => _updateTemp((f) => f.copyWith(
            categoryId: isSelected ? null : category.id,
            clearCategoryId: isSelected,
          )),
        );
      }).toList(),
    );
  }

  // ─── FOOD NATIONALITY CHIPS ───────────────────────────────────────────────
  Widget _buildFoodNationalityFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.foodNationalities.map((item) {
        final id = item['id'] as int;
        final name = item['name'];
        final displayName = name is Map
            ? (name['current'] ?? name['en'] ?? '')
            : (name?.toString() ?? '');
        final icon = item['icon'] as String? ?? '';
        final isSelected = _tempFilters.foodNationalityId == id;

        return _buildSelectableChip(
          label: icon.isNotEmpty ? '$icon $displayName' : displayName,
          isSelected: isSelected,
          onTap: () => _updateTemp((f) => f.copyWith(
            foodNationalityId: isSelected ? null : id,
            clearFoodNationalityId: isSelected,
          )),
        );
      }).toList(),
    );
  }

  // ─── GOVERNORATE CHIPS ────────────────────────────────────────────────────
  Widget _buildGovernorateFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.governorates.map((item) {
        final id = item['id'] as int;
        final name = item['name'];
        final displayName = name is Map
            ? (name['current'] ?? name['en'] ?? '')
            : (name?.toString() ?? '');
        final isSelected = _tempFilters.governorateId == id;

        return _buildSelectableChip(
          label: displayName,
          isSelected: isSelected,
          onTap: () => _updateTemp((f) => f.copyWith(
            governorateId: isSelected ? null : id,
            clearGovernorateId: isSelected,
          )),
          icon: Icons.location_on_outlined,
        );
      }).toList(),
    );
  }

  // ─── REUSABLE CHIP ────────────────────────────────────────────────────────
  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.grey[250] ?? Colors.grey[300]!,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey[500],
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.darkTextColor,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  // ─── PRICE RANGE ──────────────────────────────────────────────────────────
  Widget _buildPriceRangeFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPriceInput(
              'min'.tr,
              _minPriceCtrl,
              (value) {
                final price = double.tryParse(value);
                _updateTemp((f) => SearchFilterModel(
                  categoryId: f.categoryId,
                  restaurantId: f.restaurantId,
                  foodNationalityId: f.foodNationalityId,
                  governorateId: f.governorateId,
                  minPrice: price,
                  maxPrice: f.maxPrice,
                  minRating: f.minRating,
                  isVegetarian: f.isVegetarian,
                  isVegan: f.isVegan,
                  isGlutenFree: f.isGlutenFree,
                  isSpicy: f.isSpicy,
                  isFeatured: f.isFeatured,
                  maxPrepTime: f.maxPrepTime,
                  sortBy: f.sortBy,
                  sortOrder: f.sortOrder,
                ));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Expanded(
            child: _buildPriceInput(
              'max'.tr,
              _maxPriceCtrl,
              (value) {
                final price = double.tryParse(value);
                _updateTemp((f) => SearchFilterModel(
                  categoryId: f.categoryId,
                  restaurantId: f.restaurantId,
                  foodNationalityId: f.foodNationalityId,
                  governorateId: f.governorateId,
                  minPrice: f.minPrice,
                  maxPrice: price,
                  minRating: f.minRating,
                  isVegetarian: f.isVegetarian,
                  isVegan: f.isVegan,
                  isGlutenFree: f.isGlutenFree,
                  isSpicy: f.isSpicy,
                  isFeatured: f.isFeatured,
                  maxPrepTime: f.maxPrepTime,
                  sortBy: f.sortBy,
                  sortOrder: f.sortOrder,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput(String label, TextEditingController ctrl, Function(String) onChanged) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 13,
          color: Colors.grey[500],
        ),
        suffixText: 'ر.س',
        suffixStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 12,
          color: Colors.grey[500],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  // ─── RATING ───────────────────────────────────────────────────────────────
  Widget _buildRatingFilter() {
    return Row(
      children: [1, 2, 3, 4, 5].map((rating) {
        final isSelected = _tempFilters.minRating == rating.toDouble();
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: rating == 1 ? 0 : 4,
              right: rating == 5 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => _updateTemp((f) => f.copyWith(
                minRating: isSelected ? null : rating.toDouble(),
                clearMinRating: isSelected,
              )),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.grey[200]!,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.25),
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
                      size: 22,
                      color: isSelected ? Colors.white : const Color(0xFFFFB800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$rating+',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppColors.darkTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── DIETARY OPTIONS ──────────────────────────────────────────────────────
  Widget _buildDietaryOptions() {
    final options = [
      {
        'label': 'vegetarian'.tr,
        'icon': '🥬',
        'value': _tempFilters.isVegetarian ?? false,
        'onChanged': (bool v) => _updateTemp((f) => SearchFilterModel(
              categoryId: f.categoryId, restaurantId: f.restaurantId,
              foodNationalityId: f.foodNationalityId, governorateId: f.governorateId,
              minPrice: f.minPrice, maxPrice: f.maxPrice, minRating: f.minRating,
              isVegetarian: v ? true : null, isVegan: f.isVegan,
              isGlutenFree: f.isGlutenFree, isSpicy: f.isSpicy,
              isFeatured: f.isFeatured, maxPrepTime: f.maxPrepTime,
              sortBy: f.sortBy, sortOrder: f.sortOrder,
            )),
      },
      {
        'label': 'vegan'.tr,
        'icon': '🌱',
        'value': _tempFilters.isVegan ?? false,
        'onChanged': (bool v) => _updateTemp((f) => SearchFilterModel(
              categoryId: f.categoryId, restaurantId: f.restaurantId,
              foodNationalityId: f.foodNationalityId, governorateId: f.governorateId,
              minPrice: f.minPrice, maxPrice: f.maxPrice, minRating: f.minRating,
              isVegetarian: f.isVegetarian, isVegan: v ? true : null,
              isGlutenFree: f.isGlutenFree, isSpicy: f.isSpicy,
              isFeatured: f.isFeatured, maxPrepTime: f.maxPrepTime,
              sortBy: f.sortBy, sortOrder: f.sortOrder,
            )),
      },
      {
        'label': 'gluten_free'.tr,
        'icon': '🌾',
        'value': _tempFilters.isGlutenFree ?? false,
        'onChanged': (bool v) => _updateTemp((f) => SearchFilterModel(
              categoryId: f.categoryId, restaurantId: f.restaurantId,
              foodNationalityId: f.foodNationalityId, governorateId: f.governorateId,
              minPrice: f.minPrice, maxPrice: f.maxPrice, minRating: f.minRating,
              isVegetarian: f.isVegetarian, isVegan: f.isVegan,
              isGlutenFree: v ? true : null, isSpicy: f.isSpicy,
              isFeatured: f.isFeatured, maxPrepTime: f.maxPrepTime,
              sortBy: f.sortBy, sortOrder: f.sortOrder,
            )),
      },
      {
        'label': 'spicy'.tr,
        'icon': '🌶️',
        'value': _tempFilters.isSpicy ?? false,
        'onChanged': (bool v) => _updateTemp((f) => SearchFilterModel(
              categoryId: f.categoryId, restaurantId: f.restaurantId,
              foodNationalityId: f.foodNationalityId, governorateId: f.governorateId,
              minPrice: f.minPrice, maxPrice: f.maxPrice, minRating: f.minRating,
              isVegetarian: f.isVegetarian, isVegan: f.isVegan,
              isGlutenFree: f.isGlutenFree, isSpicy: v ? true : null,
              isFeatured: f.isFeatured, maxPrepTime: f.maxPrepTime,
              sortBy: f.sortBy, sortOrder: f.sortOrder,
            )),
      },
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isActive = opt['value'] as bool;
        return GestureDetector(
          onTap: () => (opt['onChanged'] as Function(bool))(!isActive),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? AppColors.primaryColor : Colors.grey[200]!,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(opt['icon'] as String, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  opt['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                    color: isActive ? AppColors.primaryColor : AppColors.darkTextColor,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.primaryColor),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── PREP TIME ────────────────────────────────────────────────────────────
  Widget _buildPrepTimeFilter() {
    final times = [15, 30, 45, 60, 90];
    return Row(
      children: times.map((minutes) {
        final isSelected = _tempFilters.maxPrepTime == minutes;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: minutes == times.first ? 0 : 4,
              right: minutes == times.last ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => _updateTemp((f) => f.copyWith(
                maxPrepTime: isSelected ? null : minutes,
                clearMaxPrepTime: isSelected,
              )),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.grey[200]!,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$minutes',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isSelected ? Colors.white : AppColors.darkTextColor,
                      ),
                    ),
                    Text(
                      'minutes'.tr,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: isSelected ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── SORT OPTIONS ─────────────────────────────────────────────────────────
  Widget _buildSortOptions() {
    final sortOptions = [
      {'value': 'popularity_desc', 'label': 'most_popular'.tr, 'icon': Icons.trending_up_rounded},
      {'value': 'rating_desc', 'label': 'highest_rated'.tr, 'icon': Icons.star_rounded},
      {'value': 'price_asc', 'label': 'price_low_to_high'.tr, 'icon': Icons.arrow_downward_rounded},
      {'value': 'price_desc', 'label': 'price_high_to_low'.tr, 'icon': Icons.arrow_upward_rounded},
      {'value': 'name_asc', 'label': 'name_a_to_z'.tr, 'icon': Icons.sort_by_alpha_rounded},
      {'value': 'created_at_desc', 'label': 'newest_first'.tr, 'icon': Icons.new_releases_rounded},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortOptions.map((option) {
        final parts = (option['value'] as String).split('_');
        final sortBy = parts.sublist(0, parts.length - 1).join('_');
        final sortOrder = parts.last;
        final isSelected = _tempFilters.sortBy == sortBy &&
            _tempFilters.sortOrder == sortOrder;

        return GestureDetector(
          onTap: () {
            _updateTemp((f) => SearchFilterModel(
              categoryId: f.categoryId,
              restaurantId: f.restaurantId,
              foodNationalityId: f.foodNationalityId,
              governorateId: f.governorateId,
              minPrice: f.minPrice,
              maxPrice: f.maxPrice,
              minRating: f.minRating,
              isVegetarian: f.isVegetarian,
              isVegan: f.isVegan,
              isGlutenFree: f.isGlutenFree,
              isSpicy: f.isSpicy,
              isFeatured: f.isFeatured,
              maxPrepTime: f.maxPrepTime,
              sortBy: isSelected ? null : sortBy,
              sortOrder: isSelected ? null : sortOrder,
            ));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.grey[200]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option['icon'] as IconData,
                  size: 16,
                  color: isSelected ? AppColors.primaryColor : Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  option['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                    color: isSelected ? AppColors.primaryColor : AppColors.darkTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── TOGGLE OPTION ────────────────────────────────────────────────────────
  Widget _buildToggleOption(String label, IconData icon, bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? AppColors.primaryColor : Colors.grey[200]!,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: value ? AppColors.primaryColor : Colors.grey[500]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  color: value ? AppColors.primaryColor : AppColors.darkTextColor,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: value ? AppColors.primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FOOTER ───────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
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
            // Clear all
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.clearFilters();
                  Get.back();
                },
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
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Apply
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  controller.applyFilters(_tempFilters);
                  Get.back();
                },
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
          ],
        ),
      ),
    );
  }
}


