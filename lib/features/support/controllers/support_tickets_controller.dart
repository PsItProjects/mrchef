import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/support/services/support_service.dart';

class SupportTicketsController extends GetxController {
  final SupportService _supportService = SupportService();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> tickets = <Map<String, dynamic>>[].obs;

  String get _userType => _authService.userType.value.isEmpty
      ? 'customer'
      : _authService.userType.value;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  Future<void> loadTickets() async {
    try {
      isLoading.value = true;
      final result = await _supportService.listTickets(userType: _userType);
      tickets.assignAll(result);
    } on DioException catch (e) {
      final msg = _extractBackendMessage(e) ?? TranslationHelper.tr('error');
      Get.snackbar(
        TranslationHelper.tr('error'),
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTicket({required String subject, String? description}) async {
    try {
      isLoading.value = true;
      await _supportService.createTicket(
        userType: _userType,
        subject: subject,
        description: description,
      );
      await loadTickets();
      Get.snackbar(
        TranslationHelper.tr('success'),
        TranslationHelper.tr('success'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.2),
      );
    } on DioException catch (e) {
      final msg = _extractBackendMessage(e) ?? TranslationHelper.tr('error');
      Get.snackbar(
        TranslationHelper.tr('error'),
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openTicket(int id) {
    Get.toNamed('/support/tickets/$id');
  }

  String? _extractBackendMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        final m = (data['message'] as String).trim();
        return m.isEmpty ? null : m;
      }
      if (data is String) {
        final m = data.trim();
        return m.isEmpty ? null : m;
      }
    } catch (_) {}
    return null;
  }
}
