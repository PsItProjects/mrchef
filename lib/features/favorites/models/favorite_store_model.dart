import 'package:get/get.dart';

class FavoriteStoreModel {
  final int id;
  final String name;
  final String image;
  final double rating;
  final String backgroundImage;
  final String? coverImage;
  final String? description;
  final String? phone;
  final double? deliveryFee;
  final double? minimumOrder;
  final bool isActive;

  FavoriteStoreModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.backgroundImage,
    this.coverImage,
    this.description,
    this.phone,
    this.deliveryFee,
    this.minimumOrder,
    this.isActive = true,
  });

  factory FavoriteStoreModel.fromJson(Map<String, dynamic> json) {
    // Extract name from translatable field
    String extractedName = 'مطعم غير محدد';
    if (json['name'] != null) {
      if (json['name'] is Map<String, dynamic>) {
        Map<String, dynamic> nameMap = json['name'];
        String currentLocale = Get.locale?.languageCode ?? 'ar';
        extractedName = nameMap[currentLocale] ?? nameMap['ar'] ?? nameMap['en'] ?? 'مطعم غير محدد';
      } else if (json['name'] is String) {
        extractedName = json['name'];
      }
    }

    return FavoriteStoreModel(
      id: json['id'] ?? 0,
      name: extractedName,
      image: json['logo'] ?? json['image'] ?? 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
      rating: _parseRating(json['rating']),
      backgroundImage: json['cover_image'] ?? json['backgroundImage'] ?? '',
      coverImage: json['cover_image'],
      description: json['description'] is Map<String, dynamic>
          ? _extractTranslatedText(json['description'])
          : json['description']?.toString(),
      phone: json['phone']?.toString(),
      deliveryFee: _parseDouble(json['delivery_fee']),
      minimumOrder: _parseDouble(json['minimum_order']),
      isActive: json['is_active'] ?? true,
    );
  }

  /// Parse rating from different formats (String, int, double)
  static double _parseRating(dynamic rating) {
    if (rating == null) return 4.5;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) {
      return double.tryParse(rating) ?? 4.5;
    }
    return 4.5;
  }

  /// Parse double from different formats (String, int, double)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Extract translated text from translatable field
  static String? _extractTranslatedText(Map<String, dynamic>? translationMap) {
    if (translationMap == null) return null;
    String currentLocale = Get.locale?.languageCode ?? 'ar';
    return translationMap[currentLocale] ?? translationMap['ar'] ?? translationMap['en'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'backgroundImage': backgroundImage,
      'coverImage': coverImage,
      'description': description,
      'phone': phone,
      'deliveryFee': deliveryFee,
      'minimumOrder': minimumOrder,
      'isActive': isActive,
    };
  }

  FavoriteStoreModel copyWith({
    int? id,
    String? name,
    String? image,
    double? rating,
    String? backgroundImage,
    String? coverImage,
    String? description,
    String? phone,
    double? deliveryFee,
    double? minimumOrder,
    bool? isActive,
  }) {
    return FavoriteStoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
