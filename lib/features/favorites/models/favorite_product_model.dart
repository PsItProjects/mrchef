enum ProductAvailability {
  available,
  outOfStock,
}

class FavoriteProductModel {
  final int id;
  final String name;
  final String image;
  final double price;
  final ProductAvailability availability;

  FavoriteProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.availability,
  });

  factory FavoriteProductModel.fromJson(Map<String, dynamic> json) {
    return FavoriteProductModel(
      id: json['id'],
      name: json['name'],
      image: json['primary_image'] ?? json['image'],
      price: _parsePrice(json['price']),
      availability: _parseAvailability(json['is_available'] ?? json['availability']),
    );
  }

  /// Parse price from different formats (String, int, double)
  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  /// Parse availability from different formats
  static ProductAvailability _parseAvailability(dynamic availability) {
    if (availability == null) return ProductAvailability.available;
    if (availability is bool) {
      return availability ? ProductAvailability.available : ProductAvailability.outOfStock;
    }
    if (availability is String) {
      return availability.toLowerCase() == 'available'
          ? ProductAvailability.available
          : ProductAvailability.outOfStock;
    }
    return ProductAvailability.available;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'availability': availability == ProductAvailability.available 
          ? 'available' 
          : 'outOfStock',
    };
  }

  FavoriteProductModel copyWith({
    int? id,
    String? name,
    String? image,
    double? price,
    ProductAvailability? availability,
  }) {
    return FavoriteProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      availability: availability ?? this.availability,
    );
  }

  // Helper getters
  bool get isAvailable => availability == ProductAvailability.available;

  String get availabilityText => isAvailable ? 'Available' : 'Out of stock';
}
