import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';

/// Controller for Vendor Step 4: Location & Complete Onboarding
class VendorStep4Controller extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final ProfileSwitchService _profileSwitchService = Get.find<ProfileSwitchService>();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Loading state
  final isLoading = false.obs;

  // Form controllers
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final addressEnController = TextEditingController();
  final addressArController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final buildingController = TextEditingController();
  final floorController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onClose() {
    latitudeController.dispose();
    longitudeController.dispose();
    addressEnController.dispose();
    addressArController.dispose();
    cityController.dispose();
    areaController.dispose();
    buildingController.dispose();
    floorController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Pick location from map (placeholder for now)
  void pickLocation() {
    // TODO: Implement location picker
    ToastService.showInfo('Location picker coming soon');
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      print('📤 Completing onboarding...');

      final response = await _apiClient.post(
        '/merchant/onboarding/step4',
        data: {
          'location_latitude': double.tryParse(latitudeController.text) ?? 0.0,
          'location_longitude': double.tryParse(longitudeController.text) ?? 0.0,
          'location_address_en': addressEnController.text.trim(),
          'location_address_ar': addressArController.text.trim(),
          'location_city': cityController.text.trim(),
          'location_area': areaController.text.trim(),
          'location_building': buildingController.text.trim().isNotEmpty
              ? buildingController.text.trim()
              : null,
          'location_floor': floorController.text.trim().isNotEmpty
              ? floorController.text.trim()
              : null,
          'location_notes': notesController.text.trim().isNotEmpty
              ? notesController.text.trim()
              : null,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Onboarding completed successfully');

        ToastService.showSuccess('تم إكمال إعداد التاجر بنجاح!');

        // ✅ Refresh account status to reflect merchant_onboarding_completed = true
        print('🔄 Fetching updated account status...');
        final status = await _profileSwitchService.fetchAccountStatus();
        
        if (status != null) {
          print('📊 Account Status after onboarding:');
          print('  - merchantOnboardingCompleted: ${status.merchantOnboardingCompleted}');
          print('  - canSwitchToMerchant: ${status.canSwitchToMerchant}');
          print('  - hasMerchantProfile: ${status.hasMerchantProfile}');
          print('  - activeRole: ${status.activeRole}');
        } else {
          print('⚠️ Failed to fetch account status');
        }

        // ✅ Switch to merchant role automatically
        print('🔄 Attempting to switch to merchant role...');
        final switched = await _profileSwitchService.switchRole();

        if (switched) {
          print('✅ Successfully switched to merchant role');
          // Navigate to merchant home
          Get.offAllNamed('/merchant-home');
        } else {
          print('⚠️ Failed to switch to merchant role');
          // Fallback: just go to home and let user manually switch
          ToastService.showInfo('يمكنك الآن التبديل إلى حساب التاجر من الإعدادات');
          Get.offAllNamed('/home');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error completing onboarding: $e');
      ToastService.showError('حدث خطأ أثناء إكمال التسجيل');
    } finally {
      isLoading.value = false;
    }
  }

  /// Validators
  String? validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'latitude_required'.tr;
    }
    final lat = double.tryParse(value);
    if (lat == null || lat < -90 || lat > 90) {
      return 'invalid_latitude'.tr;
    }
    return null;
  }

  String? validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'longitude_required'.tr;
    }
    final lng = double.tryParse(value);
    if (lng == null || lng < -180 || lng > 180) {
      return 'invalid_longitude'.tr;
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }
}
