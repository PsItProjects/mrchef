import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/edit_profile_controller.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';

class EditProfileAvatar extends GetView<EditProfileController> {
  const EditProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    
    return Column(
      children: [
        // Avatar with camera overlay
        Stack(
          children: [
            // Main avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFCE3EA),
              ),
              child: Center(
                child: Obx(() => Text(
                  profileController.userProfile.value.initials,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    color: Color(0xFFEA0A2B),
                    letterSpacing: -0.01,
                  ),
                )),
              ),
            ),
            
            // Camera overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: controller.changePhoto,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Change photo text
        GestureDetector(
          onTap: controller.changePhoto,
          child: const Text(
            'Change photo',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF1C1C1C),
            ),
          ),
        ),
      ],
    );
  }
}
