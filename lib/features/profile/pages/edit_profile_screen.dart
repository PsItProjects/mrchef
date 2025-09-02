import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/edit_profile_controller.dart';
import 'package:mrsheaf/features/profile/widgets/edit_profile_header.dart';
import 'package:mrsheaf/features/profile/widgets/edit_profile_avatar.dart';
import 'package:mrsheaf/features/profile/widgets/edit_profile_form.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const EditProfileHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    
                    // Avatar section
                    const EditProfileAvatar(),
                    
                    const SizedBox(height: 32),
                    
                    // Form
                    const EditProfileForm(),
                    
                    const SizedBox(height: 32),
                    
                    // Save button
                    Obx(() => Container(
                      width: 380,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isLoading.value
                              ? Colors.grey
                              : AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'save'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Color(0xFF592E2C),
                                  letterSpacing: -0.005,
                                ),
                              ),
                      ),
                    )),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
