class BannerModel {
  final int id;
  final String? image;
  final Map<String, String>? title;
  final Map<String, String>? description;
  final String type;
  final int displayOrder;
  final bool isActive;
  final String? startDate;
  final String? endDate;
  
  // Type-specific fields
  final String? externalUrl;
  final RestaurantData? restaurant;
  final ProductData? product;

  BannerModel({
    required this.id,
    this.image,
    this.title,
    this.description,
    required this.type,
    required this.displayOrder,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.externalUrl,
    this.restaurant,
    this.product,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      image: json['image'],
      title: json['title'] != null ? Map<String, String>.from(json['title']) : null,
      description: json['description'] != null ? Map<String, String>.from(json['description']) : null,
      type: json['type'] ?? 'image_only',
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      startDate: json['start_date'],
      endDate: json['end_date'],
      externalUrl: json['external_url'],
      restaurant: json['restaurant'] != null ? RestaurantData.fromJson(json['restaurant']) : null,
      product: json['product'] != null ? ProductData.fromJson(json['product']) : null,
    );
  }

  String? getTitle(String languageCode) {
    if (title == null) return null;
    return title![languageCode] ?? title!['en'] ?? title!['ar'];
  }

  String? getDescription(String languageCode) {
    if (description == null) return null;
    return description![languageCode] ?? description!['en'] ?? description!['ar'];
  }
}

class RestaurantData {
  final int id;
  final dynamic businessName;
  final String? logo;

  RestaurantData({
    required this.id,
    this.businessName,
    this.logo,
  });

  factory RestaurantData.fromJson(Map<String, dynamic> json) {
    return RestaurantData(
      id: json['id'],
      businessName: json['business_name'],
      logo: json['logo'],
    );
  }

  String getName(String languageCode) {
    if (businessName != null) {
      if (businessName is Map) {
        return businessName[languageCode] ?? businessName['en'] ?? businessName['ar'] ?? 'Restaurant';
      }
      return businessName.toString();
    }
    return 'Restaurant';
  }
}

class ProductData {
  final int id;
  final String name;
  final double price;
  final String? primaryImage;
  final int restaurantId;

  ProductData({
    required this.id,
    required this.name,
    required this.price,
    this.primaryImage,
    required this.restaurantId,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['id'],
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      primaryImage: json['primary_image'],
      restaurantId: json['restaurant_id'],
    );
  }
}

