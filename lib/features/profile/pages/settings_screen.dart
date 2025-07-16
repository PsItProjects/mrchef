import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/settings_controller.dart';
import 'package:mrsheaf/features/profile/widgets/settings_header.dart';
import 'package:mrsheaf/features/profile/widgets/settings_payment_card.dart';
import 'package:mrsheaf/features/profile/widgets/settings_menu_list.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const SettingsHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // Payment Method card
                    const SettingsPaymentCard(),
                    
                    const SizedBox(height: 16),
                    
                    // Settings menu
                    const SettingsMenuList(),
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
