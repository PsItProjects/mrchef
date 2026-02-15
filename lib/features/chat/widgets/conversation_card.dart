import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:intl/intl.dart' as intl;

class ConversationCard extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(hasUnread),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + time row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.restaurant.businessName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    hasUnread ? FontWeight.w700 : FontWeight.w500,
                                color: AppColors.textDarkColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.lastMessageAt != null)
                            Text(
                              _formatTime(conversation.lastMessageAt!),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    hasUnread ? FontWeight.w600 : FontWeight.w400,
                                color: hasUnread
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Last message + unread badge
                      Row(
                        children: [
                          // Message type icon
                          if (conversation.lastMessage?.messageType ==
                              'product_attachment')
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.receipt_rounded,
                                  size: 15, color: Colors.grey.shade400),
                            )
                          else if (conversation.lastMessage?.messageType ==
                              'image')
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.image_rounded,
                                  size: 15, color: Colors.grey.shade400),
                            ),

                          Expanded(
                            child: Text(
                              _getDisplayMessage(),
                              style: TextStyle(
                                fontSize: 14,
                                color: hasUnread
                                    ? AppColors.textDarkColor
                                    : Colors.grey.shade500,
                                fontWeight: hasUnread
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Unread badge
                          if (hasUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              constraints: const BoxConstraints(
                                  minWidth: 20, minHeight: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  conversation.unreadCount > 99
                                      ? '99+'
                                      : conversation.unreadCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider aligned with text (after avatar)
        Padding(
          padding: const EdgeInsets.only(left: 78, right: 16),
          child: Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade200),
        ),
      ],
    );
  }

  Widget _buildAvatar(bool hasUnread) {
    final logo = conversation.restaurant.logo;
    final name = conversation.restaurant.businessName;
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
      ),
      child: logo != null && logo.isNotEmpty
          ? ClipOval(
              child: Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                firstLetter,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
    );
  }

  String _getDisplayMessage() {
    final lastMsg = conversation.lastMessage;
    if (lastMsg == null || lastMsg.message.isEmpty) {
      if (lastMsg?.messageType == 'product_attachment') {
        return _isArabic ? '📦 طلب جديد' : '📦 New order';
      }
      if (lastMsg?.messageType == 'image') {
        return _isArabic ? '📷 صورة' : '📷 Photo';
      }
      return _isArabic ? 'ابدأ المحادثة' : 'Start conversation';
    }
    return lastMsg.message;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return intl.DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return _isArabic ? 'أمس' : 'Yesterday';
    } else if (difference.inDays < 7) {
      const arabicDays = [
        'الاثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
        'الأحد',
      ];
      const englishDays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final dayIndex = dateTime.weekday - 1;
      return _isArabic ? arabicDays[dayIndex] : englishDays[dayIndex];
    } else {
      return intl.DateFormat('dd/MM').format(dateTime);
    }
  }
}

