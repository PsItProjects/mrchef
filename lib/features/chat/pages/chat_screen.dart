import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/chat/controllers/chat_controller.dart';
import 'package:mrsheaf/features/chat/widgets/message_bubble.dart';
import 'package:mrsheaf/features/chat/widgets/product_attachment_card.dart';
import 'package:mrsheaf/features/support/widgets/report_conversation_dialog.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(isArabic),
      body: Column(
        children: [
          // Messages list
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

              return RefreshIndicator(
                onRefresh: controller.refreshMessages,
                color: AppColors.primaryColor,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    final messageKey = controller.messageKeys[message.id];

                    // Wrap message in Container with key for scrolling
                    Widget messageWidget;

                    // Show product attachment card for any message with product_attachment type
                    if (message.messageType == 'product_attachment' &&
                        message.attachments != null) {
                      messageWidget = Column(
                        children: [
                          ProductAttachmentCard(
                            attachments: message.attachments!,
                          ),
                          const SizedBox(height: 8),
                          Obx(() => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: controller.highlightedMessageId.value == message.id
                                      ? AppColors.primaryColor.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: MessageBubble(
                                  message: message,
                                  onReplyTap: controller.scrollToMessage,
                                ),
                              )),
                        ],
                      );
                    } else {
                      // Regular message bubble with highlight animation
                      messageWidget = Obx(() => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: controller.highlightedMessageId.value == message.id
                                  ? AppColors.primaryColor.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: MessageBubble(
                              message: message,
                              onReplyTap: controller.scrollToMessage,
                            ),
                          ));
                    }

                    // Wrap with key for scrolling
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
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          color: const Color(0xFF262626),
          size: 20,
        ),
        onPressed: () => Get.offAllNamed('/conversations'),
      ),
      title: Obx(() {
        final conv = controller.conversation.value;
        if (conv == null) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            // Restaurant logo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: conv.restaurant.logo != null && conv.restaurant.logo!.isNotEmpty
                  ? Image.network(
                      conv.restaurant.logo!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderLogo();
                      },
                    )
                  : _buildPlaceholderLogo(),
            ),

            const SizedBox(width: 12),

            // Restaurant name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.restaurant.businessName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF262626),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conv.conversationType == 'order_chat')
                    Text(
                      isArabic ? 'طلب' : 'Order',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
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

  Widget _buildPlaceholderLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.restaurant,
        size: 20,
        color: AppColors.primaryColor,
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
            'no_messages'.tr,
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
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      controller.selectedImage.value!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Image info
                  Expanded(
                    child: Text(
                      'image_attached'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  // Remove button
                  GestureDetector(
                    onTap: controller.clearSelectedImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.red[400],
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
        // Message input area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image picker button
              Obx(() {
                return GestureDetector(
                  onTap: controller.isUploadingImage.value ? null : controller.showImagePicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: controller.isUploadingImage.value
                          ? Colors.grey[300]
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: controller.isUploadingImage.value
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.grey[600],
                            size: 22,
                          ),
                  ),
                );
              }),

              const SizedBox(width: 8),

              // Text input
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'type_message'.tr,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
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

              const SizedBox(width: 12),

              // Send button
              Obx(() {
                final isBusy = controller.isSending.value || controller.isUploadingImage.value;
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
                    decoration: BoxDecoration(
                      color: isBusy ? Colors.grey[400] : AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: isBusy
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Icon(
                            hasImage ? Icons.image : Icons.send,
                            color: const Color(0xFF262626),
                            size: 20,
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

