import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/models/user_profile_model.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  
  // Form validation
  final formKey = GlobalKey<FormState>();
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Country code
  final RxString countryCode = '+966'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void _loadCurrentProfile() {
    final profileController = Get.find<ProfileController>();
    final currentProfile = profileController.userProfile.value;
    
    fullNameController.text = currentProfile.fullName;
    emailController.text = currentProfile.email;
    phoneController.text = currentProfile.phoneNumber;
    countryCode.value = currentProfile.countryCode ?? '+966';
  }

  void changePhoto() {
    // TODO: Implement photo picker
    Get.snackbar(
      'Change Photo',
      'Photo picker functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveProfile() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      final profileController = Get.find<ProfileController>();
      final currentProfile = profileController.userProfile.value;
      
      final updatedProfile = currentProfile.copyWith(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        countryCode: countryCode.value,
      );
      
      profileController.updateProfile(updatedProfile);
      isLoading.value = false;
      
      Get.back();
    });
  }

  // Form validation methods
  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
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
