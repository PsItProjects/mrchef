import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_chat_controller.dart';
import 'package:mrsheaf/features/merchant/widgets/merchant_product_attachment_card.dart';
import 'package:mrsheaf/features/chat/widgets/message_bubble.dart';
import 'package:mrsheaf/features/support/widgets/report_conversation_dialog.dart';

class MerchantChatScreen extends GetView<MerchantChatController> {
  const MerchantChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }

              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshMessages,
                color: AppColors.primaryColor,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    final messageKey = controller.messageKeys[message.id];

                    // Check if this is a product attachment message
                    if (message.messageType == 'product_attachment' &&
                        message.attachments != null) {
                      return Container(
                        key: messageKey,
                        child: Column(
                          children: [
                            // Product attachment card with approve/reject buttons
                            Obx(() {
                              // Get orderId from attachments
                              final orderId = message.attachments!['order_id'];
                              return MerchantProductAttachmentCard(
                                attachments: message.attachments!,
                                orderData: orderId != null
                                    ? controller.ordersData[orderId]
                                    : controller.orderData.value,
                                canApprove:
                                    true, // Always show buttons if pending
                                isUpdating: orderId != null
                                    ? controller.isOrderUpdating(orderId)
                                    : false,
                                onOrderStatusChange: (id, status,
                                    {double? agreedPrice}) {
                                  controller.updateOrderStatusById(
                                    id,
                                    status,
                                    agreedPrice: agreedPrice,
                                  );
                                },
                              );
                            }),
                            const SizedBox(height: 8),
                            // Message bubble
                            Obx(() => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: controller
                                                .highlightedMessageId.value ==
                                            message.id
                                        ? AppColors.primaryColor.withAlpha(51)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: MessageBubble(
                                    message: message,
                                    onReplyTap: controller.scrollToMessage,
                                  ),
                                )),
                          ],
                        ),
                      );
                    }

                    // Regular message
                    return Container(
                      key: messageKey,
                      child: Obx(() => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: controller.highlightedMessageId.value ==
                                      message.id
                                  ? AppColors.primaryColor.withAlpha(51)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: MessageBubble(
                              message: message,
                              onReplyTap: controller.scrollToMessage,
                            ),
                          )),
                    );
                  },
                ),
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          TranslationHelper.isRTL
              ? Icons.arrow_forward_ios
              : Icons.arrow_back_ios,
          color: const Color(0xFF262626),
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final conv = controller.conversation.value;
        final customerName = controller.customerName ??
            conv?.customer.name ??
            TranslationHelper.tr('customer');
        final customerAvatar =
            controller.customerAvatar ?? conv?.customer.avatar;

        return Row(
          children: [
            _buildCustomerAvatar(customerName, customerAvatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF262626),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (controller.customerPhone != null)
                    Text(
                      controller.customerPhone!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.flag_outlined, color: Color(0xFF262626)),
          onPressed: _showReportDialog,
          tooltip: 'report'.tr,
        ),
      ],
    );
  }

  void _showReportDialog() {
    Get.dialog(
      ReportConversationDialog(
        onSubmit: (reason, details) => controller.reportConversation(
          reason: reason,
          details: details,
        ),
      ),
    );
  }

  Widget _buildCustomerAvatar(String name, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.primaryColor.withAlpha(51), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.primaryColor.withAlpha(26),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.primaryColor.withAlpha(26),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fallback to first letter
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            TranslationHelper.tr('no_messages'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller.messageController,
                textDirection: TranslationHelper.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: TranslationHelper.tr('type_message'),
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => GestureDetector(
                onTap:
                    controller.isSending.value ? null : controller.sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: controller.isSending.value
                        ? Colors.grey[400]
                        : AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: controller.isSending.value
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : const Icon(Icons.send,
                          color: Color(0xFF262626), size: 20),
                ),
              )),
        ],
      ),
    );
  }
}
