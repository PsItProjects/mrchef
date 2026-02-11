import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String image;
  final double rating;
  final int reviewCount;
  final String productCode;
  final List<String> sizes;
  final List<Map<String, dynamic>> rawSizes; // Raw size data with IDs and prices
  final List<AdditionalOption> additionalOptions;
  final List<String> images;
  final int? categoryId;
  final int? restaurantId;
  final Map<int, int> starsBreakdown; // Star distribution {5: 70, 4: 20, ...}

  // Discount info
  final String discountType; // 'percentage' or 'fixed'
  final double discountPercentage;
  final bool hasDiscount;

  // Nutritional / dietary info
  final int? calories;
  final List<String> ingredients;
  final int preparationTime;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isSpicy;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.productCode,
    required this.sizes,
    required this.rawSizes,
    required this.additionalOptions,
    required this.images,
    this.categoryId,
    this.restaurantId,
    this.starsBreakdown = const {},
    this.discountType = 'percentage',
    this.discountPercentage = 0,
    this.hasDiscount = false,
    this.calories,
    this.ingredients = const [],
    this.preparationTime = 15,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isSpicy = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Use LanguageService to get localized text
    final languageService = LanguageService.instance;

    String getName(dynamic nameField) {
      return languageService.getLocalizedText(nameField);
    }

    String getDescription(dynamic descField) {
      return languageService.getLocalizedText(descField);
    }

    double getRating(dynamic ratingField) {
      if (ratingField is Map<String, dynamic>) {
        return (ratingField['average'] ?? 0).toDouble();
      }
      if (ratingField is num) return ratingField.toDouble();
      return 0.0;
    }

    int getReviewCount(dynamic ratingField, dynamic reviewCountField) {
      // Prefer rating.count (falls back to 0) over reviewCount (falls back to total_orders/205)
      if (ratingField is Map<String, dynamic>) {
        final count = ratingField['count'];
        if (count != null && count is int && count >= 0) return count;
      }
      if (reviewCountField is int) return reviewCountField;
      return 0;
    }

    // Handle image URL properly
    String getImageUrl(dynamic imageField) {
      if (imageField != null && imageField.toString().isNotEmpty && imageField != 'null') {
        String imageUrl = imageField.toString();
        // If it's already a full URL, return it
        if (imageUrl.startsWith('http')) {
          return imageUrl;
        }
        // If it's a relative path, construct full URL
        String baseUrl = ApiConstants.useProductionServer
            ? 'https://mr-shife-backend-main-ygodva.laravel.cloud'
            : 'http://127.0.0.1:8000';
        return '$baseUrl/storage/$imageUrl';
      }
      return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop'; // fallback image
    }

    // Extract restaurant ID from restaurant object or direct field
    int? restaurantId;
    if (json['restaurant'] != null && json['restaurant'] is Map) {
      restaurantId = json['restaurant']['id'];
    } else if (json['restaurant_id'] != null) {
      restaurantId = json['restaurant_id'];
    }

    // Helper function to safely parse price
    double parsePrice(dynamic priceField) {
      if (priceField == null) return 0.0;
      if (priceField is double) return priceField;
      if (priceField is int) return priceField.toDouble();
      if (priceField is String) {
        return double.tryParse(priceField) ?? 0.0;
      }
      return 0.0;
    }

    // Parse ingredients — could be list of strings or a single string
    List<String> parseIngredients(dynamic field) {
      if (field is List) return List<String>.from(field.map((e) => e.toString()));
      if (field is String && field.isNotEmpty) return field.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return [];
    }

    return ProductModel(
      id: json['id'],
      name: getName(json['name']),
      description: getDescription(json['description']),
      price: parsePrice(json['price']),
      originalPrice: json['originalPrice'] != null ? parsePrice(json['originalPrice']) : null,
      image: getImageUrl(json['primary_image'] ?? json['image']),
      rating: getRating(json['rating']),
      reviewCount: getReviewCount(json['rating'], json['reviewCount']),
      productCode: json['productCode'] ?? 'N/A',
      sizes: _extractSizes(json['sizes']),
      rawSizes: _extractRawSizes(json['sizes']),
      additionalOptions: _extractAdditionalOptions(json['additionalOptions']),
      images: List<String>.from(json['images'] ?? [json['primary_image'] ?? json['image'] ?? '']),
      categoryId: json['internal_category_id'] ?? json['categoryId'] ?? json['category']?['id'],
      restaurantId: restaurantId,
      starsBreakdown: _extractStarsBreakdown(json['rating']),
      // Discount
      discountType: json['discount_type']?.toString() ?? 'percentage',
      discountPercentage: parsePrice(json['discount_percentage']),
      hasDiscount: json['has_discount'] == true || (json['originalPrice'] != null && parsePrice(json['originalPrice']) > parsePrice(json['price'])),
      // Nutritional / dietary
      calories: json['calories'] is int ? json['calories'] : (json['calories'] != null ? int.tryParse(json['calories'].toString()) : null),
      ingredients: parseIngredients(json['ingredients']),
      preparationTime: json['preparation_time'] is int ? json['preparation_time'] : 15,
      isVegetarian: json['is_vegetarian'] == true,
      isVegan: json['is_vegan'] == true,
      isGlutenFree: json['is_gluten_free'] == true,
      isSpicy: json['is_spicy'] == true,
    );
  }

  /// Extract stars breakdown from rating object
  static Map<int, int> _extractStarsBreakdown(dynamic ratingField) {
    if (ratingField is Map<String, dynamic>) {
      final breakdown = ratingField['stars_breakdown'];
      if (breakdown is Map) {
        final result = <int, int>{};
        breakdown.forEach((key, value) {
          final star = int.tryParse(key.toString());
          final count = (value is int) ? value : (value is double ? value.toInt() : 0);
          if (star != null) result[star] = count;
        });
        return result;
      }
    }
    return {};
  }

  // Helper methods for extracting data from backend response
  static List<String> _extractSizes(dynamic sizesData) {
    if (sizesData is List) {
      List<String> sizes = [];
      for (var sizeObj in sizesData) {
        if (sizeObj is Map<String, dynamic>) {
          String sizeName = sizeObj['name']?.toString() ?? '';
          if (sizeName.isNotEmpty) {
            sizes.add(sizeName);
          }
        } else if (sizeObj is String) {
          sizes.add(sizeObj);
        }
      }
      if (sizes.isNotEmpty) {
        return sizes;
      }
    }
    return ['S', 'M', 'L'];
  }

  static List<Map<String, dynamic>> _extractRawSizes(dynamic sizesData) {
    if (sizesData is List) {
      List<Map<String, dynamic>> rawSizes = [];
      for (var sizeObj in sizesData) {
        if (sizeObj is Map<String, dynamic>) {
          rawSizes.add(Map<String, dynamic>.from(sizeObj));
        }
      }
      return rawSizes;
    }
    return [];
  }

  static List<AdditionalOption> _extractAdditionalOptions(dynamic additionalOptions) {
    List<AdditionalOption> options = [];
    if (additionalOptions is List) {
      // Handle flat structure (new backend response)
      for (var option in additionalOptions) {
        if (option is Map<String, dynamic>) {
          // Extract option name
          String optionName = '';
          if (option['name'] is Map<String, dynamic>) {
            optionName = option['name']['current'] ?? option['name']['ar'] ?? option['name']['en'] ?? '';
          } else {
            optionName = option['name']?.toString() ?? '';
          }

          // Extract group name
          String groupName = '';
          if (option['group_name'] is Map<String, dynamic>) {
            groupName = option['group_name']['current'] ?? option['group_name']['ar'] ?? option['group_name']['en'] ?? '';
          } else {
            groupName = option['group_name']?.toString() ?? '';
          }

          // Skip size groups as they're handled separately
          if (groupName.toLowerCase().contains('size') || groupName.toLowerCase().contains('حجم')) continue;

          options.add(AdditionalOption(
            id: option['id'] ?? 0,
            name: optionName,
            price: (option['price'] ?? 0).toDouble(),
            icon: _getIconForOption(optionName),
            isSelected: option['isSelected'] ?? false,
            isRequired: option['is_required'] ?? false,
            groupName: groupName,
            groupId: option['group_id'] ?? 0,
          ));
        }
      }
    }
    return options;
  }

  /// Get appropriate icon based on option name
  static String _getIconForOption(String optionName) {
    final name = optionName.toLowerCase();

    if (name.contains('خبز') || name.contains('bread')) return 'bread';
    if (name.contains('ليمون') || name.contains('lemon')) return 'lemon';
    if (name.contains('جبن') || name.contains('cheese')) return 'cheese';
    if (name.contains('لحم') || name.contains('meat')) return 'meat';
    if (name.contains('دجاج') || name.contains('chicken')) return 'meat';
    if (name.contains('خضار') || name.contains('vegetable')) return 'vegetable';
    if (name.contains('صوص') || name.contains('sauce')) return 'sauce';
    if (name.contains('صنوبر') || name.contains('pine')) return 'nuts';
    if (name.contains('بابريكا') || name.contains('paprika')) return 'spice';
    if (name.contains('زيت') || name.contains('oil')) return 'oil';

    return 'salad'; // Default icon
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'productCode': productCode,
      'sizes': sizes,
      'rawSizes': rawSizes,
      'additionalOptions': additionalOptions.map((option) => option.toJson()).toList(),
      'images': images,
      'categoryId': categoryId,
      'restaurantId': restaurantId,
      'starsBreakdown': starsBreakdown,
      'discount_type': discountType,
      'discount_percentage': discountPercentage,
      'has_discount': hasDiscount,
      'calories': calories,
      'ingredients': ingredients,
      'preparation_time': preparationTime,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_gluten_free': isGlutenFree,
      'is_spicy': isSpicy,
    };
  }
}

class AdditionalOption {
  final int id;
  final String name;
  final double? price;
  final String icon;
  final bool isSelected;
  final bool isRequired;
  final String? groupName;
  final int? groupId;

  AdditionalOption({
    required this.id,
    required this.name,
    this.price,
    required this.icon,
    this.isSelected = false,
    this.isRequired = false,
    this.groupName,
    this.groupId,
  });

  factory AdditionalOption.fromJson(Map<String, dynamic> json) {
    String getName(dynamic nameField) {
      if (nameField is Map<String, dynamic>) {
        return nameField['current'] ?? nameField['en'] ?? nameField.values.first ?? '';
      }
      return nameField?.toString() ?? '';
    }

    return AdditionalOption(
      id: json['id'],
      name: getName(json['name']),
      price: json['price']?.toDouble(),
      icon: json['icon'] ?? 'salad', // Default icon
      isSelected: json['isSelected'] ?? false,
      isRequired: json['isRequired'] ?? false,
      groupName: json['groupName'],
      groupId: json['groupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'icon': icon,
      'isSelected': isSelected,
      'isRequired': isRequired,
      'groupName': groupName,
      'groupId': groupId,
    };
  }

  AdditionalOption copyWith({
    int? id,
    String? name,
    double? price,
    String? icon,
    bool? isSelected,
    bool? isRequired,
    String? groupName,
    int? groupId,
  }) {
    return AdditionalOption(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
      isRequired: isRequired ?? this.isRequired,
      groupName: groupName ?? this.groupName,
      groupId: groupId ?? this.groupId,
    );
  }
}
