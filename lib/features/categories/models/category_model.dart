import 'package:get/get.dart';
import 'package:mrsheaf/core/services/language_service.dart';

class CategoryModel {
  final int id;
  final dynamic name; // Can be String or Map<String, dynamic> for multilingual
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
      name: json['name'], // Keep as dynamic to support both String and Map
      icon: json['icon'] ?? 'default',
      itemCount: json['itemCount'] ?? 0,
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
    dynamic name,
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

  /// Get translated name based on current language
  String get displayName {
    if (name is Map<String, dynamic>) {
      try {
        final languageService = Get.find<LanguageService>();
        final currentLang = languageService.currentLanguage;
        return name[currentLang] ?? name['ar'] ?? name['en'] ?? '';
      } catch (e) {
        return name['ar'] ?? name['en'] ?? '';
      }
    }
    return name?.toString() ?? '';
  }
}

class KitchenModel {
  final int id;
  final int merchantId;
  final String name;
  final String businessName;
  final String description;
  final String businessType;
  final String phone;
  final String email;
  final String? logo;
  final String? coverImage;
  final Map<String, dynamic>? businessHours;
  final double deliveryFee;
  final double minimumOrder;
  final int deliveryRadius;
  final int preparationTime;
  final String? address;
  final String? city;
  final String? area;
  final double averageRating;
  final int reviewsCount;
  final int totalProducts;
  final int availableProducts;
  final bool isActive;
  final bool isFeatured;
  final bool isVerified;
  final bool acceptsOnlinePayment;
  final bool offersDelivery;
  final bool offersPickup;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? merchant;
  final List<Map<String, dynamic>>? categories;
  final List<Map<String, dynamic>>? products;

  KitchenModel({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.businessName,
    required this.description,
    required this.businessType,
    required this.phone,
    required this.email,
    this.logo,
    this.coverImage,
    this.businessHours,
    required this.deliveryFee,
    required this.minimumOrder,
    required this.deliveryRadius,
    required this.preparationTime,
    this.address,
    this.city,
    this.area,
    required this.averageRating,
    required this.reviewsCount,
    required this.totalProducts,
    required this.availableProducts,
    this.isActive = true,
    this.isFeatured = false,
    this.isVerified = false,
    this.acceptsOnlinePayment = true,
    this.offersDelivery = true,
    this.offersPickup = false,
    required this.createdAt,
    required this.updatedAt,
    this.merchant,
    this.categories,
    this.products,
  });

  factory KitchenModel.fromJson(Map<String, dynamic> json) {
    return KitchenModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      name: _getTranslatedText(json['name']),
      businessName: _getTranslatedText(json['business_name']),
      description: _getTranslatedText(json['description']),
      businessType: json['business_type'] ?? 'restaurant',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      logo: json['logo'],
      coverImage: json['cover_image'],
      businessHours: json['business_hours'],
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      minimumOrder: double.tryParse(json['minimum_order']?.toString() ?? '0') ?? 0.0,
      deliveryRadius: json['delivery_radius'] ?? 0,
      preparationTime: json['preparation_time'] ?? 0,
      address: _getTranslatedText(json['address']),
      city: json['city'],
      area: json['area'],
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      availableProducts: json['available_products'] ?? 0,
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      isVerified: json['is_verified'] ?? false,
      acceptsOnlinePayment: json['accepts_online_payment'] ?? true,
      offersDelivery: json['offers_delivery'] ?? true,
      offersPickup: json['offers_pickup'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      merchant: json['merchant'],
      categories: json['categories'] != null ? List<Map<String, dynamic>>.from(json['categories']) : null,
      products: json['products'] != null ? List<Map<String, dynamic>>.from(json['products']) : null,
    );
  }

  static String _getTranslatedText(dynamic field) {
    if (field is Map<String, dynamic>) {
      try {
        // Try to get current language from LanguageService
        final languageService = Get.find<LanguageService>();
        final currentLang = languageService.currentLanguage;
        return field[currentLang] ?? field['ar'] ?? field['en'] ?? '';
      } catch (e) {
        // Fallback if LanguageService is not available
        return field['ar'] ?? field['en'] ?? '';
      }
    }
    return field?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'name': name,
      'business_name': businessName,
      'description': description,
      'business_type': businessType,
      'phone': phone,
      'email': email,
      'logo': logo,
      'cover_image': coverImage,
      'business_hours': businessHours,
      'delivery_fee': deliveryFee,
      'minimum_order': minimumOrder,
      'delivery_radius': deliveryRadius,
      'preparation_time': preparationTime,
      'address': address,
      'city': city,
      'area': area,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'total_products': totalProducts,
      'available_products': availableProducts,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_verified': isVerified,
      'accepts_online_payment': acceptsOnlinePayment,
      'offers_delivery': offersDelivery,
      'offers_pickup': offersPickup,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'merchant': merchant,
      'categories': categories,
      'products': products,
    };
  }

  // Helper getters for UI
  String get displayName => businessName.isNotEmpty ? businessName : name;
  String get displayDescription => description;
  String get displayAddress => address ?? '';
  String get deliveryTimeText => '${preparationTime} دقيقة';
  String get ratingText => averageRating.toStringAsFixed(1);
  String get reviewCountText => '$reviewsCount تقييم';
  String get minimumOrderText => '${minimumOrder.toStringAsFixed(0)} ر.س';
  String get deliveryFeeText => '${deliveryFee.toStringAsFixed(0)} ر.س';

  // For backward compatibility with existing UI
  String get image => logo ?? 'assets/images/default_restaurant.png';

  /// Get full logo URL - handles both full URLs and relative paths
  String? get logoUrl {
    if (logo == null || logo!.isEmpty) return null;
    // If already a full URL, return as-is
    if (logo!.startsWith('http://') || logo!.startsWith('https://')) {
      return logo;
    }
    // Otherwise, it's a relative path - but API returns full URL now
    return logo;
  }
  double get rating => averageRating;
  int get reviewCount => reviewsCount;
  List<String> get specialties => categories?.map((cat) => _getTranslatedText(cat['name'])).toList() ?? [];
  String get deliveryTime => deliveryTimeText;
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
