import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';

class VendorStep2Controller extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  // Form fields
  final RxString storeNameEn = ''.obs;
  final RxString storeNameAr = ''.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎯 VendorStep2Controller initialized');
  }

  /// Validate form
  bool _validateForm() {
    if (storeNameEn.value.trim().isEmpty) {
      Get.snackbar(TranslationHelper.tr('error'), TranslationHelper.tr('enter_store_name_en'));
      return false;
    }

    if (storeNameAr.value.trim().isEmpty) {
      Get.snackbar(TranslationHelper.tr('error'), TranslationHelper.tr('enter_store_name_ar'));
      return false;
    }

    return true;
  }

  /// Submit business information
  Future<void> submitBusinessInfo() async {
    // Validate form first
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      print('📤 Submitting business info...');
      print('📋 Store Name (EN): ${storeNameEn.value}');
      print('📋 Store Name (AR): ${storeNameAr.value}');

      final payload = {
        'business_name_en': storeNameEn.value.trim(),
        'business_name_ar': storeNameAr.value.trim(),
        'business_type': 'restaurant', // Add required business_type field
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
          Get.snackbar(
            '🎉 تم إكمال التسجيل',
            'تم حفظ معلومات المتجر بنجاح! جاري تحويلك إلى لوحة التحكم...',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );

          // Wait a moment for user to see the success message
          await Future.delayed(const Duration(seconds: 2));

          // Navigate directly to merchant dashboard (onboarding complete!)
          print('🚀 Redirecting to merchant dashboard...');

          // IMPORTANT: Use offAllNamed to clear navigation stack
          // This prevents the middleware from redirecting back to Step 2
          Get.offAllNamed('/merchant-home');
        } else {
          print('⚠️ Server response does not indicate completion');
          Get.snackbar(
            'تنبيه',
            'تم حفظ البيانات لكن قد تحتاج لإكمال خطوات إضافية',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error submitting business info: $e');
      
      String errorMessage = 'حدث خطأ أثناء حفظ البيانات';
      // ApiClient wraps Dio; response parsing happens there.

      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
