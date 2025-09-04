class CartItemModel {
  final int id;
  final int productId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String size;
  final int quantity;
  final List<CartAdditionalOption> additionalOptions;
  final double totalPrice;
  final String? specialInstructions;
  final DateTime? createdAt;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.size,
    required this.quantity,
    this.additionalOptions = const [],
    required this.totalPrice,
    this.specialInstructions,
    this.createdAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      productId: json['productId'] ?? json['product_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? json['primary_image'] ?? '',
      size: json['size'] ?? '',
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      specialInstructions: json['special_instructions'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      additionalOptions: (json['additionalOptions'] as List<dynamic>?)
          ?.map((option) => CartAdditionalOption.fromJson(option))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'size': size,
      'quantity': quantity,
      'total_price': totalPrice,
      'special_instructions': specialInstructions,
      'additionalOptions': additionalOptions.map((option) => option.toJson()).toList(),
    };
  }

  CartItemModel copyWith({
    int? id,
    int? productId,
    String? name,
    String? description,
    double? price,
    String? image,
    String? size,
    int? quantity,
    List<CartAdditionalOption>? additionalOptions,
    double? totalPrice,
    String? specialInstructions,
    DateTime? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      additionalOptions: additionalOptions ?? this.additionalOptions,
      totalPrice: totalPrice ?? this.totalPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculate local total price for this item including additional options
  // This is a fallback calculation when server total is not available
  double get calculatedTotalPrice {
    double basePrice = price * quantity;
    double optionsPrice = additionalOptions
        .where((option) => option.isSelected)
        .fold(0.0, (sum, option) => sum + (option.price * quantity));
    return basePrice + optionsPrice;
  }

  // Get display text for additional options
  String get additionalOptionsText {
    final selectedOptions = additionalOptions
        .where((option) => option.isSelected)
        .map((option) => option.name)
        .toList();
    
    if (selectedOptions.isEmpty) return '';
    return selectedOptions.join(', ');
  }
}

class CartAdditionalOption {
  final int id;
  final String name;
  final double price;
  final bool isSelected;

  CartAdditionalOption({
    required this.id,
    required this.name,
    required this.price,
    required this.isSelected,
  });

  factory CartAdditionalOption.fromJson(Map<String, dynamic> json) {
    return CartAdditionalOption(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'isSelected': isSelected,
    };
  }

  CartAdditionalOption copyWith({
    int? id,
    String? name,
    double? price,
    bool? isSelected,
  }) {
    return CartAdditionalOption(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
