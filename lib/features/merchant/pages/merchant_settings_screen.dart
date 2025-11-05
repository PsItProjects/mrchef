import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/merchant/services/merchant_profile_service.dart';
import 'package:mrsheaf/features/merchant/pages/edit_restaurant_info_screen.dart';
import 'package:mrsheaf/features/merchant/pages/working_hours_screen.dart';
import 'package:mrsheaf/features/merchant/pages/notification_settings_screen.dart';
import 'package:mrsheaf/features/merchant/pages/edit_personal_profile_screen.dart';
import 'package:mrsheaf/features/profile/widgets/about_app_bottom_sheet.dart';

class MerchantSettingsScreen extends StatefulWidget {
  const MerchantSettingsScreen({Key? key}) : super(key: key);

  @override
  State<MerchantSettingsScreen> createState() => _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  final _profileService = Get.put(MerchantProfileService());
  final _authService = Get.find<AuthService>();
  final _languageService = Get.find<LanguageService>();

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    print('🔄 Settings: Loading profile...');
    setState(() => _isLoading = true);
    final data = await _profileService.getProfile();
    print('✅ Settings: Profile loaded');
    print('   data keys: ${data?.keys.toList()}');
    if (data != null && data.containsKey('merchant')) {
      print('   merchant avatar: ${data['merchant']?['avatar']}');
    }
    setState(() {
      _profileData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildRestaurantSection(),
                    const SizedBox(height: 20),
                    _buildAccountSection(),
                    const SizedBox(height: 20),
                    _buildNotificationsSection(),
                    const SizedBox(height: 20),
                    _buildAppSection(),
                    const SizedBox(height: 20),
                    _buildLogoutButton(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.settings, color: AppColors.primaryColor, size: 28),
          const SizedBox(width: 12),
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

  Widget _buildProfileCard() {
    final merchant = _profileData?['merchant'];
    final merchantName = merchant?['name']?['current'] ?? 'merchant'.tr;
    final email = merchant?['email'] ?? 'merchant@example.com';
    final avatarUrl = merchant?['avatar'];
    final firstLetter = merchantName.isNotEmpty ? merchantName[0].toUpperCase() : 'M';

    print('🖼️ Settings: Building profile card');
    print('   avatarUrl: $avatarUrl');
    print('   merchantName: $merchantName');
    print('   email: $email');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            key: ValueKey(avatarUrl ?? 'no_avatar'), // Force rebuild when avatar changes
            radius: 30,
            backgroundColor: AppColors.primaryColor,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Get.to(() => const EditPersonalProfileScreen());
              if (result == true) await _loadProfile();
            },
            child: Icon(Icons.edit, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection() {
    return _buildSection(
      title: 'restaurant_settings'.tr,
      items: [
        _buildSettingsTile(
          icon: Icons.store,
          iconColor: AppColors.primaryColor,
          title: 'restaurant_info'.tr,
          subtitle: 'edit_restaurant_details'.tr,
          onTap: () async {
            final result = await Get.to(() => const EditRestaurantInfoScreen());
            if (result == true) {
              _loadProfile();
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.inventory_2,
          iconColor: const Color(0xFF9C27B0),
          title: 'products'.tr,
          subtitle: 'manage_restaurant_products'.tr,
          onTap: () => Get.toNamed('/merchant/products'),
        ),
        _buildSettingsTile(
          icon: Icons.schedule,
          iconColor: AppColors.primaryColor,
          title: 'working_hours'.tr,
          subtitle: 'set_opening_closing_hours'.tr,
          onTap: () => Get.to(() => const WorkingHoursScreen()),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'account_settings'.tr,
      items: [
        _buildSettingsTile(
          icon: Icons.person,
          iconColor: AppColors.primaryColor,
          title: 'personal_profile'.tr,
          subtitle: 'edit_personal_account'.tr,
          onTap: () async {
            final result = await Get.to(() => const EditPersonalProfileScreen());
            if (result == true) await _loadProfile();
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      title: 'notifications'.tr,
      items: [
        _buildSettingsTile(
          icon: Icons.notifications,
          iconColor: AppColors.primaryColor,
          title: 'notification_settings'.tr,
          subtitle: 'manage_notifications'.tr,
          onTap: () => Get.to(() => const NotificationSettingsScreen()),
        ),
      ],
    );
  }

  Widget _buildAppSection() {
    return _buildSection(
      title: 'app_settings'.tr,
      items: [
        _buildLanguageTile(),
        _buildSettingsTile(
          icon: Icons.info_outline,
          iconColor: AppColors.primaryColor,
          title: 'about_app'.tr,
          subtitle: 'app_information'.tr,
          onTap: () {
            AboutAppBottomSheet.show();
          },
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkColor,
              ),
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Obx(() {
      final currentLang = _languageService.currentLanguage;
      final langName = currentLang == 'ar' ? 'العربية' : 'English';

      return InkWell(
        onTap: _showLanguageDialog,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.language, color: AppColors.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'app_language'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(langName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      );
    });
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('select_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
              title: const Text('العربية'),
              onTap: () => _changeLanguage('ar'),
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              onTap: () => _changeLanguage('en'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    Get.back(); // Close dialog

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
      barrierDismissible: false,
    );

    try {
      // 1. Update language in backend
      final success = await _profileService.updateLanguage(languageCode);

      if (success) {
        // 2. Update language locally
        await _languageService.setLanguage(languageCode);

        // 3. Update locale
        Get.updateLocale(Locale(languageCode));

        // 4. Reload profile data to get updated translations
        await _loadProfile();

        // Close loading dialog
        Get.back();

        // Show success message
        Get.snackbar(
          'success'.tr,
          'language_updated_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Close loading dialog
        Get.back();

        // Show error message
        Get.snackbar(
          'error'.tr,
          'language_update_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog
      Get.back();

      // Show error message
      Get.snackbar(
        'error'.tr,
        'language_update_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'logout'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _authService.logout();
              } catch (e) {
                print('Logout error: $e');
              }
              Get.offAllNamed('/login');
            },
            child: Text(
              'logout'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
