import 'package:flutter/foundation.dart';

class RestaurantModel {
  final int id;
  final String name;
  final String businessName;
  final String description;
  final String businessType;
  final String logo;
  final String coverImage;
  final LocationInfo location;
  final DeliveryInfo delivery;
  final Map<String, dynamic>? businessHours;
  final bool isOpenNow;
  final String? nextOpeningTime;
  final RatingInfo rating;
  final String status;
  final bool isFeatured;
  final bool isVerified;
  final bool hasDiscount;
  final double? discountPercentage;
  final ContactInfo contact;
  final List<String> cuisineTypes;
  final List<PopularDish> popularDishes;
  final DistanceInfo? distance;
  final RestaurantStats stats;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.businessName,
    required this.description,
    required this.businessType,
    required this.logo,
    required this.coverImage,
    required this.location,
    required this.delivery,
    this.businessHours,
    required this.isOpenNow,
    this.nextOpeningTime,
    required this.rating,
    required this.status,
    required this.isFeatured,
    required this.isVerified,
    required this.hasDiscount,
    this.discountPercentage,
    required this.contact,
    required this.cuisineTypes,
    required this.popularDishes,
    this.distance,
    required this.stats,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    try {
      return RestaurantModel(
        id: json['id'] ?? 0,
        name: _parseTranslatable(json['name']),
        businessName: _parseTranslatable(json['business_name']),
        description: _parseTranslatable(json['description']),
        businessType: json['business_type']?.toString() ?? '',
        logo: json['logo']?.toString() ?? 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
        coverImage: json['cover_image']?.toString() ?? 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
        location: _safeParseLocationInfo(json['location']),
        delivery: _safeParseDeliveryInfo(json['delivery']),
        businessHours: json['business_hours'],
        isOpenNow: json['is_open_now'] ?? true, // Default to open for demo
        nextOpeningTime: json['next_opening_time']?.toString(),
        rating: _safeParseRatingInfo(json['rating']),
        status: json['status']?.toString() ?? 'active',
        isFeatured: json['is_featured'] ?? false,
        isVerified: json['is_verified'] ?? false,
        hasDiscount: json['has_discount'] ?? false,
        discountPercentage: _parseDouble(json['discount_percentage']),
        contact: _safeParseContactInfo(json['contact']),
        cuisineTypes: _parseCuisineTypes(json),
        popularDishes: _parsePopularDishes(json),
        distance: json['distance'] != null ? _safeParseDistanceInfo(json['distance']) : null,
        stats: _safeParseRestaurantStats(json['stats']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ RESTAURANT MODEL ERROR: $e');
        print('📦 JSON DATA: $json');
      }
      rethrow;
    }
  }

  static LocationInfo _safeParseLocationInfo(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return LocationInfo.fromJson(data);
      }
      return LocationInfo.fromJson({});
    } catch (e) {
      return LocationInfo.fromJson({});
    }
  }

  static DeliveryInfo _safeParseDeliveryInfo(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return DeliveryInfo.fromJson(data);
      }
      return DeliveryInfo.fromJson({});
    } catch (e) {
      return DeliveryInfo.fromJson({});
    }
  }

  static RatingInfo _safeParseRatingInfo(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return RatingInfo.fromJson(data);
      }
      return RatingInfo.fromJson({});
    } catch (e) {
      return RatingInfo.fromJson({});
    }
  }

  static ContactInfo _safeParseContactInfo(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return ContactInfo.fromJson(data);
      }
      return ContactInfo.fromJson({});
    } catch (e) {
      return ContactInfo.fromJson({});
    }
  }

  static DistanceInfo _safeParseDistanceInfo(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return DistanceInfo.fromJson(data);
      }
      return DistanceInfo.fromJson({});
    } catch (e) {
      return DistanceInfo.fromJson({});
    }
  }

  static RestaurantStats _safeParseRestaurantStats(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return RestaurantStats.fromJson(data);
      }
      return RestaurantStats.fromJson({});
    } catch (e) {
      return RestaurantStats.fromJson({});
    }
  }

  static List<String> _parseCuisineTypes(Map<String, dynamic> json) {
    try {
      // Try different possible keys for cuisine types
      if (json['cuisine_types'] != null) {
        if (json['cuisine_types'] is List) {
          return List<String>.from(json['cuisine_types']);
        }
      }
      if (json['business_type'] != null) {
        return [json['business_type'].toString()];
      }
      return ['مطعم'];
    } catch (e) {
      return ['مطعم'];
    }
  }

  static List<PopularDish> _parsePopularDishes(Map<String, dynamic> json) {
    try {
      if (json['popular_dishes'] != null && json['popular_dishes'] is List) {
        return (json['popular_dishes'] as List<dynamic>)
            .map((dish) => PopularDish.fromJson(dish))
            .toList();
      }
      // Return empty list if no popular dishes
      return [];
    } catch (e) {
      return [];
    }
  }

  static String _parseTranslatable(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['current'] ?? value['ar'] ?? value['en'] ?? '';
    }
    if (value is List && value.isNotEmpty) {
      // Handle array format - take first item
      return _parseTranslatable(value.first);
    }
    return value.toString();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class LocationInfo {
  final String address;
  final String city;
  final String area;
  final double? latitude;
  final double? longitude;

  LocationInfo({
    required this.address,
    required this.city,
    required this.area,
    this.latitude,
    this.longitude,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      address: RestaurantModel._parseTranslatable(json['address']),
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      latitude: RestaurantModel._parseDouble(json['latitude']),
      longitude: RestaurantModel._parseDouble(json['longitude']),
    );
  }
}

class DeliveryInfo {
  final double? radius;
  final double? fee;
  final double? minimumOrder;
  final String estimatedTime;

  DeliveryInfo({
    this.radius,
    this.fee,
    this.minimumOrder,
    required this.estimatedTime,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      radius: RestaurantModel._parseDouble(json['radius'] ?? json['delivery_radius']),
      fee: RestaurantModel._parseDouble(json['fee'] ?? json['delivery_fee']) ?? 5.0,
      minimumOrder: RestaurantModel._parseDouble(json['minimum_order'] ?? json['minimum_order_amount']),
      estimatedTime: json['estimated_time'] ?? json['delivery_time'] ?? '25-35 دقيقة',
    );
  }
}

class RatingInfo {
  final double average;
  final int count;
  final Map<int, int> stars;

  RatingInfo({
    required this.average,
    required this.count,
    required this.stars,
  });

  factory RatingInfo.fromJson(Map<String, dynamic> json) {
    return RatingInfo(
      average: RestaurantModel._parseDouble(json['average']) ?? 4.5,
      count: json['count'] ?? 0,
      stars: Map<int, int>.from(json['stars'] ?? {}),
    );
  }
}

class ContactInfo {
  final String? phone;
  final String? email;

  ContactInfo({
    this.phone,
    this.email,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class PopularDish {
  final int id;
  final String name;
  final String image;
  final double price;

  PopularDish({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  factory PopularDish.fromJson(Map<String, dynamic> json) {
    try {
      return PopularDish(
        id: json['id'] ?? 0,
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        price: RestaurantModel._parseDouble(json['price']) ?? 0.0,
      );
    } catch (e) {
      return PopularDish(
        id: 0,
        name: '',
        image: '',
        price: 0.0,
      );
    }
  }
}

class DistanceInfo {
  final double value;
  final String unit;
  final String text;

  DistanceInfo({
    required this.value,
    required this.unit,
    required this.text,
  });

  factory DistanceInfo.fromJson(Map<String, dynamic> json) {
    return DistanceInfo(
      value: RestaurantModel._parseDouble(json['value']) ?? 0.0,
      unit: json['unit'] ?? 'km',
      text: json['text'] ?? '0 km',
    );
  }
}

class RestaurantStats {
  final int totalProducts;
  final int categoriesCount;
  final int ordersCount;

  RestaurantStats({
    required this.totalProducts,
    required this.categoriesCount,
    required this.ordersCount,
  });

  factory RestaurantStats.fromJson(Map<String, dynamic> json) {
    return RestaurantStats(
      totalProducts: json['total_products'] ?? 0,
      categoriesCount: json['categories_count'] ?? 0,
      ordersCount: json['orders_count'] ?? 0,
    );
  }
}
