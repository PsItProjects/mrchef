import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/support/services/support_service.dart';

class SupportTicketDetailController extends GetxController {
  final SupportService _supportService = SupportService();
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _imagePicker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxMap<String, dynamic> ticket = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late final int ticketId;
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 3); // Faster refresh

  String get _userType => _authService.userType.value.isEmpty
      ? 'customer'
      : _authService.userType.value;

  @override
  void onInit() {
    super.onInit();
    ticketId = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
    loadTicket();
    _startPolling();
  }

  @override
  void onClose() {
    _stopPolling();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Start auto-refresh polling for real-time updates
  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _silentRefresh();
    });
  }

  /// Stop polling
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Silent refresh without showing loading indicator
  Future<void> _silentRefresh() async {
    // Don't refresh if ticket is closed
    if (ticket['status'] == 'closed') {
      _stopPolling();
      return;
    }

    try {
      final t = await _supportService.getTicket(userType: _userType, ticketId: ticketId);
      final newMsgs = (t['messages'] as List?) ?? const [];
      
      // Only update if there are new messages
      if (newMsgs.length > messages.length) {
        print('🔄 New messages detected: ${newMsgs.length} vs ${messages.length}');
        ticket.assignAll(t);
        messages.assignAll(newMsgs.map((e) => Map<String, dynamic>.from(e as Map)).toList());
        _scrollToBottom();
      }
      
      // Update status if changed
      if (t['status'] != ticket['status']) {
        ticket.assignAll(t);
        if (t['status'] == 'closed') {
          _stopPolling();
        }
      }
    } catch (e) {
      // Silent fail - don't show errors for background refresh
      print('❌ Silent refresh error: $e');
    }
  }

  Future<void> loadTicket() async {
    try {
      isLoading.value = true;
      final t = await _supportService.getTicket(userType: _userType, ticketId: ticketId);
      ticket.assignAll(t);
      final msgs = (t['messages'] as List?) ?? const [];
      messages.assignAll(msgs.map((e) => Map<String, dynamic>.from(e as Map)).toList());
      _scrollToBottom();
      
      // Restart polling if ticket was reopened
      if (t['status'] != 'closed' && _pollingTimer == null) {
        _startPolling();
      }
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

    // Check if we have image to send
    if (selectedImage.value != null) {
      await _sendImageMessage();
      return;
    }

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

  Future<void> _sendImageMessage() async {
    if (selectedImage.value == null) return;

    try {
      isUploading.value = true;
      await _supportService.sendTicketImageMessage(
        userType: _userType,
        ticketId: ticketId,
        imageFile: selectedImage.value!,
        caption: messageController.text.trim(),
      );
      messageController.clear();
      selectedImage.value = null;
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
      isUploading.value = false;
    }
  }

  Future<void> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      selectedImage.value = File(pickedFile.path);
    } catch (e) {
      Get.snackbar(
        TranslationHelper.tr('error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
      );
    }
  }

  void clearSelectedImage() {
    selectedImage.value = null;
  }

  void showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.amber),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                pickImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.amber),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                pickImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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
