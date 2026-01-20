import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import '../../../core/services/toast_service.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/reports/services/report_service.dart';

class ReportDetailController extends GetxController {
  final ReportService _reportService = ReportService();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxMap<String, dynamic> report = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late final int reportId;

  String get _userType => _authService.userType.value.isEmpty
      ? 'customer'
      : _authService.userType.value;

  @override
  void onInit() {
    super.onInit();
    reportId = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
    loadReport();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadReport() async {
    try {
      isLoading.value = true;
      final r = await _reportService.getReport(userType: _userType, reportId: reportId);
      report.assignAll(r);
      final msgs = (r['messages'] as List?) ?? const [];
      messages.assignAll(msgs.map((e) => Map<String, dynamic>.from(e as Map)).toList());
      _scrollToBottom();
    } on DioException catch (e) {
      final msg = _extractBackendMessage(e) ?? TranslationHelper.tr('error');
      ToastService.showError(msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    try {
      isSending.value = true;
      await _reportService.sendReportMessage(
        userType: _userType,
        reportId: reportId,
        message: text,
      );
      messageController.clear();
      await loadReport();
    } on DioException catch (e) {
      final msg = _extractBackendMessage(e) ?? TranslationHelper.tr('error');
      ToastService.showError(msg);
    } finally {
      isSending.value = false;
    }
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
