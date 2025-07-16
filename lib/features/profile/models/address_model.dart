enum AddressType {
  home,
  work,
  other,
}

class AddressModel {
  final int id;
  final AddressType type;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.type,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    this.state = '',
    required this.country,
    this.postalCode = '',
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      type: AddressType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AddressType.home,
      ),
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'],
      state: json['state'] ?? '',
      country: json['country'],
      postalCode: json['postalCode'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    int? id,
    AddressType? type,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      type: type ?? this.type,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Helper getters
  String get typeDisplayName {
    switch (type) {
      case AddressType.home:
        return 'HOME';
      case AddressType.work:
        return 'Work';
      case AddressType.other:
        return 'Other';
    }
  }

  String get fullAddress {
    List<String> parts = [addressLine1];
    
    if (addressLine2.isNotEmpty) {
      parts.add(addressLine2);
    }
    
    parts.add(city);
    
    if (postalCode.isNotEmpty) {
      parts.add(postalCode);
    }
    
    if (state.isNotEmpty) {
      parts.add(state);
    }
    
    parts.add(country);
    
    return parts.join(', ');
  }

  String get shortAddress {
    return '$addressLine1, $city, $country';
  }
}
