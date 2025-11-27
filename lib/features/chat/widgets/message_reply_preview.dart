import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';

/// Widget to display a replied-to message preview (WhatsApp style)
class MessageReplyPreview extends StatelessWidget {
  final RepliedMessageModel repliedMessage;
  final VoidCallback onTap;

  const MessageReplyPreview({
    super.key,
    required this.repliedMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            right: isArabic
                ? BorderSide.none
                : const BorderSide(
                    color: Color(0xFFFACD02),
                    width: 3,
                  ),
            left: isArabic
                ? const BorderSide(
                    color: Color(0xFFFACD02),
                    width: 3,
                  )
                : BorderSide.none,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sender name or "Order Details"
            Text(
              _getSenderLabel(),
              style: const TextStyle(
                color: Color(0xFFFACD02),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Message preview
            Text(
              _getMessagePreview(),
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getSenderLabel() {
    if (repliedMessage.messageType == 'product_attachment') {
      return 'order_details'.tr;
    } else if (repliedMessage.senderType == 'customer') {
      return 'you'.tr;
    } else if (repliedMessage.senderType == 'merchant') {
      return 'restaurant'.tr;
    } else {
      return 'system'.tr;
    }
  }

  String _getMessagePreview() {
    if (repliedMessage.messageType == 'product_attachment') {
      // Extract order info from attachments
      final attachments = repliedMessage.attachments;
      if (attachments != null) {
        final items = attachments['items'] as List?;
        final totalAmount = attachments['total_amount'];
        final itemCount = attachments['item_count'] ?? items?.length ?? 0;

        if (totalAmount != null) {
          return '$itemCount ${'items'.tr} - $totalAmount ${'sar'.tr}';
        }
      }
      return repliedMessage.message;
    }
    return repliedMessage.message;
  }
}

