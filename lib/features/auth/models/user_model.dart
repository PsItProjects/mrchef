class UserModel {
  final int id;
  final String? nameEn;
  final String? nameAr;
  final String? fullName;
  final String phoneNumber;
  final String countryCode;
  final String? email;
  final String status;
  final String userType; // 'customer' or 'merchant'
  final String? registrationStep;
  final String? preferredLanguage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    this.nameEn,
    this.nameAr,
    this.fullName,
    required this.phoneNumber,
    required this.countryCode,
    this.email,
    required this.status,
    required this.userType,
    this.registrationStep,
    this.preferredLanguage,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? json['name']?['en'],
      nameAr: json['name_ar'] ?? json['name']?['ar'],
      fullName: json['full_name'] ?? json['name'],
      phoneNumber: json['phone_number'] ?? '',
      countryCode: json['country_code'] ?? '+966',
      email: json['email'],
      status: json['status'] ?? 'pending',
      userType: json['user_type'] ?? 'customer',
      registrationStep: json['registration_step'],
      preferredLanguage: json['preferred_language'] ?? 'en',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'email': email,
      'status': status,
      'user_type': userType,
      'registration_step': registrationStep,
      'preferred_language': preferredLanguage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    if (nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return 'User';
  }

  String get fullPhoneNumber => '$countryCode$phoneNumber';

  bool get isCustomer => userType == 'customer';
  bool get isMerchant => userType == 'merchant';
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';

  UserModel copyWith({
    int? id,
    String? nameEn,
    String? nameAr,
    String? fullName,
    String? phoneNumber,
    String? countryCode,
    String? email,
    String? status,
    String? userType,
    String? registrationStep,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      email: email ?? this.email,
      status: status ?? this.status,
      userType: userType ?? this.userType,
      registrationStep: registrationStep ?? this.registrationStep,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
