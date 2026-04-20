import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/widgets/language_switcher.dart';
import 'package:mrsheaf/features/profile/widgets/unified_profile_card.dart';
import 'package:mrsheaf/features/profile/widgets/unified_menu_list.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_main_controller.dart';

/// شاشة الإعدادات الموحدة - نفس الشاشة للعميل والتاجر
/// تعرض بطاقة الملف الشخصي مع زر التبديل (مثل فيسبوك)
/// والقوائم تتكيف تلقائيًا حسب الدور الحالي
class UnifiedSettingsScreen extends StatelessWidget {
  const UnifiedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            _buildHeader(),
            // ─── Content ───
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Profile Card with Switch
                    const UnifiedProfileCard(),
                    const SizedBox(height: 20),
                    // Unified Menu (rebuilds when active role changes so a
                    // brand-new customer never momentarily sees merchant items)
                    Obx(() {
                      // Touch reactive sources so this Obx rebuilds whenever
                      // either the unified-account status or auth user-type
                      // changes.
                      if (Get.isRegistered<ProfileSwitchService>()) {
                        Get.find<ProfileSwitchService>().accountStatus.value;
                      }
                      Get.find<AuthService>().userType.value;
                      return const UnifiedMenuList();
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chat icon
          GestureDetector(
            onTap: () {
              if (_isMerchantMode()) {
                // Navigate to merchant messages tab (index 2)
                if (Get.isRegistered<MerchantMainController>()) {
                  Get.find<MerchantMainController>().changeTab(2);
                }
              } else {
                Get.toNamed('/conversations');
              }
            },
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 22,
              color: Color(0xFF262626),
            ),
          ),
          // Title
          Text(
            'settings'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF262626),
            ),
          ),
          // Language switcher
          const LanguageSwitcher(
            isCompact: true,
            showLabel: false,
          ),
        ],
      ),
    );
  }

  bool _isMerchantMode() {
    try {
      if (Get.isRegistered<ProfileSwitchService>()) {
        final ps = Get.find<ProfileSwitchService>();
        final status = ps.accountStatus.value;
        if (status != null) {
          return status.isMerchantMode;
        }
      }
      // Default to customer when status hasn't loaded yet — never silently
      // promote a brand-new customer to merchant mode.
      return false;
    } catch (e) {
      return false;
    }
  }
}
