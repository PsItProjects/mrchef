import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class MerchantSettingsService extends GetxService {
  static MerchantSettingsService get instance => Get.find<MerchantSettingsService>();
  
  final ApiClient _apiClient = ApiClient.instance;
  
  // Observable settings
  final Rx<MerchantProfile> merchantProfile = MerchantProfile().obs;
  final Rx<RestaurantInfo> restaurantInfo = RestaurantInfo().obs;
  final Rx<NotificationSettings> notificationSettings = NotificationSettings().obs;
  final RxList<Map<String, dynamic>> businessTypes = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await loadMerchantProfile();
    await loadBusinessTypes();
  }
  
  /// Load merchant profile from backend
  Future<void> loadMerchantProfile() async {
    try {
      isLoading.value = true;
      print('📊 === LOADING MERCHANT PROFILE ===');

      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/merchant/profile',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print('✅ Profile API response received');
        print('📦 Response structure: ${data.keys.toList()}');
        print('📦 Has "merchant" key: ${data.containsKey('merchant')}');

        // Update merchant profile
        final merchantData = data['merchant'] ?? data; // Support both structures
        print('📦 merchantData keys: ${merchantData.keys.toList()}');
        print('📦 merchantData has "restaurant": ${merchantData.containsKey('restaurant')}');

        merchantProfile.value = MerchantProfile.fromJson(merchantData);
        print('✅ Merchant profile parsed');

        // Update restaurant info if available
        // Check both data['merchant']['restaurant'] and data['restaurant']
        final restaurantData = merchantData['restaurant'] as Map<String, dynamic>?;

        if (restaurantData != null) {
          // Debug: Check if business_hours exists in API response
          print('🏪 === RESTAURANT DATA DEBUG ===');
          print('   All keys: ${restaurantData.keys.toList()}');
          print('   Has business_hours key: ${restaurantData.containsKey('business_hours')}');

          if (restaurantData.containsKey('business_hours')) {
            final businessHoursRaw = restaurantData['business_hours'];
            print('   business_hours type: ${businessHoursRaw.runtimeType}');
            print('   business_hours value: $businessHoursRaw');

            if (businessHoursRaw is Map) {
              print('   business_hours is Map with ${businessHoursRaw.length} entries');
              print('   Days in business_hours: ${businessHoursRaw.keys.toList()}');
            } else if (businessHoursRaw == null) {
              print('   ⚠️ business_hours is NULL');
            } else {
              print('   ⚠️ business_hours is unexpected type');
            }
          } else {
            print('   ❌ business_hours key NOT FOUND in API response');
          }

          // Parse restaurant info
          print('🔄 Parsing RestaurantInfo...');
          restaurantInfo.value = RestaurantInfo.fromJson(restaurantData);

          // Debug: Check parsed result
          print('🏪 === AFTER PARSING ===');
          print('   restaurantInfo.value is null: ${restaurantInfo.value == null}');
          if (restaurantInfo.value != null) {
            print('   restaurantInfo.businessHours is null: ${restaurantInfo.value.businessHours == null}');
            if (restaurantInfo.value.businessHours != null) {
              print('   businessHours has ${restaurantInfo.value.businessHours!.length} days');
              restaurantInfo.value.businessHours!.forEach((day, workingDay) {
                print('   - $day: ${workingDay.isOpen ? "OPEN ${workingDay.openTime}-${workingDay.closeTime}" : "CLOSED"}');
              });
            }
          }
          print('🏪 === END DEBUG ===');
        } else {
          print('⚠️ No restaurant data in API response');
        }

        // Update notification settings
        final settings = merchantData['settings'] as Map<String, dynamic>?;
        if (settings != null && settings['notifications'] != null) {
          notificationSettings.value = NotificationSettings.fromJson(
            settings['notifications'] as Map<String, dynamic>
          );
        }

        print('✅ MERCHANT: Profile loaded successfully');
      }
    } on DioException catch (e) {
      print('❌ MERCHANT: Error loading profile: $e');
      print('❌ MERCHANT: Status code: ${e.response?.statusCode}');
      print('❌ MERCHANT: Response data: ${e.response?.data}');

      // Check if it's onboarding issue
      if (e.response?.statusCode == 403) {
        final responseData = e.response?.data;
        if (responseData != null && responseData.toString().contains('onboarding')) {
          print('🔄 MERCHANT: Onboarding required, redirecting...');
          _handleOnboardingRequired(e);
          return;
        }
      }

      _showErrorSnackbar('Failed to load profile');
    } catch (e) {
      print('❌ MERCHANT: Unexpected error: $e');
      _showErrorSnackbar('Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load business types from backend
  Future<void> loadBusinessTypes() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/merchant/business-types',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final types = data['business_types'] as List<dynamic>;
        businessTypes.value = types.cast<Map<String, dynamic>>();

        print('✅ MERCHANT: Business types loaded successfully');
      }
    } catch (e) {
      print('❌ MERCHANT: Error loading business types: $e');

      // Fallback to hardcoded business types if API fails
      print('🔄 MERCHANT: Using fallback business types');
      businessTypes.value = [
        {'value': 'restaurant', 'label_ar': 'مطعم', 'label_en': 'Restaurant'},
        {'value': 'cafe', 'label_ar': 'مقهى', 'label_en': 'Cafe'},
        {'value': 'bakery', 'label_ar': 'مخبز', 'label_en': 'Bakery'},
        {'value': 'fastfood', 'label_ar': 'وجبات سريعة', 'label_en': 'Fast Food'},
        {'value': 'pizza', 'label_ar': 'بيتزا', 'label_en': 'Pizza'},
        {'value': 'seafood', 'label_ar': 'مأكولات بحرية', 'label_en': 'Seafood'},
        {'value': 'dessert', 'label_ar': 'حلويات', 'label_en': 'Dessert'},
        {'value': 'juice', 'label_ar': 'عصائر', 'label_en': 'Juice'},
        {'value': 'grocery', 'label_ar': 'بقالة', 'label_en': 'Grocery'},
        {'value': 'pharmacy', 'label_ar': 'صيدلية', 'label_en': 'Pharmacy'},
      ];
    }
  }

  /// Update merchant basic profile
  Future<bool> updateMerchantProfile({
    String? nameEn,
    String? nameAr,
    String? email,
    String? preferredLanguage,
  }) async {
    try {
      isLoading.value = true;
      
      final data = <String, dynamic>{};
      if (nameEn != null) data['name_en'] = nameEn;
      if (nameAr != null) data['name_ar'] = nameAr;
      if (email != null) data['email'] = email;
      if (preferredLanguage != null) data['preferred_language'] = preferredLanguage;
      
      final response = await _apiClient.put(
        '${ApiConstants.baseUrl}/merchant/profile',
        data: data,
      );
      
      if (response.statusCode == 200) {
        await loadMerchantProfile(); // Reload to get updated data
        _showSuccessSnackbar('Profile updated successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ MERCHANT: Error updating profile: $e');
      _showErrorSnackbar('Failed to update profile');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update restaurant information
  Future<bool> updateRestaurantInfo({
    String? nameEn,
    String? nameAr,
    String? businessNameEn,
    String? businessNameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? businessType,
    String? phone,
    String? email,
    String? city,
    String? area,
    double? deliveryFee,
    double? minimumOrder,
    int? deliveryRadius,
    int? preparationTime,
  }) async {
    try {
      isLoading.value = true;
      
      final data = <String, dynamic>{};
      if (nameEn != null) data['name_en'] = nameEn;
      if (nameAr != null) data['name_ar'] = nameAr;
      if (businessNameEn != null) data['business_name_en'] = businessNameEn;
      if (businessNameAr != null) data['business_name_ar'] = businessNameAr;
      if (descriptionEn != null) data['description_en'] = descriptionEn;
      if (descriptionAr != null) data['description_ar'] = descriptionAr;
      if (businessType != null) data['business_type'] = businessType;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (city != null) data['city'] = city;
      if (area != null) data['area'] = area;
      if (deliveryFee != null) data['delivery_fee'] = deliveryFee;
      if (minimumOrder != null) data['minimum_order'] = minimumOrder;
      if (deliveryRadius != null) data['delivery_radius'] = deliveryRadius;
      if (preparationTime != null) data['preparation_time'] = preparationTime;
      
      final response = await _apiClient.put(
        '${ApiConstants.baseUrl}/merchant/profile/restaurant-info',
        data: data,
      );
      
      if (response.statusCode == 200) {
        await loadMerchantProfile(); // Reload to get updated data
        _showSuccessSnackbar('Restaurant info updated successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ MERCHANT: Error updating restaurant info: $e');
      _showErrorSnackbar('Failed to update restaurant info');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update working hours
  Future<bool> updateWorkingHours(Map<String, WorkingDay> workingHours) async {
    try {
      isLoading.value = true;
      
      // Convert working hours to backend format
      final businessHours = <String, dynamic>{};
      workingHours.forEach((day, workingDay) {
        if (workingDay.isOpen) {
          businessHours[day.toLowerCase()] = {
            'open': workingDay.openTime,
            'close': workingDay.closeTime,
          };
        }
      });
      
      final response = await _apiClient.put(
        '${ApiConstants.baseUrl}/merchant/profile/restaurant-info',
        data: {
          'business_hours': businessHours,
        },
      );
      
      if (response.statusCode == 200) {
        await loadMerchantProfile(); // Reload to get updated data
        _showSuccessSnackbar('Working hours updated successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ MERCHANT: Error updating working hours: $e');
      _showErrorSnackbar('Failed to update working hours');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update notification settings
  Future<bool> updateNotificationSettings({
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? orderNotifications,
    bool? marketingNotifications,
  }) async {
    try {
      isLoading.value = true;
      
      final data = <String, dynamic>{};
      if (emailNotifications != null) data['email_notifications'] = emailNotifications;
      if (smsNotifications != null) data['sms_notifications'] = smsNotifications;
      if (pushNotifications != null) data['push_notifications'] = pushNotifications;
      if (orderNotifications != null) data['order_notifications'] = orderNotifications;
      if (marketingNotifications != null) data['marketing_notifications'] = marketingNotifications;
      
      final response = await _apiClient.put(
        '${ApiConstants.baseUrl}/merchant/profile/notification-settings',
        data: data,
      );
      
      if (response.statusCode == 200) {
        await loadMerchantProfile(); // Reload to get updated data
        _showSuccessSnackbar('Notification settings updated successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ MERCHANT: Error updating notification settings: $e');
      _showErrorSnackbar('Failed to update notification settings');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Handle onboarding required - redirect to appropriate step
  void _handleOnboardingRequired(DioException error) {
    print('🔄 MERCHANT: _handleOnboardingRequired called!');
    print('🔍 MERCHANT: Error type: ${error.runtimeType}');

    try {
      // Parse the error response to get onboarding info
      String currentStep = 'subscription_selection'; // default
      String redirectRoute = '/vendor-step1'; // default

      // Try to extract actual data from DioException
      if (error.response != null && error.response?.data != null) {
        final responseData = error.response?.data;
        print('🔍 MERCHANT: Full response data: $responseData');

        if (responseData is Map<String, dynamic> && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          print('🔍 MERCHANT: Extracted data: $data');

          // Get current step from API response
          if (data['current_step'] != null) {
            currentStep = data['current_step'].toString();
            print('🔍 MERCHANT: Found current_step: $currentStep');
          }

          // Get next action info
          if (data['next_action'] != null) {
            final nextAction = data['next_action'] as Map<String, dynamic>;
            final step = nextAction['step'];

            print('🔍 MERCHANT: Current step: $currentStep');
            print('🔍 MERCHANT: Next action step: $step');

            // Map current step to route based on what's missing
            // Only 2 steps for merchants:
            // Step 1: subscription_selection → /vendor-step1
            // Step 2: business_information → /vendor-step2
            if (currentStep == 'subscription_selection') {
              redirectRoute = '/vendor-step1';
            } else if (currentStep == 'business_information') {
              redirectRoute = '/vendor-step2';
            } else {
              // Fallback: use step number from next_action
              switch (step) {
                case 1:
                  redirectRoute = '/vendor-step1';
                  break;
                case 2:
                  redirectRoute = '/vendor-step2';
                  break;
                default:
                  redirectRoute = '/vendor-step1';
              }
            }
          }
        } else {
          print('❌ MERCHANT: responseData is not Map or data is null');
        }
      } else {
        print('❌ MERCHANT: error.response or error.response.data is null');
      }

      print('🔄 MERCHANT: Final decision - Redirecting to: $redirectRoute');

      // Show informative message
      Get.snackbar(
        'إكمال التسجيل',
        'يجب إكمال عملية التسجيل أولاً',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to appropriate onboarding step immediately
      print('🚀 MERCHANT: Executing navigation to $redirectRoute');
      Get.offAllNamed(redirectRoute);

    } catch (e) {
      print('❌ MERCHANT: Error parsing onboarding info: $e');
      print('❌ MERCHANT: Stack trace: ${e.toString()}');

      // Fallback to step 1
      print('🔄 MERCHANT: Fallback navigation to /vendor-step1');
      Get.offAllNamed('/vendor-step1');
    }
  }
}

// Data models
class MerchantProfile {
  final String? nameEn;
  final String? nameAr;
  final String? email;
  final String? phoneNumber;
  final String? preferredLanguage;
  final String? status;
  
  MerchantProfile({
    this.nameEn,
    this.nameAr,
    this.email,
    this.phoneNumber,
    this.preferredLanguage,
    this.status,
  });
  
  factory MerchantProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>?;
    return MerchantProfile(
      nameEn: name?['en'],
      nameAr: name?['ar'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      preferredLanguage: json['preferred_language'],
      status: json['status'],
    );
  }
}

class RestaurantInfo {
  final String? nameEn;
  final String? nameAr;
  final String? businessNameEn;
  final String? businessNameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? businessType;
  final String? phone;
  final String? email;
  final String? city;
  final String? area;
  final double? deliveryFee;
  final double? minimumOrder;
  final int? deliveryRadius;
  final int? preparationTime;
  final Map<String, WorkingDay>? businessHours;
  
  RestaurantInfo({
    this.nameEn,
    this.nameAr,
    this.businessNameEn,
    this.businessNameAr,
    this.descriptionEn,
    this.descriptionAr,
    this.businessType,
    this.phone,
    this.email,
    this.city,
    this.area,
    this.deliveryFee,
    this.minimumOrder,
    this.deliveryRadius,
    this.preparationTime,
    this.businessHours,
  });
  
  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    // Handle both direct string values and JSON objects for names
    String? nameEn, nameAr, businessNameEn, businessNameAr, descriptionEn, descriptionAr;

    // Parse name field
    if (json['name'] is String) {
      nameAr = json['name']; // Default to Arabic if single string
    } else if (json['name'] is Map<String, dynamic>) {
      final name = json['name'] as Map<String, dynamic>;
      nameEn = name['en'];
      nameAr = name['ar'];
    }

    // Parse business_name field
    if (json['business_name'] is String) {
      businessNameAr = json['business_name']; // Default to Arabic if single string
    } else if (json['business_name'] is Map<String, dynamic>) {
      final businessName = json['business_name'] as Map<String, dynamic>;
      businessNameEn = businessName['en'];
      businessNameAr = businessName['ar'];
    }

    // Parse description field
    if (json['description'] is String) {
      descriptionAr = json['description']; // Default to Arabic if single string
    } else if (json['description'] is Map<String, dynamic>) {
      final description = json['description'] as Map<String, dynamic>;
      descriptionEn = description['en'];
      descriptionAr = description['ar'];
    }

    // Parse business hours
    Map<String, WorkingDay>? businessHours;
    print('📅 === PARSING BUSINESS HOURS ===');
    print('   json has business_hours key: ${json.containsKey('business_hours')}');

    final hoursJson = json['business_hours'];
    print('   business_hours raw value: $hoursJson');
    print('   business_hours type: ${hoursJson.runtimeType}');

    if (hoursJson != null && hoursJson is Map) {
      businessHours = {};
      final hoursMap = hoursJson as Map<String, dynamic>;
      print('   business_hours is Map with ${hoursMap.length} entries');

      final days = ['saturday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
      for (final day in days) {
        final dayData = hoursMap[day];
        if (dayData != null && dayData is Map) {
          final dayMap = dayData as Map<String, dynamic>;
          businessHours[day] = WorkingDay(
            isOpen: true,
            openTime: dayMap['open'] ?? '09:00',
            closeTime: dayMap['close'] ?? '22:00',
          );
          print('   ✅ $day: OPEN (${dayMap['open']} - ${dayMap['close']})');
        } else {
          businessHours[day] = WorkingDay(isOpen: false);
          print('   ❌ $day: CLOSED (not in API response)');
        }
      }
      print('   Final businessHours map has ${businessHours.length} days');
    } else {
      print('   ⚠️ business_hours is null or not a Map');
    }
    print('📅 === END PARSING ===');

    return RestaurantInfo(
      nameEn: nameEn,
      nameAr: nameAr,
      businessNameEn: businessNameEn,
      businessNameAr: businessNameAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      businessType: json['type'] ?? json['business_type'], // Handle both 'type' and 'business_type'
      phone: json['phone'],
      email: json['email'],
      city: json['city'],
      area: json['area'],
      deliveryFee: json['delivery_fee']?.toDouble(),
      minimumOrder: json['minimum_order']?.toDouble(),
      deliveryRadius: json['delivery_radius'],
      preparationTime: json['preparation_time'],
      businessHours: businessHours,
    );
  }
}

class NotificationSettings {
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool orderNotifications;
  final bool marketingNotifications;
  
  NotificationSettings({
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.pushNotifications = true,
    this.orderNotifications = true,
    this.marketingNotifications = false,
  });
  
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailNotifications: json['email_notifications'] ?? true,
      smsNotifications: json['sms_notifications'] ?? true,
      pushNotifications: json['push_notifications'] ?? true,
      orderNotifications: json['order_notifications'] ?? true,
      marketingNotifications: json['marketing_notifications'] ?? false,
    );
  }
}

class WorkingDay {
  final bool isOpen;
  final String openTime;
  final String closeTime;
  
  WorkingDay({
    this.isOpen = false,
    this.openTime = '09:00',
    this.closeTime = '22:00',
  });
}
