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
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      image: json['image'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      productCode: json['productCode'],
      sizes: List<String>.from(json['sizes'] ?? ['S', 'M', 'L']),
      additionalOptions: (json['additionalOptions'] as List? ?? [])
          .map((option) => AdditionalOption.fromJson(option))
          .toList(),
      images: List<String>.from(json['images'] ?? [json['image']]),
      categoryId: json['categoryId'],
    );
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
    return AdditionalOption(
      id: json['id'],
      name: json['name'],
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
