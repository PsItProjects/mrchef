class FavoriteStoreModel {
  final int id;
  final String name;
  final String image;
  final double rating;
  final String backgroundImage;

  FavoriteStoreModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.backgroundImage,
  });

  factory FavoriteStoreModel.fromJson(Map<String, dynamic> json) {
    return FavoriteStoreModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      rating: json['rating'].toDouble(),
      backgroundImage: json['backgroundImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'backgroundImage': backgroundImage,
    };
  }

  FavoriteStoreModel copyWith({
    int? id,
    String? name,
    String? image,
    double? rating,
    String? backgroundImage,
  }) {
    return FavoriteStoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }
}
