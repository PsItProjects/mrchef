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
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      size: json['size'],
      quantity: json['quantity'],
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
    );
  }

  // Calculate total price for this item including additional options
  double get totalPrice {
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
