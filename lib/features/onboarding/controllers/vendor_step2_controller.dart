import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import '../../../core/services/toast_service.dart';

class VendorStep2Controller extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  // Form fields - Store Info
  final RxString storeNameEn = ''.obs;
  final RxString storeNameAr = ''.obs;

  // Form fields - Location
  final RxDouble latitude = 24.7136.obs; // Default: Riyadh
  final RxDouble longitude = 46.6753.obs;
  final RxString addressEn = ''.obs;
  final RxString addressAr = ''.obs;
  final RxString city = ''.obs;
  final RxString area = ''.obs;
  final RxBool locationFetched = false.obs;

  // Map controller
  GoogleMapController? mapController;
  final markers = <Marker>{}.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isGettingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎯 VendorStep2Controller initialized');
    _updateMarker();
  }

  /// Update map marker
  void _updateMarker() {
    markers.value = {
      Marker(
        markerId: const MarkerId('store_location'),
        position: LatLng(latitude.value, longitude.value),
        draggable: true,
        onDragEnd: (newPosition) {
          _onMapTap(newPosition);
        },
      ),
    };
  }

  /// Handle map tap to select location
  Future<void> _onMapTap(LatLng position) async {
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    locationFetched.value = true;
    _updateMarker();

    // Try to get address from coordinates
    await _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  /// Called when map is tapped
  void onMapTapped(LatLng position) {
    _onMapTap(position);
  }

  /// Get address from coordinates using reverse geocoding
  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Set city and area
        city.value = place.locality ?? place.administrativeArea ?? '';
        area.value = place.subLocality ?? place.subAdministrativeArea ?? '';
        
        // Build address string (user can edit later)
        String builtAddress = [
          place.street,
          place.subLocality,
          place.locality,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        
        if (addressEn.value.isEmpty) {
          addressEn.value = builtAddress;
        }
        
        print('📍 Reverse geocoded: $builtAddress');
      }
    } catch (e) {
      print('⚠️ Reverse geocoding failed: $e');
    }
  }

  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      isGettingLocation.value = true;

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ToastService.showError('location_permission_denied'.tr);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ToastService.showError('location_permission_denied_forever'.tr);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      locationFetched.value = true;
      
      _updateMarker();

      // Move camera to new position
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      ToastService.showSuccess('location_fetched_successfully'.tr);
      print('📍 Location: ${latitude.value}, ${longitude.value}');

    } catch (e) {
      print('❌ Error getting location: $e');
      ToastService.showError('error_getting_location'.tr);
    } finally {
      isGettingLocation.value = false;
    }
  }

  /// On map created
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// Validate form
  bool _validateForm() {
    if (storeNameEn.value.trim().isEmpty) {
      ToastService.showError(TranslationHelper.tr('enter_store_name_en'));
      return false;
    }

    if (storeNameAr.value.trim().isEmpty) {
      ToastService.showError(TranslationHelper.tr('enter_store_name_ar'));
      return false;
    }

    if (!locationFetched.value) {
      ToastService.showError('please_get_location'.tr);
      return false;
    }

    if (addressEn.value.trim().isEmpty) {
      ToastService.showError('enter_address_english'.tr);
      return false;
    }

    if (addressAr.value.trim().isEmpty) {
      ToastService.showError('enter_address_arabic'.tr);
      return false;
    }

    return true;
  }

  /// Submit business information with location
  Future<void> submitBusinessInfo() async {
    // Validate form first
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      print('📤 Submitting business info with location...');
      print('📋 Store Name (EN): ${storeNameEn.value}');
      print('📋 Store Name (AR): ${storeNameAr.value}');
      print('📍 Location: ${latitude.value}, ${longitude.value}');
      print('🏠 Address (EN): ${addressEn.value}');
      print('🏠 Address (AR): ${addressAr.value}');

      final payload = {
        'business_name_en': storeNameEn.value.trim(),
        'business_name_ar': storeNameAr.value.trim(),
        'business_type': 'restaurant',
        // Location data
        'location_latitude': latitude.value,
        'location_longitude': longitude.value,
        'location_address_en': addressEn.value.trim(),
        'location_address_ar': addressAr.value.trim(),
        'location_city': city.value.trim().isNotEmpty ? city.value.trim() : null,
        'location_area': area.value.trim().isNotEmpty ? area.value.trim() : null,
      };

      // Send request to backend
      final response = await _apiClient.post(
        '/merchant/onboarding/step2',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Business info submitted successfully');
        print('📥 Response: ${response.data}');

        // Check if response indicates completion
        final responseData = response.data;
        final isCompleted = responseData is Map &&
                           (responseData['message']?.toString().toLowerCase().contains('completed') == true ||
                            responseData['data']?['next_step'] == 'home');

        if (isCompleted) {
          print('✅ Onboarding marked as completed by server');

          // Show success message
          ToastService.showSuccess(TranslationHelper.tr('store_info_saved_redirecting'));

          // ✅ Refresh account status to reflect merchant_onboarding_completed = true
          try {
            final switchService = Get.find<ProfileSwitchService>();
            print('🔄 Refreshing account status...');
            await switchService.fetchAccountStatus();

            // ✅ Auto-switch to merchant role
            print('🔄 Switching to merchant role...');
            await switchService.switchRole();
            print('✅ Switched to merchant role successfully');
          } catch (e) {
            print('⚠️ Could not switch role automatically: $e');
          }

          // Wait a moment for user to see the success message
          await Future.delayed(const Duration(seconds: 1));

          // Navigate directly to merchant dashboard (onboarding complete!)
          print('🚀 Redirecting to merchant dashboard...');

          // IMPORTANT: Use offAllNamed to clear navigation stack
          // This prevents the middleware from redirecting back to Step 2
          Get.offAllNamed('/merchant-home');
        } else {
          print('⚠️ Server response does not indicate completion');
          ToastService.showWarning(TranslationHelper.tr('data_saved_may_require_more_steps'));
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error submitting business info: $e');
      
      String errorMessage = TranslationHelper.tr('error_saving_data');

      ToastService.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}
