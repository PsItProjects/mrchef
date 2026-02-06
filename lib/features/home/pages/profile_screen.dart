import 'package:flutter/material.dart';
import 'package:mrsheaf/features/profile/pages/unified_settings_screen.dart';

/// ProfileScreen now delegates to UnifiedSettingsScreen
/// Same screen for both customer and merchant roles
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedSettingsScreen();
  }
}
