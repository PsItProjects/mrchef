class SearchFilterModel {
  final int? categoryId;
  final int? restaurantId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool? isVegetarian;
  final bool? isSpicy;
  final bool? isFeatured;
  final String? sortBy; // 'price', 'rating', 'name', 'created_at'
  final String? sortOrder; // 'asc', 'desc'

  SearchFilterModel({
    this.categoryId,
    this.restaurantId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.isVegetarian,
    this.isSpicy,
    this.isFeatured,
    this.sortBy,
    this.sortOrder,
  });

  SearchFilterModel copyWith({
    int? categoryId,
    int? restaurantId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? isVegetarian,
    bool? isSpicy,
    bool? isFeatured,
    String? sortBy,
    String? sortOrder,
  }) {
    return SearchFilterModel(
      categoryId: categoryId ?? this.categoryId,
      restaurantId: restaurantId ?? this.restaurantId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isSpicy: isSpicy ?? this.isSpicy,
      isFeatured: isFeatured ?? this.isFeatured,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (categoryId != null) data['category_id'] = categoryId;
    if (restaurantId != null) data['restaurant_id'] = restaurantId;
    if (minPrice != null) data['min_price'] = minPrice;
    if (maxPrice != null) data['max_price'] = maxPrice;
    if (minRating != null) data['min_rating'] = minRating;
    if (isVegetarian != null) data['is_vegetarian'] = isVegetarian;
    if (isSpicy != null) data['is_spicy'] = isSpicy;
    if (isFeatured != null) data['is_featured'] = isFeatured;
    if (sortBy != null) data['sort_by'] = sortBy;
    if (sortOrder != null) data['sort_order'] = sortOrder;
    
    return data;
  }

  bool get hasActiveFilters {
    return categoryId != null ||
        restaurantId != null ||
        minPrice != null ||
        maxPrice != null ||
        minRating != null ||
        isVegetarian == true ||
        isSpicy == true ||
        isFeatured == true;
  }

  int get activeFiltersCount {
    int count = 0;
    if (categoryId != null) count++;
    if (restaurantId != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minRating != null) count++;
    if (isVegetarian == true) count++;
    if (isSpicy == true) count++;
    if (isFeatured == true) count++;
    return count;
  }

  void clear() {
    // This will be handled by creating a new instance
  }
}

