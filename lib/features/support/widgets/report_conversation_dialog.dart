import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class ReportConversationDialog extends StatefulWidget {
  final Future<void> Function(String reason, String? details) onSubmit;

  const ReportConversationDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ReportConversationDialog> createState() => _ReportConversationDialogState();
}

class _ReportConversationDialogState extends State<ReportConversationDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? _reasonError;

  @override
  void dispose() {
    _reasonController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final reason = _reasonController.text.trim();
    final details = _detailsController.text.trim();

    if (reason.isEmpty) {
      setState(() => _reasonError = 'field_required'.tr);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    // Close the dialog first to avoid lifecycle issues with controllers/keyboard.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.back();
    }

    await widget.onSubmit(reason, details.isEmpty ? null : details);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale ?? Localizations.localeOf(context);
    final isRtl = const <String>{'ar', 'fa', 'ur', 'he'}.contains(locale.languageCode.toLowerCase());

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    InputDecoration decoration({
      required String label,
      String? errorText,
      Widget? prefixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.9), width: 1.4),
        ),
      );
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.flag_outlined, color: AppColors.primaryColor.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'report_conversation'.tr,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: 'cancel'.tr,
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close, color: cs.onSurface.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'report_conversation_hint'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.72)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reasonController,
                    textInputAction: TextInputAction.next,
                    decoration: decoration(
                      label: 'report_reason'.tr,
                      errorText: _reasonError,
                      prefixIcon: const Icon(Icons.report_gmailerrorred_outlined),
                    ),
                    onChanged: (_) {
                      if (_reasonError != null) {
                        setState(() => _reasonError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _detailsController,
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: decoration(
                      label: 'report_details_optional'.tr,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('cancel'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _handleSubmit,
                          child: Text('submit'.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
