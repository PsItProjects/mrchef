import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/support/controllers/support_ticket_detail_controller.dart';

class SupportTicketDetailScreen extends GetView<SupportTicketDetailController> {
  const SupportTicketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = (Get.locale?.languageCode ?? 'ar') == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text('ticket'.tr),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF262626),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadTicket,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadTicket,
                color: AppColors.primaryColor,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final m = controller.messages[index];
                    final senderType = (m['sender_type'] ?? '').toString();
                    final text = (m['message'] ?? '').toString();
                    final isMe = senderType != 'admin';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primaryColor.withOpacity(0.12) : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(text),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          _buildInput(isArabic),
        ],
      ),
    );
  }

  Widget _buildInput(bool isArabic) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, -2)),
        ]),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: 'type_message'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: controller.sendMessage,
              icon: const Icon(Icons.send, color: AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
