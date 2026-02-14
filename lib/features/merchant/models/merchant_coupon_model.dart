import 'package:get/get.dart';

class MerchantCouponModel {
  final int id;
  final String code;
  final Map<String, String?> title;
  final Map<String, String?>? description;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final double? maxDiscountAmount;
  final double? minOrderAmount;
  final int? maxUsesTotal;
  final int? maxUsesPerCustomer;
  final int usedCount;
  final bool isActive;
  final String appliesTo; // 'all' or 'specific'
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final int productsCount;
  final int redemptionsCount;
  final String status; // 'active', 'inactive', 'scheduled', 'expired', 'exhausted'
  final DateTime? createdAt;
  final List<CouponProductModel>? products;

  MerchantCouponModel({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.type,
    required this.value,
    this.maxDiscountAmount,
    this.minOrderAmount,
    this.maxUsesTotal,
    this.maxUsesPerCustomer,
    this.usedCount = 0,
    required this.isActive,
    required this.appliesTo,
    this.startsAt,
    this.expiresAt,
    this.productsCount = 0,
    this.redemptionsCount = 0,
    this.status = 'active',
    this.createdAt,
    this.products,
  });

  factory MerchantCouponModel.fromJson(Map<String, dynamic> json) {
    return MerchantCouponModel(
      id: json['id'] as int,
      code: json['code'] as String,
      title: _parseLocalizedMap(json['title']),
      description: json['description'] != null ? _parseLocalizedMap(json['description']) : null,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      maxDiscountAmount: json['max_discount_amount'] != null ? (json['max_discount_amount'] as num).toDouble() : null,
      minOrderAmount: json['min_order_amount'] != null ? (json['min_order_amount'] as num).toDouble() : null,
      maxUsesTotal: json['max_uses_total'] as int?,
      maxUsesPerCustomer: json['max_uses_per_customer'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      appliesTo: json['applies_to'] as String? ?? 'all',
      startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      productsCount: json['products_count'] as int? ?? 0,
      redemptionsCount: json['redemptions_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      products: json['products'] != null
          ? (json['products'] as List).map((p) => CouponProductModel.fromJson(p)).toList()
          : null,
    );
  }

  static Map<String, String?> _parseLocalizedMap(dynamic value) {
    if (value is Map) {
      return {
        'ar': value['ar']?.toString(),
        'en': value['en']?.toString(),
      };
    }
    if (value is String) {
      return {'ar': value, 'en': value};
    }
    return {'ar': null, 'en': null};
  }

  String get localizedTitle {
    final locale = Get.locale?.languageCode ?? 'ar';
    return title[locale] ?? title['ar'] ?? title['en'] ?? '';
  }

  String? get localizedDescription {
    if (description == null) return null;
    final locale = Get.locale?.languageCode ?? 'ar';
    return description![locale] ?? description!['ar'] ?? description!['en'];
  }

  String get displayValue {
    if (type == 'percentage') {
      return '${value.toStringAsFixed(0)}%';
    }
    return '${value.toStringAsFixed(2)} SAR';
  }

  bool get isExpired => status == 'expired';
  bool get isScheduled => status == 'scheduled';
  bool get isExhausted => status == 'exhausted';
  bool get isCurrentlyActive => status == 'active';

  String get usageText {
    if (maxUsesTotal != null) {
      return '$usedCount / $maxUsesTotal';
    }
    return '$usedCount';
  }

  MerchantCouponModel copyWith({
    bool? isActive,
    String? status,
  }) {
    return MerchantCouponModel(
      id: id,
      code: code,
      title: title,
      description: description,
      type: type,
      value: value,
      maxDiscountAmount: maxDiscountAmount,
      minOrderAmount: minOrderAmount,
      maxUsesTotal: maxUsesTotal,
      maxUsesPerCustomer: maxUsesPerCustomer,
      usedCount: usedCount,
      isActive: isActive ?? this.isActive,
      appliesTo: appliesTo,
      startsAt: startsAt,
      expiresAt: expiresAt,
      productsCount: productsCount,
      redemptionsCount: redemptionsCount,
      status: status ?? this.status,
      createdAt: createdAt,
      products: products,
    );
  }
}

class CouponProductModel {
  final int id;
  final Map<String, String?>? name;
  final double price;

  CouponProductModel({
    required this.id,
    this.name,
    required this.price,
  });

  factory CouponProductModel.fromJson(Map<String, dynamic> json) {
    return CouponProductModel(
      id: json['id'] as int,
      name: json['name'] != null ? MerchantCouponModel._parseLocalizedMap(json['name']) : null,
      price: (json['price'] as num).toDouble(),
    );
  }

  String get localizedName {
    if (name == null) return '';
    final locale = Get.locale?.languageCode ?? 'ar';
    return name![locale] ?? name!['ar'] ?? name!['en'] ?? '';
  }
}
