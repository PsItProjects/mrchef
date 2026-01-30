import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

class GuestService extends GetxService {
  static const String _isGuestKey = 'is_guest_mode';
  
  final RxBool _isGuestMode = false.obs;
  SharedPreferences? _prefs;

  Future<GuestService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isGuestMode.value = _prefs?.getBool(_isGuestKey) ?? false;
    return this;
  }

  /// Enter guest mode
  Future<void> enterGuestMode() async {
    _isGuestMode.value = true;
    await _prefs?.setBool(_isGuestKey, true);
    Get.offAllNamed(AppRoutes.HOME);
  }

  /// Exit guest mode
  Future<void> exitGuestMode() async {
    _isGuestMode.value = false;
    await _prefs?.setBool(_isGuestKey, false);
  }

  /// Check if user is in guest mode
  bool get isGuestMode => _isGuestMode.value;

  /// Check if user is in guest mode (alias)
  bool get isGuest => _isGuestMode.value;

  /// Show login required modal
  /// Returns true if user chose to login/signup, false if dismissed
  Future<bool> showLoginRequiredModal({
    String? title,
    String? message,
    bool canDismiss = true,
    BuildContext? context, // Optional context parameter
  }) async {
    final result = await Get.dialog<bool>(
      _LoginRequiredModal(
        title: title,
        message: message,
        canDismiss: canDismiss,
      ),
      barrierDismissible: canDismiss,
    );
    return result ?? false;
  }

  /// Check guest and show modal if needed
  /// Returns true if user is guest (and modal was shown)
  /// Returns false if user is not guest
  bool checkGuestAndShowModal({
    String? title,
    String? message,
    BuildContext? context, // Optional context parameter
  }) {
    if (isGuest) {
      showLoginRequiredModal(title: title, message: message);
      return true; // User IS guest
    }
    return false; // User is NOT guest
  }
}

class _LoginRequiredModal extends StatelessWidget {
  final String? title;
  final String? message;
  final bool canDismiss;

  const _LoginRequiredModal({
    this.title,
    this.message,
    this.canDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button (if dismissible)
            if (canDismiss)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(result: false),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.login_rounded,
                size: 40,
                color: AppColors.primaryColor,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              title ?? 'login_required'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              message ?? 'guest_login_message'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 28),
            
            // Login button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  Get.back(result: true);
                  // Exit guest mode
                  final guestService = Get.find<GuestService>();
                  await guestService.exitGuestMode();
                  Get.offAllNamed(AppRoutes.LOGIN);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'login'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF592E2C),
                    height: 1.2,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Sign up button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () async {
                  Get.back(result: true);
                  // Exit guest mode
                  final guestService = Get.find<GuestService>();
                  await guestService.exitGuestMode();
                  Get.offAllNamed(AppRoutes.SIGNUP);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'create_account'.tr,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Continue as guest link
            GestureDetector(
              onTap: () => Get.back(result: false),
              child: Text(
                'continue_browsing'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF999999),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
