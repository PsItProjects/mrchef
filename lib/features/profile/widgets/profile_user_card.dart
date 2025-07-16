import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class ProfileUserCard extends GetView<ProfileController> {
  const ProfileUserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return
      InkWell(
        onTap: controller.navigateToEditProfile,
        child:
        Container(
      // width: 380,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E3E3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User info section
          Row(
            children: [
              // Avatar
              Obx(() => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE3E3E3),
                ),
                child: controller.userProfile.value.avatar != null
                    ? ClipOval(
                        child: Image.asset(
                          controller.userProfile.value.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAvatarFallback();
                          },
                        ),
                      )
                    : _buildAvatarFallback(),
              )),
              
              const SizedBox(width: 8),
              
              // User details
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 208,
                    child: Text(
                      controller.userProfile.value.displayName,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF262626),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Container(
                    width: 140,
                    child: Text(
                      controller.userProfile.value.email,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
          
          // Edit button (arrow icon)
         Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF262626),
              ),
            ),

        ],
      ),
    ));
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE3E3E3),
      ),
      child: Center(
        child: Obx(() => Text(
          controller.userProfile.value.initials,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF262626),
          ),
        )),
      ),
    );
  }
}
