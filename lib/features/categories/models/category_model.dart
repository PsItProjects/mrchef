class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final int itemCount;
  final bool isSelected;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.itemCount,
    this.isSelected = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      itemCount: json['itemCount'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'itemCount': itemCount,
      'isSelected': isSelected,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    int? itemCount,
    bool? isSelected,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      itemCount: itemCount ?? this.itemCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class KitchenModel {
  final int id;
  final String name;
  final String image;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> specialties;

  KitchenModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.specialties,
  });

  factory KitchenModel.fromJson(Map<String, dynamic> json) {
    return KitchenModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      description: json['description'],
      specialties: List<String>.from(json['specialties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'specialties': specialties,
    };
  }
}

class FilterModel {
  final String title;
  final List<FilterOption> options;
  final bool isExpanded;

  FilterModel({
    required this.title,
    required this.options,
    this.isExpanded = false,
  });

  FilterModel copyWith({
    String? title,
    List<FilterOption>? options,
    bool? isExpanded,
  }) {
    return FilterModel(
      title: title ?? this.title,
      options: options ?? this.options,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class FilterOption {
  final int id;
  final String name;
  final int count;
  final bool isSelected;
  final double? rating;

  FilterOption({
    required this.id,
    required this.name,
    required this.count,
    this.isSelected = false,
    this.rating,
  });

  FilterOption copyWith({
    int? id,
    String? name,
    int? count,
    bool? isSelected,
    double? rating,
  }) {
    return FilterOption(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      isSelected: isSelected ?? this.isSelected,
      rating: rating ?? this.rating,
    );
  }
}
