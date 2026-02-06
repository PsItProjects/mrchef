import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/profile/pages/edit_profile_screen.dart';
import 'package:mrsheaf/features/merchant/pages/edit_personal_profile_screen.dart';

/// بطاقة الملف الشخصي الموحدة مع زر تبديل الحساب (مثل فيسبوك)
/// تُستخدم لكل من العميل والتاجر
class UnifiedProfileCard extends StatelessWidget {
  const UnifiedProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final isArabic = Get.find<LanguageService>().currentLanguage == 'ar';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── User Info Row ───
          InkWell(
            onTap: () {
              // Navigate to appropriate edit profile screen
              final isMerchant = _isMerchantMode();
              if (isMerchant) {
                Get.to(() => const EditPersonalProfileScreen());
              } else {
                Get.to(() => const EditProfileScreen());
              }
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                final user = authService.currentUser.value;
                final displayName = user?.displayName ?? '';
                final email = user?.email ?? '';
                final avatarUrl = user?.avatarUrl;
                final initial = displayName.isNotEmpty
                    ? displayName[0].toUpperCase()
                    : '?';

                return Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                width: 56,
                                height: 56,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    // Name & Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontFamily: isArabic ? null : 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: const Color(0xFF262626),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email,
                            style: TextStyle(
                              fontFamily: isArabic ? null : 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: const Color(0xFF999999),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Arrow to Edit
                    Icon(
                      isArabic
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: const Color(0xFFBBBBBB),
                    ),
                  ],
                );
              }),
            ),
          ),

          // ─── Role Badge + Switch Button ───
          _buildSwitchSection(isArabic),
        ],
      ),
    );
  }

  Widget _buildSwitchSection(bool isArabic) {
    try {
      if (!Get.isRegistered<ProfileSwitchService>()) {
        return const SizedBox.shrink();
      }

      final switchService = Get.find<ProfileSwitchService>();

      return Obx(() {
        final status = switchService.accountStatus.value;
        final isSwitching = switchService.isSwitching.value;

        if (status == null) {
          if (!switchService.isLoadingStatus.value) {
            switchService.fetchAccountStatus();
          }
          return const SizedBox.shrink();
        }

        // ── Current role badge
        final isM = status.isMerchantMode;
        final roleIcon = isM ? Icons.store_rounded : Icons.person_rounded;
        final roleLabel =
            isM ? 'merchant_account'.tr : 'customer_account'.tr;
        final roleBadgeColor =
            isM ? const Color(0xFF6C63FF) : AppColors.primaryColor;

        // ── Switch action
        String? switchLabel;
        IconData? switchIcon;
        Color switchColor = const Color(0xFF27AE60);
        VoidCallback? onSwitch;

        if (status.canSwitchToMerchant && status.isCustomerMode) {
          switchLabel = 'switch_to_merchant'.tr;
          switchIcon = Icons.store_rounded;
          switchColor = const Color(0xFF6C63FF);
          onSwitch = () => _handleSwitch(switchService, 'merchant');
        } else if (status.canSwitchToMerchant && status.isMerchantMode) {
          switchLabel = 'switch_to_customer'.tr;
          switchIcon = Icons.person_rounded;
          switchColor = AppColors.primaryColor;
          onSwitch = () => _handleSwitch(switchService, 'customer');
        } else if (status.canActivateMerchant && status.isCustomerMode) {
          switchLabel = 'become_merchant'.tr;
          switchIcon = Icons.rocket_launch_rounded;
          switchColor = const Color(0xFFFF8008);
          onSwitch = () => _handleActivate(switchService);
        } else if (status.hasMerchantProfile &&
            !status.merchantOnboardingCompleted &&
            status.isCustomerMode) {
          switchLabel = 'complete_merchant_setup'.tr;
          switchIcon = Icons.settings_suggest_rounded;
          switchColor = const Color(0xFF11998E);
          onSwitch = () => _handleSwitch(switchService, 'merchant');
        }

        if (switchLabel == null) return const SizedBox.shrink();

        return Column(
          children: [
            // Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: const Color(0xFFF0F0F0),
            ),
            // Role badge row + switch button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  // Active role badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: roleBadgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleIcon, size: 14, color: roleBadgeColor),
                        const SizedBox(width: 5),
                        Text(
                          roleLabel,
                          style: TextStyle(
                            fontFamily: isArabic ? null : 'Lato',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleBadgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Switch button
                  GestureDetector(
                    onTap: isSwitching ? null : onSwitch,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSwitching
                            ? Colors.grey[200]
                            : switchColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSwitching
                              ? Colors.grey[300]!
                              : switchColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: isSwitching
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    switchColor),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(switchIcon, size: 15, color: switchColor),
                                const SizedBox(width: 6),
                                Text(
                                  switchLabel,
                                  style: TextStyle(
                                    fontFamily: isArabic ? null : 'Lato',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: switchColor,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  bool _isMerchantMode() {
    try {
      if (Get.isRegistered<ProfileSwitchService>()) {
        final ps = Get.find<ProfileSwitchService>();
        if (ps.accountStatus.value != null) {
          return ps.accountStatus.value!.isMerchantMode;
        }
      }
      final auth = Get.find<AuthService>();
      return auth.userType.value == 'merchant';
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleSwitch(
      ProfileSwitchService service, String target) async {
    final success = await service.switchRole();
    if (success) {
      if (target == 'merchant') {
        ToastService.showSuccess('switched_to_merchant'.tr);
        Get.offAllNamed('/merchant-home');
      } else {
        ToastService.showSuccess('switched_to_customer'.tr);
        Get.offAllNamed('/home');
      }
    } else {
      ToastService.showError('switch_failed'.tr);
    }
  }

  Future<void> _handleActivate(ProfileSwitchService service) async {
    final success = await service.activateMerchant();
    if (success) {
      final switched = await service.switchRole();
      if (switched) {
        ToastService.showSuccess('merchant_activated'.tr);
        Get.offAllNamed('/merchant-home');
      }
    } else {
      ToastService.showError('merchant_activation_failed'.tr);
    }
  }
}
