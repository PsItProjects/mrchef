import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/services/biometric_service.dart';
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
          title: TranslationHelper.tr('my_orders'),
          subtitle: controller.orderCountText,
          onTap: controller.navigateToMyOrders,
        )),

        const SizedBox(height: 16),

        // Shipping Addresses
        Obx(() => ProfileMenuItem(
          title: TranslationHelper.tr('shipping_addresses'),
          subtitle: controller.addressCountText,
          onTap: controller.navigateToShippingAddresses,
        )),

        const SizedBox(height: 16),

        // Biometric Login - يظهر فقط إذا كان الجهاز يدعم البصمة
        _buildBiometricToggle(),

        // Payment Method
        // Obx(() => ProfileMenuItem(
        //   title: TranslationHelper.tr('payment_methods'),
        //   subtitle: controller.cardCountText,
        //   onTap: controller.navigateToPaymentMethods,
        // )),
        //
        // const SizedBox(height: 16),
        //
        // // My reviews
        // Obx(() => ProfileMenuItem(
        //   title: TranslationHelper.tr('my_reviews'),
        //   subtitle: controller.reviewCountText,
        //   onTap: controller.navigateToMyReviews,
        // )),
        //
        // const SizedBox(height: 16),
        //
        // // Setting
        // ProfileMenuItem(
        //   title: 'settings'.tr,
        //   subtitle: 'notification_password_faq_content'.tr,
        //   onTap: controller.navigateToSettings,
        // ),
        
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
              title: TranslationHelper.tr('biometric_login'),
              subtitle: biometricService.isBiometricEnabled.value 
                  ? TranslationHelper.tr('enabled')
                  : TranslationHelper.tr('disabled'),
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
          Get.snackbar(
            'فشل التفعيل',
            'لا يمكن تفعيل البصمة. تأكد من تسجيل الدخول أولاً',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
          );
          return;
        }
        
        final success = await biometricService.enableBiometricLogin(
          token: token,
          userType: userType,
          userId: user.id.toString(),
          phoneNumber: user.phoneNumber ?? '',
        );
        
        if (success) {
          Get.snackbar(
            'تم التفعيل',
            'تم تفعيل تسجيل الدخول بالبصمة',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.3),
          );
        } else {
          Get.snackbar(
            'فشل التفعيل',
            'لا يمكن تفعيل البصمة',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.3),
          );
        }
      } catch (e) {
        Get.snackbar(
          'فشل التفعيل',
          'لا يمكن تفعيل البصمة. تأكد من تسجيل الدخول أولاً',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.3),
        );
      }
    } else {
      // إلغاء تفعيل البصمة
      await biometricService.disableBiometricLogin();
      Get.snackbar(
        'تم الإلغاء',
        'تم إلغاء تسجيل الدخول بالبصمة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.3),
      );
    }
  }
}
