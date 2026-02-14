import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/biometric_service.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/services/profile_switch_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/profile/widgets/about_app_bottom_sheet.dart';
import 'package:mrsheaf/features/profile/widgets/account_deletion_bottom_sheet.dart';
import 'package:mrsheaf/features/profile/pages/privacy_policy_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_orders_screen.dart';
import 'package:mrsheaf/features/profile/pages/shipping_addresses_screen.dart';
import 'package:mrsheaf/features/profile/pages/my_reviews_screen.dart';
import 'package:mrsheaf/features/merchant/pages/edit_restaurant_info_screen.dart';
import 'package:mrsheaf/features/merchant/pages/working_hours_screen.dart';
import 'package:mrsheaf/features/merchant/pages/merchant_coupons_screen.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

/// قائمة الإعدادات الموحدة - تتكيف حسب الدور الحالي (عميل / تاجر)
class UnifiedMenuList extends StatelessWidget {
  const UnifiedMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.find<LanguageService>().currentLanguage == 'ar';
    final authService = Get.find<AuthService>();

    // Determine current role
    final isMerchant = _isMerchantMode(authService);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ─── Customer-Only Section ───
          if (!isMerchant) ...[
            _buildSection(
              title: 'my_account'.tr,
              isArabic: isArabic,
              items: [
                _SettingsTileData(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: const Color(0xFF6C63FF),
                  title: 'my_orders'.tr,
                  subtitle: 'view_order_history'.tr,
                  onTap: () => Get.to(() => const MyOrdersScreen()),
                ),
                _SettingsTileData(
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF00BFA5),
                  title: 'shipping_addresses'.tr,
                  subtitle: 'manage_delivery_addresses'.tr,
                  onTap: () => Get.to(() => const ShippingAddressesScreen()),
                ),
                _SettingsTileData(
                  icon: Icons.star_outline_rounded,
                  iconColor: const Color(0xFFFFB300),
                  title: 'my_reviews'.tr,
                  subtitle: 'my_reviews_desc'.tr,
                  onTap: () => Get.to(() => const MyReviewsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // ─── Merchant-Only Section ───
          if (isMerchant) ...[
            _buildSection(
              title: 'restaurant_settings'.tr,
              isArabic: isArabic,
              items: [
                _SettingsTileData(
                  icon: Icons.store_rounded,
                  iconColor: AppColors.primaryColor,
                  title: 'restaurant_info'.tr,
                  subtitle: 'edit_restaurant_details'.tr,
                  onTap: () => Get.to(() => const EditRestaurantInfoScreen()),
                ),
                _SettingsTileData(
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFF9C27B0),
                  title: 'products'.tr,
                  subtitle: 'manage_restaurant_products'.tr,
                  onTap: () => Get.toNamed(AppRoutes.MERCHANT_PRODUCTS),
                ),
                _SettingsTileData(
                  icon: Icons.schedule_rounded,
                  iconColor: const Color(0xFF00BCD4),
                  title: 'working_hours'.tr,
                  subtitle: 'set_opening_closing_hours'.tr,
                  onTap: () => Get.to(() => const WorkingHoursScreen()),
                ),
                _SettingsTileData(
                  icon: Icons.discount,
                  iconColor: const Color(0xFFFF6B35),
                  title: 'discount_codes'.tr,
                  subtitle: 'manage_discount_codes'.tr,
                  onTap: () => Get.to(() => const MerchantCouponsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // ─── Common: Support Section ───
          _buildSection(
            title: 'support'.tr,
            isArabic: isArabic,
            items: [
              _SettingsTileData(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF2196F3),
                title: 'conversations'.tr,
                subtitle: 'view_conversations'.tr,
                onTap: () => Get.toNamed(AppRoutes.CONVERSATIONS),
              ),
              _SettingsTileData(
                icon: Icons.headset_mic_outlined,
                iconColor: const Color(0xFF4CAF50),
                title: 'support_tickets'.tr,
                subtitle: 'support_tickets_desc'.tr,
                onTap: () => Get.toNamed(AppRoutes.SUPPORT_TICKETS),
              ),
              if (!isMerchant)
                _SettingsTileData(
                  icon: Icons.report_outlined,
                  iconColor: const Color(0xFFFF7043),
                  title: 'my_reports'.tr,
                  subtitle: 'my_reports_desc'.tr,
                  onTap: () => Get.toNamed(AppRoutes.MY_REPORTS),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Common: App Settings ───
          _buildSection(
            title: 'app_settings'.tr,
            isArabic: isArabic,
            items: [
              _buildLanguageTileData(),
              _buildBiometricTileData(),
              _SettingsTileData(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFFF9800),
                title: 'notification_label'.tr,
                subtitle: 'manage_notifications'.tr,
                onTap: () {
                  if (isMerchant) {
                    Get.toNamed(AppRoutes.MERCHANT_NOTIFICATIONS);
                  } else {
                    Get.toNamed(AppRoutes.NOTIFICATIONS);
                  }
                },
              ),
              _SettingsTileData(
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF9C27B0),
                title: 'privacy'.tr,
                subtitle: 'privacy_policy_desc'.tr,
                onTap: () => Get.to(() => const PrivacyPolicyScreen()),
              ),
              _SettingsTileData(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primaryColor,
                title: 'about_app'.tr,
                subtitle: 'app_information'.tr,
                onTap: () => AboutAppBottomSheet.show(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Danger Zone ───
          _buildSection(
            title: 'account'.tr,
            isArabic: isArabic,
            items: [
              _SettingsTileData(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFEB5757),
                title: 'delete_account'.tr,
                subtitle: 'account_deletion_step1_title'.tr,
                onTap: () => AccountDeletionBottomSheet.show(),
                isDanger: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Logout ───
          _buildLogoutButton(isArabic),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  bool _isMerchantMode(AuthService authService) {
    try {
      if (Get.isRegistered<ProfileSwitchService>()) {
        final ps = Get.find<ProfileSwitchService>();
        if (ps.accountStatus.value != null) {
          return ps.accountStatus.value!.isMerchantMode;
        }
      }
      // Fallback
      return authService.userType.value == 'merchant';
    } catch (e) {
      return false;
    }
  }

  Widget _buildSection({
    required String title,
    required bool isArabic,
    required List<_SettingsTileData?> items,
  }) {
    final filtered = items.whereType<_SettingsTileData>().toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: isArabic ? null : 'Lato',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF999999),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...filtered.asMap().entries.map((entry) {
            final isLast = entry.key == filtered.length - 1;
            return _buildSettingsTile(entry.value, isArabic, isLast: isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    _SettingsTileData data,
    bool isArabic, {
    bool isLast = false,
  }) {
    // Handle special types
    if (data.customBuilder != null) {
      return data.customBuilder!();
    }

    return InkWell(
      onTap: data.onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(14))
          : BorderRadius.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: data.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontFamily: isArabic ? null : 'Lato',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: data.isDanger
                              ? const Color(0xFFEB5757)
                              : const Color(0xFF262626),
                        ),
                      ),
                      if (data.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          data.subtitle!,
                          style: TextStyle(
                            fontFamily: isArabic ? null : 'Lato',
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing
                if (data.trailing != null)
                  data.trailing!
                else
                  Icon(
                    isArabic
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
          if (!isLast)
            Container(
              margin: const EdgeInsets.only(left: 60),
              height: 0.5,
              color: const Color(0xFFF0F0F0),
            ),
        ],
      ),
    );
  }

  _SettingsTileData? _buildLanguageTileData() {
    try {
      final langService = Get.find<LanguageService>();
      final currentLang = langService.currentLanguage;
      final langName = currentLang == 'ar' ? 'العربية' : 'English';

      return _SettingsTileData(
        icon: Icons.language_rounded,
        iconColor: const Color(0xFF03A9F4),
        title: 'app_language'.tr,
        subtitle: langName,
        onTap: () => _showLanguageDialog(),
      );
    } catch (e) {
      return null;
    }
  }

  _SettingsTileData? _buildBiometricTileData() {
    try {
      final bio = Get.find<BiometricService>();
      if (!bio.isBiometricAvailable.value) return null;

      return _SettingsTileData(
        icon: Icons.fingerprint_rounded,
        iconColor: const Color(0xFF4CAF50),
        title: 'biometric_login'.tr,
        subtitle: bio.isBiometricEnabled.value ? 'enabled'.tr : 'disabled'.tr,
        onTap: () async {
          if (!bio.isBiometricEnabled.value) {
            final auth = Get.find<AuthService>();
            final token = await auth.getToken();
            final user = auth.currentUser.value;
            final userType = auth.userType.value;
            if (token == null || user == null) return;
            final ok = await bio.enableBiometricLogin(
              token: token,
              userType: userType,
              userId: user.id.toString(),
              phoneNumber: user.phoneNumber ?? '',
            );
            if (ok) {
              ToastService.showSuccess('biometric_enable_success'.tr);
            } else {
              ToastService.showError('biometric_auth_failed'.tr);
            }
          } else {
            await bio.disableBiometricLogin();
            ToastService.showWarning('biometric_disable_success'.tr);
          }
        },
      );
    } catch (e) {
      return null;
    }
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('select_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
              title: const Text('العربية'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onTap: () => _changeLanguage('ar'),
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onTap: () => _changeLanguage('en'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLanguage(String code) async {
    Get.back();
    Get.dialog(
      const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor)),
      barrierDismissible: false,
    );
    try {
      final langService = Get.find<LanguageService>();
      await langService.setLanguage(code);
      Get.updateLocale(Locale(code));
      Get.back();
      ToastService.showSuccess('language_updated_successfully'.tr);
    } catch (e) {
      Get.back();
      ToastService.showError('language_update_failed'.tr);
    }
  }

  Widget _buildLogoutButton(bool isArabic) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
        label: Text(
          'logout'.tr,
          style: TextStyle(
            fontFamily: isArabic ? null : 'Lato',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEB5757),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  void _handleLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,
                style: const TextStyle(color: Color(0xFF999999))),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                final auth = Get.find<AuthService>();
                await auth.logout();
              } catch (_) {}
              Get.offAllNamed('/login');
            },
            child: Text('logout'.tr,
                style: const TextStyle(color: Color(0xFFEB5757))),
          ),
        ],
      ),
    );
  }
}

/// Data class for settings tiles
class _SettingsTileData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDanger;
  final Widget? trailing;
  final Widget Function()? customBuilder;

  _SettingsTileData({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDanger = false,
    this.trailing,
    this.customBuilder,
  });
}
