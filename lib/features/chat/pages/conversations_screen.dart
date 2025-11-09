import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_colors.dart';
import 'package:mrsheaf/features/chat/controllers/conversations_controller.dart';
import 'package:mrsheaf/features/chat/widgets/conversation_card.dart';
import 'package:intl/intl.dart' as intl;

class ConversationsScreen extends GetView<ConversationsController> {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isArabic),

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
                  return _buildEmptyState(isArabic);
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshConversations,
                  color: AppColors.primaryColor,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: controller.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = controller.conversations[index];
                      return ConversationCard(
                        conversation: conversation,
                        onTap: () => controller.openConversation(conversation),
                      );
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              size: 20,
              color: const Color(0xFF262626),
            ),
          ),

          // Title
          Text(
            isArabic ? 'المحادثات' : 'Conversations',
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),

          // Unread count badge
          Obx(() {
            final unreadCount = controller.totalUnreadCount;
            if (unreadCount == 0) {
              return const SizedBox(width: 24);
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
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
            isArabic ? 'لا توجد محادثات' : 'No conversations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'ابدأ بطلب منتج من أحد المطاعم'
                : 'Start by ordering a product from a restaurant',
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
}

