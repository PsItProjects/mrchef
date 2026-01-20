import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/features/profile/models/user_profile_model.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';
import 'package:mrsheaf/features/merchant/pages/image_crop_screen.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import '../../../core/services/toast_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/auth_request.dart';

class EditProfileController extends GetxController {
  // Form controllers
  final fullNameController = TextEditingController();
  final arabicNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Form validation
  final formKey = GlobalKey<FormState>();

  // Loading state
  final RxBool isLoading = false.obs;

  // Country code
  final RxString countryCode = '+966'.obs;

  // Image picker
  final _imagePicker = ImagePicker();

  // Selected avatar
  final Rx<File?> selectedAvatar = Rx<File?>(null);

  // Current avatar URL from server
  final RxString currentAvatarUrl = ''.obs;

  // Services
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    arabicNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void _loadCurrentProfile() {
    // Load from AuthService current user
    final currentUser = _authService.currentUser.value;
    if (currentUser != null) {
      fullNameController.text = currentUser.nameEn ?? currentUser.displayName;
      arabicNameController.text = currentUser.nameAr ?? '';
      emailController.text = currentUser.email ?? '';
      phoneController.text = currentUser.phoneNumber;
      countryCode.value = currentUser.countryCode;

      // Load current avatar URL (use avatarUrl not avatar)
      currentAvatarUrl.value = currentUser.avatarUrl ?? '';

      print('📸 EDIT PROFILE: Loaded avatar URL: ${currentUser.avatarUrl}');
    } else {
      // Fallback to ProfileController if AuthService user is null
      final profileController = Get.find<ProfileController>();
      final currentProfile = profileController.userProfile.value;

      fullNameController.text = currentProfile.fullName;
      arabicNameController.text = '';
      emailController.text = currentProfile.email;
      phoneController.text = currentProfile.phoneNumber;
      countryCode.value = currentProfile.countryCode ?? '+966';
      currentAvatarUrl.value = currentProfile.avatar ?? '';
    }
  }

  /// Show avatar picker bottom sheet
  void changePhoto() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: Text(TranslationHelper.tr('camera')),
              onTap: () {
                Get.back();
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppColors.primaryColor),
              title: Text(TranslationHelper.tr('gallery')),
              onTap: () {
                Get.back();
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (currentAvatarUrl.value.isNotEmpty ||
                selectedAvatar.value != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(TranslationHelper.tr('remove_photo')),
                onTap: () {
                  Get.back();
                  _removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Pick avatar image with cropping
  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (image == null) return;

      // Read image bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // Navigate to crop screen
      final Uint8List? croppedImage = await Get.to<Uint8List>(
        () => ImageCropScreen(imageData: imageBytes),
        transition: Transition.cupertino,
      );

      if (croppedImage != null) {
        // Save cropped image to temp file
        final tempDir = Directory.systemTemp;
        final tempFile = File(
          '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tempFile.writeAsBytes(croppedImage);

        // Update selected avatar
        selectedAvatar.value = tempFile;
      }
    } catch (e) {
      ToastService.showError(TranslationHelper.tr('image_upload_failed'));
    }
  }

  /// Remove avatar
  Future<void> _removeAvatar() async {
    try {
      isLoading.value = true;

      // Call API to delete avatar
      final response = await _authService.deleteAvatar();

      if (response.isSuccess) {
        // Clear local state
        selectedAvatar.value = null;
        currentAvatarUrl.value = '';

        ToastService.showSuccess(TranslationHelper.tr('avatar_deleted_successfully'));
      } else {
        ToastService.showError(response.message);
      }
    } catch (e) {
      ToastService.showError(TranslationHelper.tr('avatar_delete_failed'));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Upload avatar if changed
      if (selectedAvatar.value != null) {
        final avatarResponse =
            await _authService.updateAvatar(selectedAvatar.value!);
        if (!avatarResponse.isSuccess) {
          ToastService.showError(avatarResponse.message);
          return;
        }

        // Update currentAvatarUrl after successful upload
        if (avatarResponse.data != null) {
          currentAvatarUrl.value = avatarResponse.data!.avatarUrl ?? '';
          selectedAvatar.value = null; // Clear selected avatar
          print('✅ Avatar uploaded successfully: ${currentAvatarUrl.value}');
        }
      }

      // Create update request with only the fields that can be updated
      // ✅ نرسل اللغة الحالية من التطبيق لضمان عدم تغييرها
      final currentLanguage = LanguageService.instance.currentLanguage;
      
      final request = CustomerProfileUpdateRequest(
        nameEn: fullNameController.text.trim(),
        nameAr: arabicNameController.text.trim().isNotEmpty
            ? arabicNameController.text.trim()
            : null,
        email: emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        preferredLanguage: currentLanguage, // ✅ إرسال اللغة الحالية
      );
      
      print('📤 EDIT PROFILE: Sending preferred_language: $currentLanguage');

      final response = await _authService.updateCustomerProfile(request);

      if (response.isSuccess) {
        ToastService.showSuccess('profile_updated_successfully'.tr);

        // Refresh ProfileController from API to get latest data
        final profileController = Get.find<ProfileController>();
        await profileController.refreshProfile();

        Get.back();
      } else {
        ToastService.showError(response.message);
      }
    } catch (e) {
      ToastService.showError('profile_update_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // Form validation methods
  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم بالإنجليزية مطلوب';
    }
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  String? validateArabicName(String? value) {
    // Arabic name is optional
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'الاسم بالعربية يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (value.trim().length < 8) {
      return 'الرجاء إدخال رقم هاتف صحيح';
    }
    return null;
  }
}
