import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Color(0xFF262626),
              ),
            ),
          ),
          
          // Title
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),
          
          // Placeholder for symmetry
          Container(
            width: 24,
            height: 24,
          ),
        ],
      ),
    );
  }
}
