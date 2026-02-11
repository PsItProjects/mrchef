import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Model for Merchant Product
class MerchantProductModel {
  final int id;
  final int restaurantId;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final int? categoryId;
  final String? categoryName;
  final double basePrice;
  final String discountType;
  final double? discountPercentage;
  final double? discountedPrice;
  final bool isAvailable;
  final bool isFeatured;
  final bool isPopular;
  final int preparationTime;
  final String? sku;
  final int? calories;
  final List<String>? ingredients;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isSpicy;
  final String? primaryImage;
  final List<String> images;
  final List<ProductOptionGroup> optionGroups;
  final int totalOrders;
  final double averageRating;
  final int reviewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantProductModel({
    required this.id,
    required this.restaurantId,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
    this.categoryId,
    this.categoryName,
    required this.basePrice,
    this.discountType = 'percentage',
    this.discountPercentage,
    this.discountedPrice,
    required this.isAvailable,
    required this.isFeatured,
    required this.isPopular,
    required this.preparationTime,
    this.sku,
    this.calories,
    this.ingredients,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
    required this.isSpicy,
    this.primaryImage,
    required this.images,
    required this.optionGroups,
    required this.totalOrders,
    required this.averageRating,
    required this.reviewsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get localized name
  String get name {
    final isArabic = Get.locale?.languageCode == 'ar';
    return isArabic ? nameAr : nameEn;
  }

  /// Get localized description
  String? get description {
    final isArabic = Get.locale?.languageCode == 'ar';
    return isArabic ? descriptionAr : descriptionEn;
  }

  /// Get effective price (discounted or base)
  double get effectivePrice {
    if (discountType == 'fixed' && discountedPrice != null && discountedPrice! > 0) {
      return discountedPrice!;
    }
    if (discountType == 'percentage' && discountPercentage != null && discountPercentage! > 0) {
      return basePrice - (basePrice * discountPercentage! / 100);
    }
    return discountedPrice ?? basePrice;
  }

  /// Check if product has discount
  bool get hasDiscount {
    if (discountType == 'fixed') {
      return discountedPrice != null && discountedPrice! > 0 && discountedPrice! < basePrice;
    }
    return discountPercentage != null && discountPercentage! > 0;
  }

  /// Get calculated discount percentage (works for both types)
  double get calculatedDiscountPercentage {
    if (discountType == 'fixed' && discountedPrice != null && basePrice > 0) {
      return ((basePrice - discountedPrice!) / basePrice) * 100;
    }
    return discountPercentage ?? 0;
  }

  /// Factory method to create from JSON
  factory MerchantProductModel.fromJson(Map<String, dynamic> json) {
    // Extract base price from 'price' object
    double basePrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is Map) {
        basePrice = _parseDouble(json['price']['amount']);
      } else {
        basePrice = _parseDouble(json['price']);
      }
    }

    // Extract discount price from 'discount_price' object
    double? discountPrice;
    if (json['discount_price'] != null) {
      if (json['discount_price'] is Map) {
        discountPrice = _parseDouble(json['discount_price']['amount']);
      } else {
        discountPrice = _parseDouble(json['discount_price']);
      }
    }

    // Debug: Print price extraction
    if (kDebugMode) {
      print('💰 Price extraction for product ${json['id']}:');
      print('   price field: ${json['price']}');
      print('   discount_price field: ${json['discount_price']}');
      print('   extracted basePrice: $basePrice');
      print('   extracted discountPrice: $discountPrice');
    }

    // Extract restaurant_id from either direct field or nested availability object
    int restaurantId = 0;
    if (json['restaurant_id'] != null) {
      restaurantId = json['restaurant_id'];
    } else if (json['restaurant'] != null && json['restaurant'] is Map) {
      restaurantId = json['restaurant']['id'] ?? 0;
    }

    // Extract availability from either direct field or nested object
    bool isAvailable = true;
    if (json['is_available'] != null) {
      isAvailable = json['is_available'];
    } else if (json['availability'] != null && json['availability'] is Map) {
      isAvailable = json['availability']['is_available'] ?? true;
    }

    // Extract dietary info
    bool isVegetarian = false;
    bool isVegan = false;
    bool isGlutenFree = false;
    bool isSpicy = false;

    if (json['dietary_info'] != null && json['dietary_info'] is Map) {
      isVegetarian = json['dietary_info']['is_vegetarian'] ?? false;
      isVegan = json['dietary_info']['is_vegan'] ?? false;
      isGlutenFree = json['dietary_info']['is_gluten_free'] ?? false;
      isSpicy = json['dietary_info']['is_spicy'] ?? false;
    } else {
      isVegetarian = json['is_vegetarian'] ?? false;
      isVegan = json['is_vegan'] ?? false;
      isGlutenFree = json['is_gluten_free'] ?? false;
      isSpicy = json['is_spicy'] ?? false;
    }

    return MerchantProductModel(
      id: json['id'] ?? 0,
      restaurantId: restaurantId,
      nameEn: _extractTranslation(json['name'], 'en') ?? '',
      nameAr: _extractTranslation(json['name'], 'ar') ?? '',
      descriptionEn: _extractTranslation(json['description'], 'en'),
      descriptionAr: _extractTranslation(json['description'], 'ar'),
      categoryId: json['internal_category_id'] ?? json['category_id'],
      categoryName: _extractCategoryName(json),
      basePrice: basePrice,
      discountType: json['discount_type'] ?? 'percentage',
      discountPercentage: _parseDouble(json['discount_percentage']),
      discountedPrice: discountPrice,
      isAvailable: isAvailable,
      isFeatured: json['is_featured'] ?? false,
      isPopular: json['is_popular'] ?? false,
      preparationTime: json['preparation_time'] ?? 30,
      sku: json['sku'],
      calories: json['calories'],
      ingredients: _parseStringList(json['ingredients']),
      isVegetarian: isVegetarian,
      isVegan: isVegan,
      isGlutenFree: isGlutenFree,
      isSpicy: isSpicy,
      primaryImage: _extractPrimaryImage(json),
      images: _extractImages(json),
      optionGroups: _extractOptionGroups(json),
      totalOrders: json['total_orders'] ?? 0,
      averageRating: _parseDouble(json['average_rating']),
      reviewsCount: json['reviews_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': {'en': nameEn, 'ar': nameAr},
      'description': {'en': descriptionEn, 'ar': descriptionAr},
      'internal_category_id': categoryId,
      'base_price': basePrice,
      'discount_type': discountType,
      'discount_percentage': discountPercentage,
      'discounted_price': discountedPrice,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'is_popular': isPopular,
      'preparation_time': preparationTime,
      'sku': sku,
      'calories': calories,
      'ingredients': ingredients,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_gluten_free': isGlutenFree,
      'is_spicy': isSpicy,
      'primary_image': primaryImage,
      'images': images,
      'option_groups': optionGroups.map((og) => og.toJson()).toList(),
      'total_orders': totalOrders,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Helper methods
  static String? _extractTranslation(dynamic value, String locale) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return value[locale]?.toString();
    return null;
  }

  static String? _extractCategoryName(Map<String, dynamic> json) {
    final category = json['internal_category'] ?? json['category'];
    if (category == null) return null;
    return _extractTranslation(category['name'], Get.locale?.languageCode ?? 'en');
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    // API returns ingredients as {en: [...], ar: [...], current: [...]}
    if (value is Map) {
      final current = value['current'] ?? value['en'];
      if (current is List) return current.map((e) => e.toString()).toList();
    }
    return null;
  }

  static String? _extractPrimaryImage(Map<String, dynamic> json) {
    String? result;

    if (json['primary_image'] != null) {
      if (json['primary_image'] is String) {
        result = json['primary_image'];
      } else if (json['primary_image'] is Map) {
        result = json['primary_image']['url'] ?? json['primary_image'];
      }
    }

    if (result == null && json['images'] != null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      final firstImage = (json['images'] as List).first;
      if (firstImage is String) {
        result = firstImage;
      } else if (firstImage is Map) {
        result = firstImage['url'] ?? firstImage;
      }
    }

    if (kDebugMode) {
      print('🖼️ Image extraction for product ${json['id']}:');
      print('   primary_image field: ${json['primary_image']}');
      print('   images field: ${json['images']}');
      print('   extracted primaryImage: $result');
    }

    return result;
  }

  static List<String> _extractImages(Map<String, dynamic> json) {
    final images = <String>[];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img is Map && img['url'] != null) {
          images.add(img['url']);
        } else if (img is String) {
          images.add(img);
        }
      }
    }
    return images;
  }

  static List<ProductOptionGroup> _extractOptionGroups(Map<String, dynamic> json) {
    final optionGroups = <ProductOptionGroup>[];
    if (json['option_groups'] != null && json['option_groups'] is List) {
      for (var og in json['option_groups']) {
        optionGroups.add(ProductOptionGroup.fromJson(og));
      }
    }
    return optionGroups;
  }

  /// Copy with method
  MerchantProductModel copyWith({
    int? id,
    int? restaurantId,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    int? categoryId,
    String? categoryName,
    double? basePrice,
    String? discountType,
    double? discountPercentage,
    double? discountedPrice,
    bool? isAvailable,
    bool? isFeatured,
    bool? isPopular,
    int? preparationTime,
    String? sku,
    int? calories,
    List<String>? ingredients,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isSpicy,
    String? primaryImage,
    List<String>? images,
    List<ProductOptionGroup>? optionGroups,
    int? totalOrders,
    double? averageRating,
    int? reviewsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantProductModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      basePrice: basePrice ?? this.basePrice,
      discountType: discountType ?? this.discountType,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      preparationTime: preparationTime ?? this.preparationTime,
      sku: sku ?? this.sku,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isSpicy: isSpicy ?? this.isSpicy,
      primaryImage: primaryImage ?? this.primaryImage,
      images: images ?? this.images,
      optionGroups: optionGroups ?? this.optionGroups,
      totalOrders: totalOrders ?? this.totalOrders,
      averageRating: averageRating ?? this.averageRating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model for Product Option Group
class ProductOptionGroup {
  final int? id;
  final String nameEn;
  final String nameAr;
  final String type; // size, addon, ingredient, customization
  final bool isRequired;
  final int minSelections;
  final int maxSelections;
  final int sortOrder;
  final bool isActive;
  final List<ProductOption> options;

  ProductOptionGroup({
    this.id,
    required this.nameEn,
    required this.nameAr,
    required this.type,
    required this.isRequired,
    required this.minSelections,
    required this.maxSelections,
    required this.sortOrder,
    required this.isActive,
    required this.options,
  });

  String get name {
    final isArabic = Get.locale?.languageCode == 'ar';
    return isArabic ? nameAr : nameEn;
  }

  factory ProductOptionGroup.fromJson(Map<String, dynamic> json) {
    return ProductOptionGroup(
      id: json['id'],
      nameEn: MerchantProductModel._extractTranslation(json['name'], 'en') ?? '',
      nameAr: MerchantProductModel._extractTranslation(json['name'], 'ar') ?? '',
      type: json['type'] ?? 'addon',
      isRequired: json['is_required'] ?? false,
      minSelections: json['min_selections'] ?? 0,
      maxSelections: json['max_selections'] ?? 1,
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      options: (json['options'] as List?)?.map((o) => ProductOption.fromJson(o)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': {'en': nameEn, 'ar': nameAr},
      'type': type,
      'is_required': isRequired,
      'min_selections': minSelections,
      'max_selections': maxSelections,
      'sort_order': sortOrder,
      'is_active': isActive,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

/// Model for Product Option
class ProductOption {
  final int? id;
  final String nameEn;
  final String nameAr;
  final double priceModifier;
  final String? imagePath;
  final bool isAvailable;
  final int sortOrder;

  ProductOption({
    this.id,
    required this.nameEn,
    required this.nameAr,
    required this.priceModifier,
    this.imagePath,
    required this.isAvailable,
    required this.sortOrder,
  });

  String get name {
    final isArabic = Get.locale?.languageCode == 'ar';
    return isArabic ? nameAr : nameEn;
  }

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id'],
      nameEn: MerchantProductModel._extractTranslation(json['name'], 'en') ?? '',
      nameAr: MerchantProductModel._extractTranslation(json['name'], 'ar') ?? '',
      priceModifier: MerchantProductModel._parseDouble(json['price_modifier']),
      imagePath: json['image_path'],
      isAvailable: json['is_available'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': {'en': nameEn, 'ar': nameAr},
      'price_modifier': priceModifier,
      'image_path': imagePath,
      'is_available': isAvailable,
      'sort_order': sortOrder,
    };
  }
}

/// Input model for creating/editing option groups (simplified for forms)
class ProductOptionGroupInput {
  String nameEn;
  String nameAr;
  String type;
  bool isRequired;
  int? minSelections;
  int? maxSelections;
  int sortOrder;
  List<ProductOptionInput> options;

  ProductOptionGroupInput({
    required this.nameEn,
    required this.nameAr,
    required this.type,
    required this.isRequired,
    this.minSelections,
    this.maxSelections,
    this.sortOrder = 0,
    required this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'name_en': nameEn,
      'name_ar': nameAr,
      'type': type,
      'is_required': isRequired,
      if (minSelections != null) 'min_selections': minSelections,
      if (maxSelections != null) 'max_selections': maxSelections,
      'sort_order': sortOrder,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

/// Input model for creating/editing options (simplified for forms)
class ProductOptionInput {
  String nameEn;
  String nameAr;
  double? priceModifier;
  bool isAvailable;
  int sortOrder;

  ProductOptionInput({
    required this.nameEn,
    required this.nameAr,
    this.priceModifier,
    this.isAvailable = true,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name_en': nameEn,
      'name_ar': nameAr,
      if (priceModifier != null) 'price_modifier': priceModifier,
      'is_available': isAvailable,
      'sort_order': sortOrder,
    };
  }
}
