import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:dio/dio.dart' as dio;
import '../../../core/services/toast_service.dart';

class MerchantProfileService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get merchant profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      print('📊 Loading merchant profile...');
      
      final response = await _apiClient.get('/merchant/profile');
      
      if (response.statusCode == 200) {
        print('✅ Profile loaded successfully');
        return response.data['data'];
      }
      return null;
    } on dio.DioException catch (e) {
      print('❌ Error loading profile: ${e.message}');
      return null;
    }
  }

  /// Update preferred language
  Future<bool> updateLanguage(String languageCode) async {
    try {
      print('🌐 Updating preferred language to: $languageCode');

      final response = await _apiClient.put(
        '/merchant/profile/language',
        data: {'preferred_language': languageCode},
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Language updated successfully in backend');
        final newLanguage = response.data['data']?['preferred_language'];
        print('✅ New preferred_language from API: $newLanguage');
        return true;
      }
      print('❌ Language update failed with status: ${response.statusCode}');
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating language: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      return false;
    }
  }

  /// Update personal info (name, email)
  Future<bool> updatePersonalInfo({
    String? nameEn,
    String? nameAr,
    String? email,
  }) async {
    try {
      print('📝 Updating personal info...');

      final data = <String, dynamic>{};
      if (nameEn != null) data['name_en'] = nameEn;
      if (nameAr != null) data['name_ar'] = nameAr;
      if (email != null) data['email'] = email;

      final response = await _apiClient.put(
        '/merchant/profile/personal-info',
        data: data,
      );

      if (response.statusCode == 200) {
        print('✅ Personal info updated successfully');
        ToastService.showSuccess('تم تحديث المعلومات الشخصية بنجاح');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating personal info: ${e.message}');
      ToastService.showError('فشل تحديث المعلومات الشخصية');
      return false;
    }
  }

  /// Update restaurant info
  Future<bool> updateRestaurantInfo({
    String? businessNameEn,
    String? businessNameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? addressEn,
    String? addressAr,
    String? businessType,
    String? phone,
    String? email,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('📝 Updating restaurant info...');

      final data = <String, dynamic>{};
      if (businessNameEn != null) data['business_name_en'] = businessNameEn;
      if (businessNameAr != null) data['business_name_ar'] = businessNameAr;
      if (descriptionEn != null) data['description_en'] = descriptionEn;
      if (descriptionAr != null) data['description_ar'] = descriptionAr;
      if (addressEn != null) data['address_en'] = addressEn;
      if (addressAr != null) data['address_ar'] = addressAr;
      if (businessType != null) data['business_type'] = businessType;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (city != null) data['city'] = city;
      if (area != null) data['area'] = area;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final response = await _apiClient.put(
        '/merchant/profile/restaurant-info',
        data: data,
      );

      if (response.statusCode == 200) {
        print('✅ Restaurant info updated successfully');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating restaurant info: ${e.message}');
      return false;
    }
  }

  /// Upload restaurant logo
  Future<bool> uploadRestaurantLogo(File imageFile) async {
    try {
      print('📝 Uploading restaurant logo...');

      final formData = dio.FormData.fromMap({
        'logo': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: 'restaurant_logo.jpg',
        ),
      });

      final response = await _apiClient.post(
        '/merchant/profile/restaurant/logo',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('✅ Restaurant logo uploaded successfully');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error uploading restaurant logo: ${e.message}');
      return false;
    }
  }

  /// Delete restaurant logo
  Future<bool> deleteRestaurantLogo() async {
    try {
      print('📝 Deleting restaurant logo...');

      final response = await _apiClient.delete(
        '/merchant/profile/restaurant/logo',
      );

      if (response.statusCode == 200) {
        print('✅ Restaurant logo deleted successfully');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error deleting restaurant logo: ${e.message}');
      return false;
    }
  }

  /// Upload restaurant cover image
  Future<bool> uploadRestaurantCover(File imageFile) async {
    try {
      print('📝 Uploading restaurant cover...');

      final formData = dio.FormData.fromMap({
        'cover_image': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: 'restaurant_cover.jpg',
        ),
      });

      final response = await _apiClient.post(
        '/merchant/profile/restaurant/cover',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('✅ Restaurant cover uploaded successfully');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error uploading restaurant cover: ${e.message}');
      return false;
    }
  }

  /// Delete restaurant cover image
  Future<bool> deleteRestaurantCover() async {
    try {
      print('📝 Deleting restaurant cover...');

      final response = await _apiClient.delete(
        '/merchant/profile/restaurant/cover',
      );

      if (response.statusCode == 200) {
        print('✅ Restaurant cover deleted successfully');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error deleting restaurant cover: ${e.message}');
      return false;
    }
  }

  /// Update working hours
  Future<bool> updateWorkingHours(List<Map<String, dynamic>> businessHours) async {
    try {
      print('📝 Updating working hours...');
      print('   Data: $businessHours');
      
      final response = await _apiClient.put(
        '/merchant/profile/working-hours',
        data: {'business_hours': businessHours},
      );
      
      if (response.statusCode == 200) {
        print('✅ Working hours updated successfully');
        ToastService.showSuccess('تم تحديث ساعات العمل بنجاح');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating working hours: ${e.message}');
      ToastService.showError('فشل تحديث ساعات العمل');
      return false;
    }
  }

  /// Update location
  Future<bool> updateLocation({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? area,
    String? building,
    String? floor,
    String? notes,
  }) async {
    try {
      print('📝 Updating location...');
      
      final data = <String, dynamic>{};
      if (latitude != null) data['location_latitude'] = latitude;
      if (longitude != null) data['location_longitude'] = longitude;
      if (address != null) data['location_address'] = address;
      if (city != null) data['location_city'] = city;
      if (area != null) data['location_area'] = area;
      if (building != null) data['location_building'] = building;
      if (floor != null) data['location_floor'] = floor;
      if (notes != null) data['location_notes'] = notes;

      final response = await _apiClient.put(
        '/merchant/profile/location',
        data: data,
      );
      
      if (response.statusCode == 200) {
        print('✅ Location updated successfully');
        ToastService.showSuccess('تم تحديث العنوان بنجاح');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating location: ${e.message}');
      ToastService.showError('فشل تحديث العنوان');
      return false;
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? orderNotifications,
    bool? promotionNotifications,
  }) async {
    try {
      print('📝 Updating notification settings...');
      
      final data = <String, dynamic>{};
      if (emailNotifications != null) data['email_notifications'] = emailNotifications;
      if (pushNotifications != null) data['push_notifications'] = pushNotifications;
      if (smsNotifications != null) data['sms_notifications'] = smsNotifications;
      if (orderNotifications != null) data['order_notifications'] = orderNotifications;
      if (promotionNotifications != null) data['promotion_notifications'] = promotionNotifications;

      final response = await _apiClient.put(
        '/merchant/profile/notification-settings',
        data: data,
      );
      
      if (response.statusCode == 200) {
        print('✅ Notification settings updated successfully');
        ToastService.showSuccess('تم تحديث إعدادات الإشعارات بنجاح');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating notification settings: ${e.message}');
      ToastService.showError('فشل تحديث إعدادات الإشعارات');
      return false;
    }
  }

  /// Update avatar
  Future<bool> updateAvatar(File imageFile) async {
    try {
      print('📝 Updating avatar...');

      final formData = dio.FormData.fromMap({
        'avatar': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiClient.post(
        '/merchant/profile/avatar',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('✅ Avatar updated successfully');

        // Get message from API response
        final message = response.data['message'] ?? TranslationHelper.tr('image_upload_success');

        ToastService.showSuccess(message);

        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating avatar: ${e.message}');

      // Get error message from API response
      final errorMessage = e.response?.data['message'] ?? TranslationHelper.tr('image_upload_failed');

      ToastService.showError(errorMessage);
      return false;
    }
  }

  /// Delete avatar
  Future<bool> deleteAvatar() async {
    try {
      print('📝 Deleting avatar...');

      final response = await _apiClient.delete('/merchant/profile/avatar');

      if (response.statusCode == 200) {
        print('✅ Avatar deleted successfully');
        ToastService.showSuccess('تم حذف الصورة الشخصية بنجاح');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error deleting avatar: ${e.message}');
      ToastService.showError('فشل حذف الصورة الشخصية');
      return false;
    }
  }

  /// Update merchant cover
  Future<bool> updateMerchantCover(File imageFile) async {
    try {
      print('📝 Updating merchant cover...');

      final formData = dio.FormData.fromMap({
        'cover': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiClient.post(
        '/merchant/profile/cover',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('✅ Merchant cover updated successfully');

        final message = response.data['message'] ?? TranslationHelper.tr('image_upload_success');

        ToastService.showSuccess(message);

        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating merchant cover: ${e.message}');

      final errorMessage = e.response?.data['message'] ?? TranslationHelper.tr('image_upload_failed');

      ToastService.showError(errorMessage);
      return false;
    }
  }

  /// Delete merchant cover
  Future<bool> deleteMerchantCover() async {
    try {
      print('📝 Deleting merchant cover...');

      final response = await _apiClient.delete('/merchant/profile/cover');

      if (response.statusCode == 200) {
        print('✅ Merchant cover deleted successfully');
        ToastService.showSuccess(TranslationHelper.tr('cover_deleted_successfully'));
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error deleting merchant cover: ${e.message}');
      ToastService.showError(TranslationHelper.tr('cover_delete_failed'));
      return false;
    }
  }

  /// Update restaurant cover
  Future<bool> updateRestaurantCover(File imageFile) async {
    try {
      print('📝 Updating restaurant cover...');

      final formData = dio.FormData.fromMap({
        'cover_image': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiClient.post(
        '/merchant/profile/restaurant/cover',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('✅ Restaurant cover updated successfully');

        // Get message from API response
        final message = response.data['message'] ?? TranslationHelper.tr('image_upload_success');

        ToastService.showSuccess(message);

        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error updating restaurant cover: ${e.message}');

      // Get error message from API response
      final errorMessage = e.response?.data['message'] ?? TranslationHelper.tr('image_upload_failed');

      ToastService.showError(errorMessage);
      return false;
    }
  }
}

