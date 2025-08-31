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
      sizes: _extractSizes(json['additionalOptions']),
      additionalOptions: _extractAdditionalOptions(json['additionalOptions']),
      images: List<String>.from(json['images'] ?? [json['primary_image'] ?? '']),
      categoryId: json['internal_category_id'] ?? json['categoryId'] ?? json['category']?['id'],
    );
  }

  // Helper methods for extracting data from backend response
  static List<String> _extractSizes(dynamic additionalOptions) {
    if (additionalOptions is List) {
      for (var group in additionalOptions) {
        if (group is Map<String, dynamic>) {
          String groupName = '';
          if (group['group_name'] is Map<String, dynamic>) {
            groupName = group['group_name']['current'] ?? group['group_name']['en'] ?? '';
          } else {
            groupName = group['group_name']?.toString() ?? '';
          }

          if (groupName.toLowerCase().contains('size')) {
            List<String> sizes = [];
            if (group['options'] is List) {
              for (var option in group['options']) {
                if (option is Map<String, dynamic>) {
                  String optionName = '';
                  if (option['name'] is Map<String, dynamic>) {
                    optionName = option['name']['current'] ?? option['name']['en'] ?? '';
                  } else {
                    optionName = option['name']?.toString() ?? '';
                  }
                  if (optionName.isNotEmpty) {
                    sizes.add(optionName);
                  }
                }
              }
            }
            return sizes.isNotEmpty ? sizes : ['S', 'M', 'L'];
          }
        }
      }
    }
    return ['S', 'M', 'L'];
  }

  static List<AdditionalOption> _extractAdditionalOptions(dynamic additionalOptions) {
    List<AdditionalOption> options = [];
    if (additionalOptions is List) {
      for (var group in additionalOptions) {
        if (group is Map<String, dynamic> && group['options'] is List) {
          String groupName = '';
          if (group['group_name'] is Map<String, dynamic>) {
            groupName = group['group_name']['current'] ?? group['group_name']['en'] ?? '';
          } else {
            groupName = group['group_name']?.toString() ?? '';
          }

          // Skip size groups as they're handled separately
          if (groupName.toLowerCase().contains('size')) continue;

          for (var option in group['options']) {
            if (option is Map<String, dynamic>) {
              String optionName = '';
              if (option['name'] is Map<String, dynamic>) {
                optionName = option['name']['current'] ?? option['name']['en'] ?? '';
              } else {
                optionName = option['name']?.toString() ?? '';
              }

              options.add(AdditionalOption(
                id: option['id'] ?? 0,
                name: optionName,
                price: (option['price'] ?? 0).toDouble(),
                icon: 'salad', // Default icon
                isSelected: false,
              ));
            }
          }
        }
      }
    }
    return options;
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

  AdditionalOption({
    required this.id,
    required this.name,
    this.price,
    required this.icon,
    this.isSelected = false,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'icon': icon,
      'isSelected': isSelected,
    };
  }

  AdditionalOption copyWith({
    int? id,
    String? name,
    double? price,
    String? icon,
    bool? isSelected,
  }) {
    return AdditionalOption(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
