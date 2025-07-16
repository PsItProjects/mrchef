class UserProfileModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatar;
  final String? countryCode;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatar,
    this.countryCode = '+966',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
      countryCode: json['countryCode'] ?? '+966',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'countryCode': countryCode,
    };
  }

  UserProfileModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatar,
    String? countryCode,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  // Helper getters
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  String get displayName => fullName;
  
  String get formattedPhone => '$countryCode $phoneNumber';
}
