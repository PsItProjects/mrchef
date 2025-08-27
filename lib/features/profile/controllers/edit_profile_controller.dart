import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/user_profile_model.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';
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
    } else {
      // Fallback to ProfileController if AuthService user is null
      final profileController = Get.find<ProfileController>();
      final currentProfile = profileController.userProfile.value;

      fullNameController.text = currentProfile.fullName;
      arabicNameController.text = '';
      emailController.text = currentProfile.email;
      phoneController.text = currentProfile.phoneNumber;
      countryCode.value = currentProfile.countryCode ?? '+966';
    }
  }

  void changePhoto() {
    // TODO: Implement photo picker
    Get.snackbar(
      'Change Photo',
      'Photo picker functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Create update request with only the fields that can be updated
      final request = CustomerProfileUpdateRequest(
        nameEn: fullNameController.text.trim(),
        nameAr: arabicNameController.text.trim().isNotEmpty
            ? arabicNameController.text.trim()
            : null,
        email: emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        preferredLanguage: 'en', // Default to English for now
      );

      final response = await _authService.updateCustomerProfile(request);

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.3),
        );

        // Update local ProfileController as well for UI consistency
        final profileController = Get.find<ProfileController>();
        final currentProfile = profileController.userProfile.value;

        final updatedProfile = currentProfile.copyWith(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          countryCode: countryCode.value,
        );

        profileController.updateProfile(updatedProfile);

        Get.back();
      } else {
        Get.snackbar(
          'Update Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Form validation methods
  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'English name is required';
    }
    if (value.trim().length < 2) {
      return 'English name must be at least 2 characters';
    }
    return null;
  }

  String? validateArabicName(String? value) {
    // Arabic name is optional
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'Arabic name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 8) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
