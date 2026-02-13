import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/chat/controllers/conversations_controller.dart';
import 'package:mrsheaf/features/chat/widgets/conversation_card.dart';
import 'package:mrsheaf/features/home/controllers/main_controller.dart';

class ConversationsScreen extends GetView<ConversationsController> {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
            size: 20,
            color: AppColors.textDarkColor,
          ),
          onPressed: () {
            Get.offAllNamed('/home');
            Future.delayed(const Duration(milliseconds: 100), () {
              try {
                final mainController = Get.find<MainController>();
                mainController.changeTab(4);
              } catch (_) {}
            });
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'المحادثات' : 'Conversations',
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
                '$count ${isArabic ? 'محادثة' : 'chats'}',
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
          _buildSearchBar(isArabic),

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
                  padding: EdgeInsets.zero,
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
    );
  }

  Widget _buildSearchBar(bool isArabic) {
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
              isArabic ? 'بحث...' : 'Search...',
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

  Widget _buildEmptyState(bool isArabic) {
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
              isArabic ? 'لا توجد محادثات بعد' : 'No conversations yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDarkColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isArabic
                  ? 'ابدأ بطلب منتج من أحد المتاجر'
                  : 'Start ordering from a store',
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
}

