import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

/// بطاقة تبديل الملف الشخصي - مثل فيسبوك
/// تظهر فوق قائمة الملف الشخصي لتبديل بين عميل/تاجر
class ProfileSwitchCard extends StatelessWidget {
  const ProfileSwitchCard({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      if (!Get.isRegistered<ProfileSwitchService>()) {
        return const SizedBox.shrink();
      }

      final switchService = Get.find<ProfileSwitchService>();
      final isArabic = Get.find<LanguageService>().currentLanguage == 'ar';

      return Obx(() {
        final status = switchService.accountStatus.value;
        final isSwitching = switchService.isSwitching.value;
        final isLoading = switchService.isLoadingStatus.value;

        // إذا لم يتم تحميل الحالة بعد، نحاول تحميلها
        if (status == null) {
          if (!isLoading) {
            switchService.fetchAccountStatus();
          }
          return const SizedBox.shrink();
        }

        // ─── Case 1: يمكنه التبديل للتاجر (عنده ملف تاجر مكتمل) ───
        if (status.canSwitchToMerchant && status.isCustomerMode) {
          return _buildSwitchCard(
            icon: Icons.store_rounded,
            title: 'switch_to_merchant'.tr,
            subtitle: 'switch_to_merchant_desc'.tr,
            gradientColors: [const Color(0xFF6C63FF), const Color(0xFF4834DF)],
            iconBgColor: const Color(0xFF8B83FF),
            isLoading: isSwitching,
            isArabic: isArabic,
            onTap: () => _handleSwitchToMerchant(switchService),
          );
        }

        // ─── Case 2: يمكنه تفعيل حساب تاجر (لا يملك ملف تاجر) ───
        if (status.canActivateMerchant && status.isCustomerMode) {
          return _buildSwitchCard(
            icon: Icons.rocket_launch_rounded,
            title: 'become_merchant'.tr,
            subtitle: 'become_merchant_desc'.tr,
            gradientColors: [const Color(0xFFFF8008), const Color(0xFFFFC837)],
            iconBgColor: const Color(0xFFFFAA4C),
            isLoading: isSwitching,
            isArabic: isArabic,
            onTap: () => _handleBecomeMerchant(switchService),
          );
        }

        // ─── Case 3: عنده ملف تاجر لكن الإعداد غير مكتمل ───
        if (status.hasMerchantProfile &&
            !status.merchantOnboardingCompleted &&
            status.isCustomerMode) {
          return _buildSwitchCard(
            icon: Icons.settings_suggest_rounded,
            title: 'complete_merchant_setup'.tr,
            subtitle: 'complete_merchant_setup_desc'.tr,
            gradientColors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
            iconBgColor: const Color(0xFF3DD68C),
            isLoading: isSwitching,
            isArabic: isArabic,
            onTap: () => _handleSwitchToMerchant(switchService),
          );
        }

        return const SizedBox.shrink();
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color iconBgColor,
    required bool isLoading,
    required bool isArabic,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // أيقونة
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                // نص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: isArabic ? null : 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: isArabic ? null : 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                // سهم
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isArabic
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _handleSwitchToMerchant(
      ProfileSwitchService switchService) async {
    final success = await switchService.switchRole();
    if (success) {
      ToastService.showSuccess('switched_to_merchant'.tr);
      Get.offAllNamed('/merchant-home');
    } else {
      ToastService.showError('switch_failed'.tr);
    }
  }

  Future<void> _handleBecomeMerchant(
      ProfileSwitchService switchService) async {
    final success = await switchService.activateMerchant();
    if (success) {
      final switched = await switchService.switchRole();
      if (switched) {
        ToastService.showSuccess('merchant_activated'.tr);
        Get.offAllNamed('/merchant-home');
      }
    } else {
      ToastService.showError('merchant_activation_failed'.tr);
    }
  }
}
