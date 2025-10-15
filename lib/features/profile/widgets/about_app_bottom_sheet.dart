import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/utils/app_constants.dart';

/// Professional About App Bottom Sheet
/// Shows app logo, version, and information in a beautiful modal
class AboutAppBottomSheet extends StatelessWidget {
  const AboutAppBottomSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const AboutAppBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          _buildDragHandle(),

          const SizedBox(height: 24),

          // App Logo
          _buildAppLogo(),

          const SizedBox(height: 16),

          // App Name
          _buildAppName(isArabic),

          const SizedBox(height: 8),

          // App Version
          _buildAppVersion(isArabic),

          const SizedBox(height: 24),

          // Divider
          _buildDivider(),

          const SizedBox(height: 20),

          // App Description
          _buildAppDescription(isArabic),

          const SizedBox(height: 24),

          // App Info Cards
          _buildInfoCards(isArabic),

          const SizedBox(height: 24),

          // Close Button
          _buildCloseButton(isArabic),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Image.asset(
        'assets/mr_sheaf_logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAppName(bool isArabic) {
    return Text(
      isArabic ? 'مستر شيف' : AppConstants.appName,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: AppColors.secondaryColor,
      ),
    );
  }

  Widget _buildAppVersion(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${'version'.tr} ${AppConstants.appVersion}',
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      height: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildAppDescription(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'app_description'.tr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFF5E5E5E),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoCards(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.restaurant,
              title: 'restaurants'.tr,
              subtitle: '500+',
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.people,
              title: 'users'.tr,
              subtitle: '10K+',
              color: AppColors.secondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.shopping_bag,
              title: 'orders'.tr,
              subtitle: '50K+',
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.secondaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'close'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

