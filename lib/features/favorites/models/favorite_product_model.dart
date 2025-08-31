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
      price: json['price'].toDouble(),
      availability: json['availability'] == 'available' 
          ? ProductAvailability.available 
          : ProductAvailability.outOfStock,
    );
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
