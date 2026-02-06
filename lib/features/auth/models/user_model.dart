import 'package:get/get.dart';
import 'package:mrsheaf/core/services/language_service.dart';

class UserModel {
  final int id;
  final String? nameEn;
  final String? nameAr;
  final String? fullName;
  final String phoneNumber;
  final String countryCode;
  final String? email;
  final String? avatar;
  final String? avatarUrl;
  final String status;
  final String userType; // 'customer' or 'merchant'
  final String? registrationStep;
  final String? preferredLanguage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Unified Account fields
  final String? activeRole;
  final bool hasMerchantProfile;
  final bool merchantOnboardingCompleted;
  final int? linkedMerchantId;
  final int? linkedCustomerId;

  UserModel({
    required this.id,
    this.nameEn,
    this.nameAr,
    this.fullName,
    required this.phoneNumber,
    required this.countryCode,
    this.email,
    this.avatar,
    this.avatarUrl,
    required this.status,
    required this.userType,
    this.registrationStep,
    this.preferredLanguage,
    this.createdAt,
    this.updatedAt,
    this.activeRole,
    this.hasMerchantProfile = false,
    this.merchantOnboardingCompleted = false,
    this.linkedMerchantId,
    this.linkedCustomerId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔍 USER MODEL: Parsing JSON...');
    print('   - id: ${json['id']}');
    print('   - name: ${json['name']}');
    print('   - email: ${json['email']}');
    print('   - avatar_url: ${json['avatar_url']}');

    return UserModel(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? json['name']?['en'],
      nameAr: json['name_ar'] ?? json['name']?['ar'],
      fullName:
          json['full_name'] ?? json['name']?['current'] ?? json['name']?['en'],
      phoneNumber: json['phone_number'] ?? '',
      countryCode: json['country_code'] ?? '+966',
      email: json['email'],
      avatar: json['avatar'],
      avatarUrl: json['avatar_url'],
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
      // Unified Account fields
      activeRole: json['active_role'],
      hasMerchantProfile: json['has_merchant_profile'] ?? false,
      merchantOnboardingCompleted: json['merchant_onboarding_completed'] ?? false,
      linkedMerchantId: json['linked_merchant_id'] ?? json['merchant_id'],
      linkedCustomerId: json['linked_customer_id'] ?? json['customer_id'],
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
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'status': status,
      'user_type': userType,
      'registration_step': registrationStep,
      'preferred_language': preferredLanguage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'active_role': activeRole,
      'has_merchant_profile': hasMerchantProfile,
      'merchant_onboarding_completed': merchantOnboardingCompleted,
      'linked_merchant_id': linkedMerchantId,
      'linked_customer_id': linkedCustomerId,
    };
  }

  String get displayName {
    // ✅ عرض الاسم حسب اللغة الحالية
    try {
      if (Get.isRegistered<LanguageService>()) {
        final currentLanguage = LanguageService.instance.currentLanguage;
        
        if (currentLanguage == 'ar') {
          // إذا كانت اللغة عربية، نعرض الاسم العربي أولاً
          if (nameAr != null && nameAr!.isNotEmpty) {
            return nameAr!;
          }
        } else {
          // إذا كانت اللغة إنجليزية، نعرض الاسم الإنجليزي أولاً
          if (nameEn != null && nameEn!.isNotEmpty) {
            return nameEn!;
          }
        }
      }
    } catch (e) {
      print('❌ Error getting display name: $e');
    }
    
    // Fallback: إذا لم تكن هناك خدمة لغة
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
    String? avatar,
    String? avatarUrl,
    String? status,
    String? userType,
    String? registrationStep,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? activeRole,
    bool? hasMerchantProfile,
    bool? merchantOnboardingCompleted,
    int? linkedMerchantId,
    int? linkedCustomerId,
  }) {
    return UserModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      userType: userType ?? this.userType,
      registrationStep: registrationStep ?? this.registrationStep,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeRole: activeRole ?? this.activeRole,
      hasMerchantProfile: hasMerchantProfile ?? this.hasMerchantProfile,
      merchantOnboardingCompleted: merchantOnboardingCompleted ?? this.merchantOnboardingCompleted,
      linkedMerchantId: linkedMerchantId ?? this.linkedMerchantId,
      linkedCustomerId: linkedCustomerId ?? this.linkedCustomerId,
    );
  }
}
