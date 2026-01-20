import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/services/biometric_service.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/profile/controllers/profile_controller.dart';
import 'package:mrsheaf/features/profile/widgets/profile_menu_item.dart';

class ProfileMenuList extends GetView<ProfileController> {
  const ProfileMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // My Order
        Obx(() => ProfileMenuItem(
          title: 'my_orders'.tr,
          subtitle: controller.orderCountText,
          onTap: controller.navigateToMyOrders,
        )),

        const SizedBox(height: 16),

        // Shipping Addresses
        Obx(() => ProfileMenuItem(
          title: 'shipping_addresses'.tr,
          subtitle: controller.addressCountText,
          onTap: controller.navigateToShippingAddresses,
        )),

        const SizedBox(height: 16),

        // Biometric Login - يظهر فقط إذا كان الجهاز يدعم البصمة
        _buildBiometricToggle(),

        // Support Tickets
        ProfileMenuItem(
          title: 'support_tickets'.tr,
          subtitle: 'support_tickets_desc'.tr,
          onTap: controller.navigateToSupportTickets,
        ),

        const SizedBox(height: 16),

        // My Reports
        ProfileMenuItem(
          title: 'my_reports'.tr,
          subtitle: 'my_reports_desc'.tr,
          onTap: controller.navigateToMyReports,
        ),

        const SizedBox(height: 16),

        // My Reviews - تقييماتي
        ProfileMenuItem(
          title: 'my_reviews'.tr,
          subtitle: 'my_reviews_desc'.tr,
          onTap: controller.navigateToMyReviews,
        ),

        const SizedBox(height: 16),

        // Privacy Policy - includes account deletion instructions
        ProfileMenuItem(
          title: 'privacy'.tr,
          subtitle: 'privacy_policy_desc'.tr,
          onTap: controller.openPrivacyPolicy,
        ),

        const SizedBox(height: 16),

        // Log out
        ProfileMenuItem(
          title: 'logout'.tr,
          subtitle: null,
          isLogout: true,
          onTap: controller.logout,
        ),
      ],
    );
  }

  /// بناء خيار تفعيل البصمة - يظهر فقط إذا كان الجهاز يدعمها
  Widget _buildBiometricToggle() {
    try {
      final biometricService = Get.find<BiometricService>();
      
      return Obx(() {
        // لا تظهر الخيار إذا الجهاز لا يدعم البصمة
        if (!biometricService.isBiometricAvailable.value) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            ProfileMenuItem(
              title: 'biometric_login'.tr,
              subtitle: biometricService.isBiometricEnabled.value 
                  ? 'enabled'.tr
                  : 'disabled'.tr,
              hasToggle: true,
              toggleValue: biometricService.isBiometricEnabled.value,
              onToggleChanged: (value) => _handleBiometricToggle(value, biometricService),
              isLoading: biometricService.isLoading.value,
            ),
            const SizedBox(height: 16),
          ],
        );
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  /// معالجة تغيير حالة البصمة
  Future<void> _handleBiometricToggle(bool value, BiometricService biometricService) async {
    if (value) {
      // تفعيل البصمة - نحتاج التوكن الحالي من AuthService
      try {
        final authService = Get.find<AuthService>();
        final token = await authService.getToken();
        final user = authService.currentUser.value;
        final userType = authService.userType.value;
        
        if (token == null || user == null || userType.isEmpty) {
          ToastService.showError('biometric_login_manually'.tr);
          return;
        }
        
        final success = await biometricService.enableBiometricLogin(
          token: token,
          userType: userType,
          userId: user.id.toString(),
          phoneNumber: user.phoneNumber ?? '',
        );
        
        if (success) {
          ToastService.showSuccess('biometric_enable_success'.tr);
        } else {
          ToastService.showError('biometric_enable_failed'.tr);
        }
      } catch (e) {
        ToastService.showError('biometric_enable_failed'.tr);
      }
    } else {
      // إلغاء تفعيل البصمة
      await biometricService.disableBiometricLogin();
      ToastService.showWarning('biometric_disable_success'.tr);
    }
  }
}
