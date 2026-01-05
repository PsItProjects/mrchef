import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart' as dio;
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';

class VendorStep2Controller extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  // Form fields
  final RxString storeNameEn = ''.obs;
  final RxString storeNameAr = ''.obs;
  final RxString commercialRegistrationNumber = ''.obs;

  // File upload fields
  final Rx<File?> workPermitFile = Rx<File?>(null);
  final Rx<File?> idOrPassportFile = Rx<File?>(null);
  final Rx<File?> healthCertificateFile = Rx<File?>(null);

  // File names for display
  final RxString workPermitFileName = ''.obs;
  final RxString idOrPassportFileName = ''.obs;
  final RxString healthCertificateFileName = ''.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isUploadingWorkPermit = false.obs;
  final RxBool isUploadingIdOrPassport = false.obs;
  final RxBool isUploadingHealthCertificate = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎯 VendorStep2Controller initialized');
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied) {
          final manageStatus = await Permission.manageExternalStorage.request();
          return manageStatus.isGranted;
        }
        return status.isGranted;
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  /// Pick image file
  Future<void> pickFile(String fileType) async {
    try {
      // Request permission first
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        Get.snackbar(
          'خطأ',
          'يجب منح إذن الوصول للملفات لرفع المستندات',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Set loading state
      _setLoadingState(fileType, true);

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Check file size (max 5MB)
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          Get.snackbar(
            'خطأ',
            'حجم الملف يجب أن يكون أقل من 5 ميجابايت',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Store file based on type
        switch (fileType) {
          case 'work_permit':
            workPermitFile.value = file;
            workPermitFileName.value = fileName;
            break;
          case 'id_or_passport':
            idOrPassportFile.value = file;
            idOrPassportFileName.value = fileName;
            break;
          case 'health_certificate':
            healthCertificateFile.value = file;
            healthCertificateFileName.value = fileName;
            break;
        }

        Get.snackbar(
          'نجح',
          'تم اختيار الملف: $fileName',
          snackPosition: SnackPosition.BOTTOM,
        );

        print('✅ File picked: $fileName (${fileSizeInMB.toStringAsFixed(2)} MB)');
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء اختيار الملف',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _setLoadingState(fileType, false);
    }
  }

  /// Set loading state for specific file type
  void _setLoadingState(String fileType, bool loading) {
    switch (fileType) {
      case 'work_permit':
        isUploadingWorkPermit.value = loading;
        break;
      case 'id_or_passport':
        isUploadingIdOrPassport.value = loading;
        break;
      case 'health_certificate':
        isUploadingHealthCertificate.value = loading;
        break;
    }
  }

  /// Remove selected file
  void removeFile(String fileType) {
    switch (fileType) {
      case 'work_permit':
        workPermitFile.value = null;
        workPermitFileName.value = '';
        break;
      case 'id_or_passport':
        idOrPassportFile.value = null;
        idOrPassportFileName.value = '';
        break;
      case 'health_certificate':
        healthCertificateFile.value = null;
        healthCertificateFileName.value = '';
        break;
    }
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

    if (commercialRegistrationNumber.value.trim().isEmpty) {
      Get.snackbar(TranslationHelper.tr('error'), TranslationHelper.tr('enter_commercial_registration'));
      return false;
    }

    if (workPermitFile.value == null) {
      Get.snackbar(TranslationHelper.tr('error'), TranslationHelper.tr('upload_work_permit'));
      return false;
    }

    if (idOrPassportFile.value == null) {
      Get.snackbar(TranslationHelper.tr('error'), TranslationHelper.tr('upload_id_passport'));
      return false;
    }

    if (healthCertificateFile.value == null) {
      Get.snackbar(TranslationHelper.tr('error'), TranslationHelper.tr('upload_health_certificate'));
      return false;
    }

    return true;
  }

  /// Submit business information
  Future<void> submitBusinessInfo() async {
    // Validate form first
    if (!_validateForm()) return;

    // CRITICAL: Double-check files are selected before proceeding
    print('🔍 Checking files before submission...');
    print('   Work Permit: ${workPermitFile.value?.path ?? "NOT SELECTED"}');
    print('   ID/Passport: ${idOrPassportFile.value?.path ?? "NOT SELECTED"}');
    print('   Health Certificate: ${healthCertificateFile.value?.path ?? "NOT SELECTED"}');

    if (workPermitFile.value == null ||
        idOrPassportFile.value == null ||
        healthCertificateFile.value == null) {
      Get.snackbar(
        '⚠️ ملفات ناقصة',
        'يجب رفع جميع المستندات المطلوبة:\n• رخصة العمل\n• الهوية أو جواز السفر\n• الشهادة الصحية',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
      return; // STOP HERE - DO NOT PROCEED
    }

    try {
      isLoading.value = true;

      print('📤 Submitting business info...');
      print('📋 Store Name (EN): ${storeNameEn.value}');
      print('📋 Store Name (AR): ${storeNameAr.value}');
      print('📋 Commercial Reg: ${commercialRegistrationNumber.value}');

      // Create FormData for multipart request
      final formData = dio.FormData.fromMap({
        'business_name_en': storeNameEn.value.trim(),
        'business_name_ar': storeNameAr.value.trim(),
        'commercial_registration_number': commercialRegistrationNumber.value.trim(),
        'business_type': 'restaurant', // Add required business_type field
        'work_permit': await dio.MultipartFile.fromFile(
          workPermitFile.value!.path,
          filename: workPermitFileName.value,
        ),
        'id_or_passport': await dio.MultipartFile.fromFile(
          idOrPassportFile.value!.path,
          filename: idOrPassportFileName.value,
        ),
        'health_certificate': await dio.MultipartFile.fromFile(
          healthCertificateFile.value!.path,
          filename: healthCertificateFileName.value,
        ),
      });

      print('📋 Text Fields: ${formData.fields.length} fields');
      print('📋 Files: ${formData.files.length} files');
      for (var file in formData.files) {
        print('   ✅ ${file.key}: ${file.value.filename}');
      }

      // CRITICAL CHECK: Ensure we have exactly 3 files
      if (formData.files.length != 3) {
        throw Exception('Missing files! Expected 3 files, got ${formData.files.length}');
      }

      // Send request to backend
      final response = await _apiClient.post(
        '/merchant/onboarding/step2',
        data: formData,
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
      if (e is dio.DioException) {
        if (e.response?.data != null && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get file name for display
  String getFileName(String fileType) {
    switch (fileType) {
      case 'work_permit':
        return workPermitFileName.value;
      case 'id_or_passport':
        return idOrPassportFileName.value;
      case 'health_certificate':
        return healthCertificateFileName.value;
      default:
        return '';
    }
  }

  /// Check if file is selected
  bool isFileSelected(String fileType) {
    switch (fileType) {
      case 'work_permit':
        return workPermitFile.value != null;
      case 'id_or_passport':
        return idOrPassportFile.value != null;
      case 'health_certificate':
        return healthCertificateFile.value != null;
      default:
        return false;
    }
  }

  /// Get loading state for file type
  bool isFileLoading(String fileType) {
    switch (fileType) {
      case 'work_permit':
        return isUploadingWorkPermit.value;
      case 'id_or_passport':
        return isUploadingIdOrPassport.value;
      case 'health_certificate':
        return isUploadingHealthCertificate.value;
      default:
        return false;
    }
  }

  /// Get file type display text based on file extension
  String getFileTypeText(String fileType) {
    final fileName = getFileName(fileType);
    if (fileName.isEmpty) return '';
    
    final extension = fileName.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'pdf':
        return 'ملف PDF محدد';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'صورة محددة';
      default:
        return 'ملف محدد';
    }
  }
}
