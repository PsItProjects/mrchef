import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/edit_profile_controller.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';

class EditProfileAvatar extends GetView<EditProfileController> {
  const EditProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ProfileController exists before using it
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    final profileController = Get.find<ProfileController>();

    return Column(
      children: [
        // Avatar with edit badge
        GestureDetector(
          onTap: controller.changePhoto,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main avatar
              Obx(() {
                final selectedAvatar = controller.selectedAvatar.value;
                final currentAvatarUrl = controller.currentAvatarUrl.value;

                return Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.12),
                      image: selectedAvatar != null
                          ? DecorationImage(
                              image: FileImage(selectedAvatar),
                              fit: BoxFit.cover,
                            )
                          : currentAvatarUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(currentAvatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (selectedAvatar == null && currentAvatarUrl.isEmpty)
                        ? Center(
                            child: Text(
                              profileController.userProfile.value.initials,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 38,
                                color: Color(0xFF592E2C),
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              }),

              // Edit badge
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF592E2C),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Change photo text
        GestureDetector(
          onTap: controller.changePhoto,
          child: Text(
            'change_photo'.tr,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primaryColor.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );
  }
}
