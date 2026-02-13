import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/chat/controllers/chat_controller.dart';
import 'package:mrsheaf/features/chat/widgets/message_bubble.dart';
import 'package:mrsheaf/features/chat/widgets/customer_product_attachment_card.dart';
import 'package:mrsheaf/features/support/widgets/report_conversation_dialog.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp-style beige bg
      appBar: _buildAppBar(isArabic),
      body: Column(
        children: [
          // Messages list with chat wallpaper pattern
          Expanded(
            child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (controller.messages.isEmpty) {
                  return _buildEmptyState(isArabic);
                }

                // Resolve merchant name once for all bubbles
                final merchantName =
                    controller.conversation.value?.restaurant.businessName;

                return RefreshIndicator(
                  onRefresh: controller.refreshMessages,
                  color: AppColors.primaryColor,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      final messageKey =
                          controller.messageKeys[message.id];

                      Widget messageWidget;

                      // Product attachment → use new professional card
                      if (message.messageType == 'product_attachment' &&
                          message.attachments != null) {
                        final orderId = message.attachments?['order_id'];

                        messageWidget = Column(
                          children: [
                            // Order card wrapped in Obx so it updates when ordersData changes
                            Obx(() {
                              final oData = orderId != null
                                  ? controller.ordersData[orderId]
                                  : null;
                              final isConfirming = orderId != null
                                  ? controller
                                      .isOrderConfirming(orderId)
                                  : false;

                              return CustomerProductAttachmentCard(
                                attachments: message.attachments!,
                                orderData: oData,
                                isConfirming: isConfirming,
                                onConfirmDelivery: (id) =>
                                    controller.confirmDelivery(id),
                              );
                            }),
                            const SizedBox(height: 4),
                            // Original message bubble underneath
                            Obx(() => AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: controller.highlightedMessageId
                                                .value ==
                                            message.id
                                        ? AppColors.primaryColor
                                            .withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: MessageBubble(
                                    message: message,
                                    onReplyTap:
                                        controller.scrollToMessage,
                                    merchantName: message.isFromMerchant
                                        ? merchantName
                                        : null,
                                  ),
                                )),
                          ],
                        );
                      } else {
                        // Regular message bubble
                        messageWidget = Obx(() => AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: controller.highlightedMessageId
                                            .value ==
                                        message.id
                                    ? AppColors.primaryColor
                                        .withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: MessageBubble(
                                message: message,
                                onReplyTap:
                                    controller.scrollToMessage,
                                merchantName: message.isFromMerchant
                                    ? merchantName
                                    : null,
                              ),
                            ));
                      }

                      return Container(
                        key: messageKey,
                        child: messageWidget,
                      );
                    },
                  ),
                );
              }),
            ),

          // Message input
          _buildMessageInput(isArabic),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isArabic) {
    return AppBar(
      backgroundColor: AppColors.secondaryColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Get.offAllNamed('/conversations'),
      ),
      title: Obx(() {
        final conv = controller.conversation.value;
        if (conv == null) return const SizedBox.shrink();

        return Row(
          children: [
            // Restaurant avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: conv.restaurant.logo != null &&
                        conv.restaurant.logo!.isNotEmpty
                    ? Image.network(
                        conv.restaurant.logo!,
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholderLogo(),
                      )
                    : _buildPlaceholderLogo(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.restaurant.businessName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conv.conversationType == 'order_chat')
                    Text(
                      isArabic ? 'متصل • طلب' : 'Online • Order',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
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

  Widget _buildPlaceholderLogo() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.storefront_rounded,
        size: 20,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_messages'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isArabic ? 'ابدأ المحادثة الآن' : 'Start the conversation',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isArabic) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image preview when selected
        Obx(() {
          if (controller.selectedImage.value != null) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      controller.selectedImage.value!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'image_attached'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.clearSelectedImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.red.shade400,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Input bar — WhatsApp style
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF0F0F0),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Camera / image button
                Obx(() {
                  return GestureDetector(
                    onTap: controller.isUploadingImage.value
                        ? null
                        : controller.showImagePicker,
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        color: controller.isUploadingImage.value
                            ? Colors.grey.shade300
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: controller.isUploadingImage.value
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryColor),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.grey.shade600,
                              size: 21,
                            ),
                    ),
                  );
                }),

                const SizedBox(width: 6),

                // Text field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: 'type_message'.tr,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (controller.selectedImage.value != null) {
                          controller.sendSelectedImage();
                        } else {
                          controller.sendMessage();
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Send button
                Obx(() {
                  final isBusy = controller.isSending.value ||
                      controller.isUploadingImage.value;
                  final hasImage = controller.selectedImage.value != null;
                  return GestureDetector(
                    onTap: isBusy
                        ? null
                        : () {
                            if (hasImage) {
                              controller.sendSelectedImage();
                            } else {
                              controller.sendMessage();
                            }
                          },
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(bottom: 0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isBusy
                              ? [Colors.grey.shade400, Colors.grey.shade400]
                              : [
                                  AppColors.secondaryColor,
                                  AppColors.secondaryColor.withValues(alpha: 0.85),
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: isBusy
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.secondaryColor
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: isBusy
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              ),
                            )
                          : Icon(
                              hasImage ? Icons.image : Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

