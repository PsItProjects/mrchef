import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_conversations_controller.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cached_network_image/cached_network_image.dart';

class MerchantMessagesScreen extends GetView<MerchantConversationsController> {
  const MerchantMessagesScreen({super.key});

  bool get _isArabic => TranslationHelper.isArabic;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MerchantConversationsController>()) {
      Get.put(MerchantConversationsController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'conversations'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textDarkColor,
              ),
            ),
            Obx(() {
              final count = controller.conversations.length;
              if (count == 0) return const SizedBox.shrink();
              return Text(
                '$count ${_isArabic ? 'محادثة' : 'chats'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              );
            }),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 0.5,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Conversations list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (controller.conversations.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshConversations,
                color: AppColors.primaryColor,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = controller.conversations[index];
                    return _buildConversationItem(conversation);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              _isArabic ? 'بحث...' : 'Search...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'no_conversations'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDarkColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'no_conversations_description'.tr,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(ConversationModel conversation) {
    final customerName = conversation.customer.name;
    final hasUnread = conversation.unreadCount > 0;

    return Column(
      children: [
        InkWell(
          onTap: () => controller.openConversation(conversation),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(conversation),

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
                              customerName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
                              _getDisplayMessage(conversation),
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

  Widget _buildAvatar(ConversationModel conversation) {
    final customerName = conversation.customer.name;
    final avatarUrl = conversation.customer.avatar;
    final firstLetter =
        customerName.isNotEmpty ? customerName[0].toUpperCase() : '?';

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
      ),
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                firstLetter,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
    );
  }

  String _getDisplayMessage(ConversationModel conversation) {
    final lastMsg = conversation.lastMessage;
    if (lastMsg == null || lastMsg.message.isEmpty) {
      if (lastMsg?.messageType == 'product_attachment') {
        return _isArabic ? '📦 طلب جديد' : '📦 New order';
      }
      if (lastMsg?.messageType == 'image') {
        return _isArabic ? '📷 صورة' : '📷 Photo';
      }
      return _isArabic ? 'بدء المحادثة' : 'Start conversation';
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
      final dayNames = _isArabic
          ? [
              'الأحد',
              'الإثنين',
              'الثلاثاء',
              'الأربعاء',
              'الخميس',
              'الجمعة',
              'السبت'
            ]
          : [
              'Sunday',
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday'
            ];
      return dayNames[dateTime.weekday % 7];
    } else {
      return intl.DateFormat('dd/MM').format(dateTime);
    }
  }
}
