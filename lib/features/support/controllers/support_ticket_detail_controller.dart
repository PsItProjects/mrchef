import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/support/services/support_service.dart';

class SupportTicketDetailController extends GetxController {
  final SupportService _supportService = SupportService();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> ticket = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late final int ticketId;

  String get _userType => _authService.userType.value.isEmpty
      ? 'customer'
      : _authService.userType.value;

  @override
  void onInit() {
    super.onInit();
    ticketId = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
    loadTicket();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadTicket() async {
    try {
      isLoading.value = true;
      final t = await _supportService.getTicket(userType: _userType, ticketId: ticketId);
      ticket.assignAll(t);
      final msgs = (t['messages'] as List?) ?? const [];
      messages.assignAll(msgs.map((e) => Map<String, dynamic>.from(e as Map)).toList());
      _scrollToBottom();
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

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    try {
      isLoading.value = true;
      await _supportService.sendTicketMessage(
        userType: _userType,
        ticketId: ticketId,
        message: text,
      );
      messageController.clear();
      await loadTicket();
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
