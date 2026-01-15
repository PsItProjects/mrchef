class MyReviewModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final int orderId;
  final String orderNumber;
  final int rating;
  final String comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final int? likesCount;
  final int? dislikesCount;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  MyReviewModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.orderId,
    required this.orderNumber,
    required this.rating,
    required this.comment,
    required this.images,
    required this.isVerifiedPurchase,
    this.likesCount,
    this.dislikesCount,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyReviewModel.fromJson(Map<String, dynamic> json) {
    return MyReviewModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product']?['name'] ?? 'Unknown Product',
      productImage: json['product']?['image'],
      orderId: json['order_id'] as int,
      orderNumber: json['order']?['order_number'] ?? 'N/A',
      rating: json['rating'] as int,
      comment: json['comment'] ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isVerifiedPurchase: json['is_verified_purchase'] ?? false,
      likesCount: json['likes_count'] as int?,
      dislikesCount: json['dislikes_count'] as int?,
      isApproved: json['is_approved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'order_id': orderId,
      'order_number': orderNumber,
      'rating': rating,
      'comment': comment,
      'images': images,
      'is_verified_purchase': isVerifiedPurchase,
      'likes_count': likesCount,
      'dislikes_count': dislikesCount,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

