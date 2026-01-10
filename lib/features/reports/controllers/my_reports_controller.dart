import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/reports/services/report_service.dart';

class MyReportsController extends GetxController {
  final ReportService _reportService = ReportService();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> reports = <Map<String, dynamic>>[].obs;

  String get _userType => _authService.userType.value.isEmpty
      ? 'customer'
      : _authService.userType.value;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      isLoading.value = true;
      final list = await _reportService.listReports(userType: _userType);
      reports.assignAll(list);
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

  void navigateToReportDetail(int reportId) {
    Get.toNamed(
      AppRoutes.REPORT_DETAIL,
      parameters: {'id': reportId.toString()},
    );
  }

  String getStatusText(String status) {
    switch (status) {
      case 'open':
        return TranslationHelper.tr('status_open');
      case 'in_progress':
        return TranslationHelper.tr('status_in_progress');
      case 'closed':
        return TranslationHelper.tr('status_closed');
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
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
