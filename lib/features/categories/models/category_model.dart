// Backend-compatible category model
class BackendCategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final int productsCount;
  final int? availableProductsCount;
  final List<BackendCategoryModel>? subCategories;
  final bool isSelected;

  BackendCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.sortOrder,
    required this.isActive,
    required this.productsCount,
    this.availableProductsCount,
    this.subCategories,
    this.isSelected = false,
  });

  factory BackendCategoryModel.fromJson(Map<String, dynamic> json) {
    return BackendCategoryModel(
      id: json['id'] ?? 0,
      name: _extractName(json['name']),
      description: _extractDescription(json['description']),
      image: json['image'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      productsCount: json['products_count'] ?? json['available_products_count'] ?? 0,
      availableProductsCount: json['available_products_count'],
      subCategories: json['sub_categories'] != null
          ? (json['sub_categories'] as List)
              .map((subCat) => BackendCategoryModel.fromJson(subCat))
              .toList()
          : null,
    );
  }

  static String _extractName(dynamic nameData) {
    if (nameData is String) return nameData;
    if (nameData is Map) {
      return nameData['en'] ?? nameData['ar'] ?? 'Unknown Category';
    }
    return 'Unknown Category';
  }

  static String? _extractDescription(dynamic descData) {
    if (descData == null) return null;
    if (descData is String) return descData;
    if (descData is Map) {
      return descData['en'] ?? descData['ar'];
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'sort_order': sortOrder,
      'is_active': isActive,
      'products_count': productsCount,
      'available_products_count': availableProductsCount,
      'sub_categories': subCategories?.map((sub) => sub.toJson()).toList(),
      'isSelected': isSelected,
    };
  }

  BackendCategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    int? sortOrder,
    bool? isActive,
    int? productsCount,
    int? availableProductsCount,
    List<BackendCategoryModel>? subCategories,
    bool? isSelected,
  }) {
    return BackendCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      productsCount: productsCount ?? this.productsCount,
      availableProductsCount: availableProductsCount ?? this.availableProductsCount,
      subCategories: subCategories ?? this.subCategories,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Convert to legacy CategoryModel for UI compatibility
  CategoryModel toLegacyModel() {
    return CategoryModel(
      id: id,
      name: name,
      icon: 'category_$id', // Generate icon name based on ID
      itemCount: productsCount,
      isSelected: isSelected,
    );
  }
}

// Legacy category model for UI compatibility
class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final int itemCount;
  final bool isSelected;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.itemCount,
    this.isSelected = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      itemCount: json['itemCount'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'itemCount': itemCount,
      'isSelected': isSelected,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    int? itemCount,
    bool? isSelected,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      itemCount: itemCount ?? this.itemCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class KitchenModel {
  final int id;
  final String name;
  final String image;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> specialties;

  KitchenModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.specialties,
  });

  factory KitchenModel.fromJson(Map<String, dynamic> json) {
    return KitchenModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      description: json['description'],
      specialties: List<String>.from(json['specialties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'specialties': specialties,
    };
  }
}

class FilterModel {
  final String title;
  final List<FilterOption> options;
  final bool isExpanded;

  FilterModel({
    required this.title,
    required this.options,
    this.isExpanded = false,
  });

  FilterModel copyWith({
    String? title,
    List<FilterOption>? options,
    bool? isExpanded,
  }) {
    return FilterModel(
      title: title ?? this.title,
      options: options ?? this.options,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class FilterOption {
  final int id;
  final String name;
  final int count;
  final bool isSelected;
  final double? rating;

  FilterOption({
    required this.id,
    required this.name,
    required this.count,
    this.isSelected = false,
    this.rating,
  });

  FilterOption copyWith({
    int? id,
    String? name,
    int? count,
    bool? isSelected,
    double? rating,
  }) {
    return FilterOption(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      isSelected: isSelected ?? this.isSelected,
      rating: rating ?? this.rating,
    );
  }
}
