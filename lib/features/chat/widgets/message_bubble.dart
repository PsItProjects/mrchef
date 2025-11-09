import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_colors.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:intl/intl.dart' as intl;

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isFromCustomer = message.isFromCustomer;
    final isArabic = Get.locale?.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isFromCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isFromCustomer
                  ? AppColors.primaryColor
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isFromCustomer
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isFromCustomer
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message text
                Text(
                  message.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isFromCustomer
                        ? const Color(0xFF262626)
                        : const Color(0xFF262626),
                  ),
                ),

                const SizedBox(height: 4),

                // Time
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isFromCustomer
                        ? const Color(0xFF262626).withOpacity(0.6)
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return intl.DateFormat('HH:mm').format(dateTime);
  }
}

