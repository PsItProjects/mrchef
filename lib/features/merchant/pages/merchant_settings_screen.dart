import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/core/widgets/language_switcher.dart';
import 'package:mrsheaf/features/merchant/services/merchant_settings_service.dart';
import 'package:mrsheaf/features/merchant/services/merchant_profile_service.dart';
import 'package:mrsheaf/features/merchant/pages/restaurant_info_screen.dart';
import 'package:mrsheaf/features/merchant/pages/working_hours_screen.dart';
import 'package:mrsheaf/features/merchant/pages/notification_settings_screen.dart';
import 'package:mrsheaf/features/merchant/pages/edit_personal_profile_screen.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';

class MerchantSettingsScreen extends StatefulWidget {
  const MerchantSettingsScreen({Key? key}) : super(key: key);

  @override
  State<MerchantSettingsScreen> createState() => _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  final _settingsService = Get.put(MerchantSettingsService());
  final _profileService = Get.put(MerchantProfileService());
  final _authService = Get.find<AuthService>();

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    print('🔄 MerchantSettings: Loading profile...');
    final data = await _profileService.getProfile();
    print('📊 MerchantSettings: Profile data received: ${data != null ? "✅" : "❌"}');
    if (data != null) {
      print('   merchant: ${data['merchant'] != null ? "✅" : "❌"}');
      print('   name: ${data['merchant']?['name']}');
    }
    setState(() {
      _profileData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: 20),

              // Profile Section
              _buildProfileSection(),

              const SizedBox(height: 20),

              // Settings Sections
              _buildSettingsSection(),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'merchant_settings'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final merchant = _profileData?['merchant'];
    final merchantName = merchant?['name']?['current'] ?? 'التاجر';
    final email = merchant?['email'] ?? 'merchant@example.com';
    final avatarUrl = merchant?['avatar'];

    // Get first letter for avatar fallback (use merchant name, not restaurant)
    final firstLetter = merchantName.isNotEmpty
        ? merchantName[0].toUpperCase()
        : 'ت';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryColor,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    firstLetter,
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              // Navigate to edit profile (don't pass old data, let it load fresh)
              final result = await Get.to(() => const EditPersonalProfileScreen());

              // Reload profile if updated
              if (result == true) {
                await _loadProfile();
              }
            },
            child: Icon(
              Icons.edit,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        // Restaurant Settings
        _buildSettingsGroup(
          title: 'إعدادات المطعم',
          items: [
            _buildSettingsItem(
              icon: Icons.store,
              title: 'معلومات المطعم',
              subtitle: 'تعديل اسم وتفاصيل المطعم',
              onTap: () {
                Get.to(() => const RestaurantInfoScreen());
              },
            ),
            _buildSettingsItem(
              icon: Icons.schedule,
              title: 'أوقات العمل',
              subtitle: 'تحديد أوقات فتح وإغلاق المطعم',
              onTap: () {
                Get.to(() => const WorkingHoursScreen());
              },
            ),
            // Location - Hidden until implemented
            // _buildSettingsItem(
            //   icon: Icons.location_on,
            //   title: 'العنوان',
            //   subtitle: 'تحديث عنوان المطعم',
            //   onTap: () {
            //     // TODO: Implement location update screen
            //   },
            // ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Account Settings
        _buildSettingsGroup(
          title: 'إعدادات الحساب',
          items: [
            _buildSettingsItem(
              icon: Icons.person,
              title: 'الملف الشخصي',
              subtitle: 'تعديل معلومات الحساب الشخصي',
              onTap: () async {
                // Navigate to edit profile (don't pass old data, let it load fresh)
                final result = await Get.to(() => const EditPersonalProfileScreen());

                // Reload profile if updated
                if (result == true) {
                  await _loadProfile();
                }
              },
            ),
            // Change Password - Hidden until implemented
            // _buildSettingsItem(
            //   icon: Icons.lock,
            //   title: 'تغيير كلمة المرور',
            //   subtitle: 'تحديث كلمة مرور الحساب',
            //   onTap: () {
            //     // TODO: Implement change password screen
            //   },
            // ),
            _buildSettingsItem(
              icon: Icons.notifications,
              title: 'الإشعارات',
              subtitle: 'إدارة إعدادات الإشعارات',
              onTap: () {
                Get.to(() => const NotificationSettingsScreen());
              },
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // App Settings
        _buildSettingsGroup(
          title: 'إعدادات التطبيق',
          items: [
            _buildLanguageSettingsItem(),
            // Help & Support - Hidden until implemented
            // _buildSettingsItem(
            //   icon: Icons.help,
            //   title: 'المساعدة والدعم',
            //   subtitle: 'الحصول على المساعدة',
            //   onTap: () {
            //     // TODO: Implement help & support screen
            //   },
            // ),
            // About App - Hidden until implemented
            // _buildSettingsItem(
            //   icon: Icons.info,
            //   title: 'حول التطبيق',
            //   subtitle: 'معلومات عن التطبيق',
            //   onTap: () {
            //     // TODO: Implement about app screen
            //   },
            // ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Logout
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkColor,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSettingsItem() {
    final languageService = LanguageService.instance;
    return Obx(() {
      final isArabic = languageService.isArabic;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.language,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          title: Text(
            'app_language'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'change_app_language'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'العربية' : 'English',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
          onTap: () => _showLanguageDialog(),
        );
    });
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'app_language'.tr,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('ar', 'العربية', 'Arabic'),
            const SizedBox(height: 10),
            _buildLanguageOption('en', 'English', 'English'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String englishName) {
    final languageService = LanguageService.instance;
    return Obx(() {
      final isSelected = languageService.currentLanguage == code;
        return GestureDetector(
          onTap: () {
            languageService.setLanguage(code);
            Get.updateLocale(Locale(code));
            Get.back();
            Get.snackbar(
              'success'.tr,
              'Language changed successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.successColor,
              colorText: Colors.white,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primaryColor : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primaryColor : AppColors.textDarkColor,
                  ),
                ),
              ],
            ),
          ),
        );
    });
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          TranslationHelper.tr('logout_title'),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(TranslationHelper.tr('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              TranslationHelper.tr('cancel'),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();

              try {
                final authService = Get.find<AuthService>();
                await authService.logout();

                Get.snackbar(
                  TranslationHelper.tr('logout_title'),
                  TranslationHelper.tr('logout_success'),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.successColor,
                  colorText: Colors.white,
                );
              } catch (e) {
                print('Logout error: $e');
              }

              Get.offAllNamed(AppRoutes.LOGIN);
            },
            child: Text(
              TranslationHelper.tr('logout'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
