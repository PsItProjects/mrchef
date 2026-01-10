import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/support/controllers/support_ticket_detail_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class SupportTicketDetailScreen extends GetView<SupportTicketDetailController> {
  const SupportTicketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = (Get.locale?.languageCode ?? 'ar') == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'ticket'.tr} #${controller.ticketId}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getStatusText(controller.ticket['status']?.toString() ?? ''),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(controller.ticket['status']?.toString() ?? ''),
                  ),
                ),
              ],
            )),
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
          // Ticket info header
          Obx(() {
            final subject = controller.ticket['subject']?.toString() ?? '';
            if (subject.isNotEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Text('no_messages'.tr, style: TextStyle(color: Colors.grey[600])),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadTicket,
                color: AppColors.primaryColor,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) => _buildMessageBubble(
                    controller.messages[index],
                    isArabic,
                  ),
                ),
              );
            }),
          ),
          // Closed ticket banner
          Obx(() {
            if (controller.ticket['status'] == 'closed') {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey[200],
                child: Text(
                  'ticket_closed'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }
            return _buildInput(isArabic);
          }),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> m, bool isArabic) {
    final senderType = (m['sender_type'] ?? '').toString();
    final text = (m['message'] ?? '').toString();
    final createdAt = m['created_at']?.toString() ?? '';
    final messageType = (m['type'] ?? 'text').toString();
    final imageUrl = m['image']?.toString();
    final attachments = m['attachments'];
    final isMe = senderType != 'admin' && senderType != 'system';
    final isSystem = senderType == 'system' || messageType == 'system';

    // Parse date
    String timeStr = '';
    try {
      if (createdAt.isNotEmpty) {
        final dt = DateTime.parse(createdAt).toLocal();
        timeStr = DateFormat('HH:mm').format(dt);
      }
    } catch (_) {}

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue[700], fontSize: 12),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryColor.withOpacity(0.15) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin label
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'support_team'.tr,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // Image from type=image field
                  if (messageType == 'image' && imageUrl != null && imageUrl.isNotEmpty)
                    _buildImageFromUrl(imageUrl),
                  // Image from attachments (legacy support)
                  if (attachments != null && attachments is Map && attachments['image'] != null)
                    _buildImageAttachment(attachments['image']),
                  // Message text
                  if (text.isNotEmpty)
                    Text(
                      text,
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
            ),
            // Time
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(
                timeStr,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFromUrl(String url) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(url),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageAttachment(dynamic imageData) {
    String? url;
    if (imageData is Map) {
      url = imageData['url']?.toString();
    }
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showFullScreenImage(url!),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(bool isArabic) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image preview
          Obx(() {
            if (controller.selectedImage.value != null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
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
                    Expanded(
                      child: Text(
                        'image_attached'.tr,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.clearSelectedImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.close, color: Colors.red[400], size: 18),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image picker button
                Obx(() => GestureDetector(
                      onTap: controller.isUploading.value ? null : controller.showImagePicker,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: controller.isUploading.value
                              ? Colors.grey[300]
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: controller.isUploading.value
                            ? const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : Icon(Icons.camera_alt, color: Colors.grey[600], size: 22),
                      ),
                    )),
                const SizedBox(width: 8),
                // Text field
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'type_message'.tr,
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                Obx(() {
                  final isBusy = controller.isLoading.value || controller.isUploading.value;
                  return GestureDetector(
                    onTap: isBusy ? null : controller.sendMessage,
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
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send, color: Color(0xFF262626), size: 20),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'status_open'.tr;
      case 'in_progress':
        return 'status_in_progress'.tr;
      case 'closed':
        return 'status_closed'.tr;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
