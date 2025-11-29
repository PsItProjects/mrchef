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

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already registered
    if (!Get.isRegistered<MerchantConversationsController>()) {
      Get.put(MerchantConversationsController());
    }

    final isArabic = TranslationHelper.isArabic;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isArabic),

            // Messages List
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
                  return _buildEmptyState(isArabic);
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshConversations,
                  color: AppColors.primaryColor,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = controller.conversations[index];
                      return _buildConversationCard(conversation, isArabic);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'conversations'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
          const Spacer(),
          Obx(() {
            final unreadCount = controller.totalUnreadCount;
            if (unreadCount > 0) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isArabic
                      ? '$unreadCount ${'new_messages'.tr}'
                      : '$unreadCount ${'new_messages'.tr}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_conversations'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_conversations_description'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(ConversationModel conversation, bool isArabic) {
    final customerName = conversation.customer.name;
    final lastMessage = conversation.lastMessage?.message ?? '';
    final hasUnread = conversation.unreadCount > 0;
    final orderNumber =
        conversation.orderId != null ? '#${conversation.orderId}' : null;

    return GestureDetector(
      onTap: () => controller.openConversation(conversation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(conversation, hasUnread),

              const SizedBox(width: 12),

              // Conversation details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and time row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            customerName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Order number badge
                    if (orderNumber != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isArabic ? 'طلب $orderNumber' : 'Order $orderNumber',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 5),

                    // Last message
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getDisplayMessage(lastMessage, conversation),
                            style: TextStyle(
                              fontSize: 14,
                              color: hasUnread
                                  ? AppColors.textDarkColor
                                  : Colors.grey[600],
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Unread badge
                        if (hasUnread)
                          Container(
                            margin: EdgeInsets.only(
                              left: isArabic ? 0 : 8,
                              right: isArabic ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : conversation.unreadCount.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ConversationModel conversation, bool hasUnread) {
    final customerName = conversation.customer.name;
    final avatarUrl = conversation.customer.avatar;
    final firstLetter = customerName.isNotEmpty ? customerName[0] : '?';

    return Stack(
      children: [
        // Avatar circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor,
          ),
          child: avatarUrl != null && avatarUrl.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: Text(
                        firstLetter.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Text(
                        firstLetter.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    firstLetter.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
        ),

        // Unread indicator
        if (hasUnread)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  String _getDisplayMessage(String message, ConversationModel conversation) {
    if (message.isEmpty) {
      // Check if it's a product attachment message
      if (conversation.lastMessage?.messageType == 'product_attachment') {
        return TranslationHelper.isArabic ? 'طلب جديد' : 'New order';
      }
      return TranslationHelper.isArabic ? 'بدء المحادثة' : 'Start conversation';
    }
    return message;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final isArabic = TranslationHelper.isArabic;

    if (difference.inDays == 0) {
      // Today: show time
      return intl.DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return isArabic ? 'أمس' : 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week: show day name in Arabic or English
      final dayNames = isArabic
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
      // Older: show date
      return intl.DateFormat('dd/MM').format(dateTime);
    }
  }
}
