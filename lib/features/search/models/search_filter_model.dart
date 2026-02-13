class SearchFilterModel {
  final int? categoryId;
  final int? restaurantId;
  final int? foodNationalityId;
  final int? governorateId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool? isVegetarian;
  final bool? isVegan;
  final bool? isGlutenFree;
  final bool? isSpicy;
  final bool? isFeatured;
  final int? maxPrepTime;
  final String? sortBy; // 'price', 'rating', 'name', 'created_at', 'popularity'
  final String? sortOrder; // 'asc', 'desc'

  SearchFilterModel({
    this.categoryId,
    this.restaurantId,
    this.foodNationalityId,
    this.governorateId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.isVegetarian,
    this.isVegan,
    this.isGlutenFree,
    this.isSpicy,
    this.isFeatured,
    this.maxPrepTime,
    this.sortBy,
    this.sortOrder,
  });

  SearchFilterModel copyWith({
    int? categoryId,
    int? restaurantId,
    int? foodNationalityId,
    int? governorateId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isSpicy,
    bool? isFeatured,
    int? maxPrepTime,
    String? sortBy,
    String? sortOrder,
    // Allow clearing nullable fields
    bool clearCategoryId = false,
    bool clearFoodNationalityId = false,
    bool clearGovernorateId = false,
    bool clearMinRating = false,
    bool clearMaxPrepTime = false,
  }) {
    return SearchFilterModel(
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      restaurantId: restaurantId ?? this.restaurantId,
      foodNationalityId: clearFoodNationalityId ? null : (foodNationalityId ?? this.foodNationalityId),
      governorateId: clearGovernorateId ? null : (governorateId ?? this.governorateId),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isSpicy: isSpicy ?? this.isSpicy,
      isFeatured: isFeatured ?? this.isFeatured,
      maxPrepTime: clearMaxPrepTime ? null : (maxPrepTime ?? this.maxPrepTime),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (categoryId != null) data['category_id'] = categoryId;
    if (restaurantId != null) data['restaurant_id'] = restaurantId;
    if (foodNationalityId != null) data['food_nationality_id'] = foodNationalityId;
    if (governorateId != null) data['governorate_id'] = governorateId;
    if (minPrice != null) data['min_price'] = minPrice;
    if (maxPrice != null) data['max_price'] = maxPrice;
    if (minRating != null) data['min_rating'] = minRating;
    if (isVegetarian == true) data['is_vegetarian'] = true;
    if (isVegan == true) data['is_vegan'] = true;
    if (isGlutenFree == true) data['is_gluten_free'] = true;
    if (isSpicy == true) data['is_spicy'] = true;
    if (isFeatured == true) data['is_featured'] = true;
    if (maxPrepTime != null) data['max_prep_time'] = maxPrepTime;
    if (sortBy != null) data['sort_by'] = sortBy;
    if (sortOrder != null) data['sort_order'] = sortOrder;
    return data;
  }

  bool get hasActiveFilters {
    return categoryId != null ||
        restaurantId != null ||
        foodNationalityId != null ||
        governorateId != null ||
        minPrice != null ||
        maxPrice != null ||
        minRating != null ||
        maxPrepTime != null ||
        isVegetarian == true ||
        isVegan == true ||
        isGlutenFree == true ||
        isSpicy == true ||
        isFeatured == true;
  }

  int get activeFiltersCount {
    int count = 0;
    if (categoryId != null) count++;
    if (restaurantId != null) count++;
    if (foodNationalityId != null) count++;
    if (governorateId != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minRating != null) count++;
    if (maxPrepTime != null) count++;
    if (isVegetarian == true) count++;
    if (isVegan == true) count++;
    if (isGlutenFree == true) count++;
    if (isSpicy == true) count++;
    if (isFeatured == true) count++;
    return count;
  }
}

