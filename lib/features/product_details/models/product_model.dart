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
  final int? categoryId; // إضافة معرف التصنيف

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
    this.categoryId, // إضافة معرف التصنيف
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
        return (ratingField['average'] ?? 4.5).toDouble();
      }
      return (ratingField ?? 4.5).toDouble();
    }

    int getReviewCount(dynamic reviewField) {
      if (reviewField is Map<String, dynamic>) {
        return reviewField['count'] ?? 0;
      }
      return reviewField ?? 0;
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

    return ProductModel(
      id: json['id'],
      name: getName(json['name']),
      description: getDescription(json['description']),
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      image: getImageUrl(json['primary_image']),
      rating: getRating(json['rating']),
      reviewCount: getReviewCount(json['reviewCount'] ?? json['rating']),
      productCode: json['productCode'] ?? 'N/A',
      sizes: _extractSizes(json['sizes']),
      rawSizes: _extractRawSizes(json['sizes']),
      additionalOptions: _extractAdditionalOptions(json['additionalOptions']),
      images: List<String>.from(json['images'] ?? [json['primary_image'] ?? '']),
      categoryId: json['internal_category_id'] ?? json['categoryId'] ?? json['category']?['id'],
    );
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
      'categoryId': categoryId, // إضافة معرف التصنيف
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
