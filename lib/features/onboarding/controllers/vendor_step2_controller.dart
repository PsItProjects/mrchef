import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart' as dio;
import '../../../core/network/api_client.dart';

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

  /// Pick PDF file
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
        allowedExtensions: ['pdf'],
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
      Get.snackbar('خطأ', 'يرجى إدخال اسم المتجر بالإنجليزية');
      return false;
    }

    if (storeNameAr.value.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم المتجر بالعربية');
      return false;
    }

    if (commercialRegistrationNumber.value.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال رقم السجل التجاري');
      return false;
    }

    if (workPermitFile.value == null) {
      Get.snackbar('خطأ', 'يرجى رفع ملف رخصة العمل');
      return false;
    }

    if (idOrPassportFile.value == null) {
      Get.snackbar('خطأ', 'يرجى رفع ملف الهوية أو جواز السفر');
      return false;
    }

    if (healthCertificateFile.value == null) {
      Get.snackbar('خطأ', 'يرجى رفع ملف الشهادة الصحية');
      return false;
    }

    return true;
  }

  /// Submit business information
  Future<void> submitBusinessInfo() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

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

      print('📤 Submitting business info...');
      print('📋 Data: ${formData.fields}');

      // Send request to backend
      final response = await _apiClient.post(
        '/merchant/onboarding/step2',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Business info submitted successfully');
        print('📥 Response: ${response.data}');

        Get.snackbar(
          'نجح',
          'تم حفظ معلومات المتجر بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to next step
        Get.toNamed('/vendor-step3');
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
}
