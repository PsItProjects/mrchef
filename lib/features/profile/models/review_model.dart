import 'package:mrsheaf/core/localization/currency_helper.dart';

class ReviewModel {
  final int id;
  final int? productId;
  final int? orderId;
  final String productName;
  final double productPrice;
  final String productImage;
  final int rating;
  final DateTime reviewDate;
  final String reviewText;
  final List<String> images;
  final bool isVerifiedPurchase;
  final int likesCount;
  final int dislikesCount;

  ReviewModel({
    required this.id,
    this.productId,
    this.orderId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.rating,
    required this.reviewDate,
    required this.reviewText,
    this.images = const [],
    this.isVerifiedPurchase = false,
    this.likesCount = 0,
    this.dislikesCount = 0,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      productId: json['productId'] ?? json['product_id'],
      orderId: json['orderId'] ?? json['order_id'],
      productName: json['productName'] ?? json['product_name'] ?? 'Unknown Product',
      productPrice: (json['productPrice'] ?? json['product_price'] ?? 0).toDouble(),
      productImage: json['productImage'] ?? json['product_image'] ?? '',
      rating: json['rating'] ?? 0,
      reviewDate: DateTime.parse(json['reviewDate'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      reviewText: json['reviewText'] ?? json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? json['is_verified_purchase'] ?? false,
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? json['dislikes_count'] ?? 0,
    );
  }
  
  /// Factory for parsing API response
  factory ReviewModel.fromApiJson(Map<String, dynamic> json) {
    // Handle nested product data
    final product = json['product'] as Map<String, dynamic>?;

    return ReviewModel(
      id: json['id'] ?? 0,
      productId: json['product_id'],
      orderId: json['order_id'],
      productName: product?['name'] ?? json['product_name'] ?? 'Unknown Product',
      productPrice: (product?['price'] ?? json['product_price'] ?? 0).toDouble(),
      productImage: product?['image'] ?? json['product_image'] ?? '',
      rating: json['rating'] ?? 0,
      reviewDate: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      reviewText: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      isVerifiedPurchase: json['is_verified_purchase'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      dislikesCount: json['dislikes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'orderId': orderId,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'rating': rating,
      'reviewDate': reviewDate.toIso8601String(),
      'reviewText': reviewText,
      'images': images,
      'isVerifiedPurchase': isVerifiedPurchase,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
    };
  }

  ReviewModel copyWith({
    int? id,
    int? productId,
    int? orderId,
    String? productName,
    double? productPrice,
    String? productImage,
    int? rating,
    DateTime? reviewDate,
    String? reviewText,
    List<String>? images,
    bool? isVerifiedPurchase,
    int? likesCount,
    int? dislikesCount,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
      rating: rating ?? this.rating,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewText: reviewText ?? this.reviewText,
      images: images ?? this.images,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
    );
  }

  // Helper getters
  String get formattedPrice => CurrencyHelper.formatPrice(productPrice);

  String get formattedDate {
    return '${reviewDate.day.toString().padLeft(2, '0')}/${reviewDate.month.toString().padLeft(2, '0')}/${reviewDate.year}';
  }

  List<bool> get starRatings {
    return List.generate(5, (index) => index < rating);
  }

  String get ratingText {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'No Rating';
    }
  }
}
