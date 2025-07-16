import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';
import 'package:mrsheaf/features/profile/widgets/profile_header.dart';
import 'package:mrsheaf/features/profile/widgets/profile_user_card.dart';
import 'package:mrsheaf/features/profile/widgets/profile_menu_list.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const ProfileHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // User profile card
                    const ProfileUserCard(),

                    const SizedBox(height: 16),

                    // Menu items
                    const ProfileMenuList(),
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
