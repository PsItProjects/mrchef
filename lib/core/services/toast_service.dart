import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Professional Toast Service for the entire app
/// All toasts will appear at the TOP with consistent styling
class ToastService {
  // App theme colors
  static const Color _successColor = Color(0xFF2E7D32); // Dark Green
  static const Color _errorColor = Color(0xFFC62828); // Dark Red  
  static const Color _warningColor = Color(0xFFEF6C00); // Dark Orange
  static const Color _infoColor = Color(0xFF1565C0); // Dark Blue

  /// Show success toast (green)
  static void showSuccess(String message, {String? title}) {
    _showToast(
      message: message,
      title: title ?? 'success'.tr,
      icon: Icons.check_circle_rounded,
      backgroundColor: _successColor,
    );
  }

  /// Show error toast (red)
  static void showError(String message, {String? title}) {
    _showToast(
      message: message,
      title: title ?? 'error'.tr,
      icon: Icons.error_rounded,
      backgroundColor: _errorColor,
      duration: 4,
    );
  }

  /// Show warning toast (orange)
  static void showWarning(String message, {String? title}) {
    _showToast(
      message: message,
      title: title ?? 'warning'.tr,
      icon: Icons.warning_rounded,
      backgroundColor: _warningColor,
    );
  }

  /// Show info toast (blue)
  static void showInfo(String message, {String? title}) {
    _showToast(
      message: message,
      title: title ?? 'info'.tr,
      icon: Icons.info_rounded,
      backgroundColor: _infoColor,
    );
  }

  /// Internal method to show toast with consistent styling
  static void _showToast({
    required String message,
    required String title,
    required IconData icon,
    required Color backgroundColor,
    int duration = 3,
  }) {
    // Close any existing snackbar first
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      '',
      '',
      titleText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lato',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      messageText: SizedBox.shrink(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      duration: Duration(seconds: duration),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: Duration(milliseconds: 400),
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withOpacity(0.4),
          spreadRadius: 0,
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  /// Show validation errors toast with multiple errors
  static void showValidationErrors(Map<String, dynamic> errors, {String? title}) {
    List<String> errorMessages = [];
    
    errors.forEach((field, messages) {
      if (messages is List && messages.isNotEmpty) {
        errorMessages.add('• ${messages.first}');
      } else if (messages is String) {
        errorMessages.add('• $messages');
      }
    });

    String message = errorMessages.isNotEmpty
        ? errorMessages.join('\n')
        : 'please_check_errors_below'.tr;

    _showToast(
      message: message,
      title: title ?? 'validation_error'.tr,
      icon: Icons.warning_amber_rounded,
      backgroundColor: _errorColor,
      duration: 5,
    );
  }

  /// Show simple message (for quick notifications)
  static void showMessage(String message, {bool isError = false}) {
    if (isError) {
      showError(message);
    } else {
      showSuccess(message);
    }
  }
}
