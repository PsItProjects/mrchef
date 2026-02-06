import 'package:get/get.dart';

enum AddressType {
  home,
  work,
  other,
}

class AddressModel {
  final int? id;
  final AddressType type;
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final String notes;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    this.id,
    required this.type,
    this.label = '',
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    this.state = '',
    required this.country,
    this.postalCode = '',
    this.latitude,
    this.longitude,
    this.notes = '',
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      type: AddressType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AddressType.home,
      ),
      label: json['label'] ?? '',
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      notes: json['notes'] ?? '',
      isDefault: json['is_default'] is bool
          ? json['is_default']
          : (json['is_default'] == 1 || json['is_default'] == '1'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type.toString().split('.').last,
      'label': type == AddressType.other ? label : null,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'is_default': isDefault,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  AddressModel copyWith({
    int? id,
    AddressType? type,
    String? label,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? notes,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns localized display name for the address type
  String get typeDisplayName {
    switch (type) {
      case AddressType.home:
        return 'home_address'.tr;
      case AddressType.work:
        return 'work_address'.tr;
      case AddressType.other:
        return label.isNotEmpty ? label : 'other_address'.tr;
    }
  }

  /// Icon for the address type
  String get typeIcon {
    switch (type) {
      case AddressType.home:
        return '🏠';
      case AddressType.work:
        return '🏢';
      case AddressType.other:
        return '📍';
    }
  }

  String get fullAddress {
    List<String> parts = [addressLine1];

    if (addressLine2.isNotEmpty) {
      parts.add(addressLine2);
    }

    parts.add(city);

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
