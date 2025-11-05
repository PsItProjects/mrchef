import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A TextField widget with built-in validation error display
class ValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final GlobalKey? fieldKey;
  final bool required;

  const ValidatedTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.fieldKey,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Container(
      key: fieldKey,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasError ? Colors.red : const Color(0xFF351D66),
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // TextField
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            minLines: minLines,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF351D66),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: hasError ? Colors.red.withOpacity(0.05) : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey[300]!,
                  width: hasError ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey[300]!,
                  width: hasError ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : const Color(0xFFFACD02),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
          ),

          // Error Message
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

