import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/features/profile/services/account_deletion_service.dart';

class AccountDeletionBottomSheet {
  static void show() {
    Get.bottomSheet(
      const _AccountDeletionSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _AccountDeletionSheet extends StatefulWidget {
  const _AccountDeletionSheet();

  @override
  State<_AccountDeletionSheet> createState() => _AccountDeletionSheetState();
}

class _AccountDeletionSheetState extends State<_AccountDeletionSheet> {
  final RxInt _step = 0.obs;
  final RxBool _isLoading = false.obs;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  late final AccountDeletionService _service;

  @override
  void initState() {
    super.initState();
    _service = Get.isRegistered<AccountDeletionService>()
        ? Get.find<AccountDeletionService>()
        : Get.put(AccountDeletionService());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtpAndGoNext() async {
    _isLoading.value = true;
    try {
      final result = await _service.sendOtp();
      if (result['success'] == true) {
        ToastService.showSuccess(result['message'] ?? '');
        _step.value = 1;
      } else {
        ToastService.showError(result['message'] ?? '');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _confirmRequest() async {
    final otp = _otpController.text.trim();
    if (otp.length != 4) {
      ToastService.showError('account_deletion_enter_otp_error'.tr);
      return;
    }

    _isLoading.value = true;
    try {
      final result = await _service.confirm(
        otp: otp,
        reason: _reasonController.text,
      );

      if (result['success'] == true) {
        ToastService.showSuccess(result['message'] ?? '');

        // Ensure local logout + route reset
        try {
          final auth = Get.find<AuthService>();
          await auth.logout(
            postLogoutToastMessage: 'account_deletion_post_logout_toast'.tr,
          );
        } catch (_) {
          // ignore
        }

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        ToastService.showError(result['message'] ?? '');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Obx(() {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _step.value == 0
                              ? 'account_deletion_step1_title'.tr
                              : 'account_deletion_step2_title'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF262626),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading.value ? null : () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_step.value == 0) ...[
                    _buildNoticeCard(),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'account_deletion_reason_optional'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF262626),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      minLines: 3,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'account_deletion_reason_hint'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading.value ? null : _sendOtpAndGoNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEB5757),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'account_deletion_next'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ] else ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'account_deletion_enter_otp'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF262626),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        hintText: 'account_deletion_enter_otp_hint'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _isLoading.value
                                  ? null
                                  : () {
                                      _step.value = 0;
                                    },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFBDBDBD)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'back'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: Color(0xFF262626),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading.value ? null : _confirmRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEB5757),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'account_deletion_submit'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF2994A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'account_deletion_notice_30_days'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5E5E5E),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
