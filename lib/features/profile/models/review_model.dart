class ReviewModel {
  final int id;
  final String productName;
  final double productPrice;
  final String productImage;
  final int rating;
  final DateTime reviewDate;
  final String reviewText;

  ReviewModel({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.rating,
    required this.reviewDate,
    required this.reviewText,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      productName: json['productName'],
      productPrice: json['productPrice'].toDouble(),
      productImage: json['productImage'],
      rating: json['rating'],
      reviewDate: DateTime.parse(json['reviewDate']),
      reviewText: json['reviewText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'rating': rating,
      'reviewDate': reviewDate.toIso8601String(),
      'reviewText': reviewText,
    };
  }

  ReviewModel copyWith({
    int? id,
    String? productName,
    double? productPrice,
    String? productImage,
    int? rating,
    DateTime? reviewDate,
    String? reviewText,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
      rating: rating ?? this.rating,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewText: reviewText ?? this.reviewText,
    );
  }

  // Helper getters
  String get formattedPrice => '\$ ${productPrice.toStringAsFixed(2)}';

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
