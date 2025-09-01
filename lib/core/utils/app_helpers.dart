import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_constants.dart';

class AppHelpers {
  // Date and Time Helpers
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatTime(DateTime time, {String pattern = 'HH:mm'}) {
    return DateFormat(pattern).format(time);
  }

  static String formatDateTime(DateTime dateTime, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(pattern).format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // String Helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  static String removeHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Number Helpers
  static String formatCurrency(double amount, {String currency = AppConstants.defaultCurrency}) {
    final formatter = NumberFormat.currency(symbol: '$currency ', decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatNumber(num number, {int decimalPlaces = 0}) {
    return NumberFormat('#,##0.${'0' * decimalPlaces}').format(number);
  }

  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  // Validation Helpers
  static bool isValidEmail(String email) {
    return AppConstants.emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return AppConstants.phoneRegex.hasMatch(phone);
  }

  static bool isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  // Device Helpers
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isWeb => !isMobile;

  static double get screenWidth => Get.width;
  static double get screenHeight => Get.height;
  static double get statusBarHeight => Get.mediaQuery.padding.top;
  static double get bottomBarHeight => Get.mediaQuery.padding.bottom;

  static bool get isDarkMode => Get.isDarkMode;
  static bool get isLandscape => Get.width > Get.height;
  static bool get isPortrait => Get.height > Get.width;

  static bool isMobileScreen(double width) => AppConstants.isMobile(width);
  static bool isTabletScreen(double width) => AppConstants.isTablet(width);
  static bool isDesktopScreen(double width) => AppConstants.isDesktop(width);

  // Navigation Helpers
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void showKeyboard(FocusNode focusNode) {
    FocusScope.of(Get.context!).requestFocus(focusNode);
  }

  // Haptic Feedback
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  // URL Launcher Helpers
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> launchEmail(String email, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&'),
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch email';
    }
  }

  static Future<void> launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch phone';
    }
  }

  static Future<void> launchSMS(String phone, {String? message}) async {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      query: message != null ? 'body=${Uri.encodeComponent(message)}' : null,
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch SMS';
    }
  }

  // Color Helpers
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  // File Helpers
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.allowedImageTypes.contains(extension);
  }

  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.allowedDocumentTypes.contains(extension);
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // List Helpers
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }

  static T? randomElement<T>(List<T> list) {
    if (list.isEmpty) return null;
    return list[Random().nextInt(list.length)];
  }

  // Debounce Helper
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
}

// Timer import
import 'dart:async';
