import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/chat/widgets/message_reply_preview.dart';
import 'package:intl/intl.dart' as intl;

/// WhatsApp / Messenger–style message bubble with clear visual distinction
/// between customer (right, colored) and merchant (left, white) messages.
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final Function(int messageId)? onReplyTap;
  final String? merchantName;

  // Customer bubble colour palette
  static const _customerBubbleColor = Color(0xFFDCF8C6); // WhatsApp green-ish
  static const _merchantBubbleColor = Colors.white;

  const MessageBubble({
    super.key,
    required this.message,
    this.onReplyTap,
    this.merchantName,
  });

  @override
  Widget build(BuildContext context) {
    final isFromCustomer = message.isFromCustomer;
    final isSystem = message.senderType == 'system';

    if (isSystem) return _buildSystemBubble();

    final bubbleColor =
        isFromCustomer ? _customerBubbleColor : _merchantBubbleColor;

    // Tail direction depends on sender
    final borderRadius = isFromCustomer
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isFromCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Merchant avatar (left side)
          if (!isFromCustomer) ...[
            _merchantAvatar(),
            const SizedBox(width: 6),
          ],

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82,
              ),
              margin: EdgeInsets.only(
                left: isFromCustomer ? 16 : 0,
                right: isFromCustomer ? 0 : 16,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: _buildBubbleContent(context, isFromCustomer),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  System message (centered pill)
  // ══════════════════════════════════════════════════════════
  Widget _buildSystemBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE2DEDE).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B6B6B),
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  Bubble inner content
  // ══════════════════════════════════════════════════════════
  Widget _buildBubbleContent(BuildContext context, bool isFromCustomer) {
    final hasImage =
        message.messageType == 'image' && message.attachments != null;
    final hasText = message.message.isNotEmpty;

    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Merchant name label
          if (!isFromCustomer && merchantName != null && merchantName!.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                merchantName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),

          // Reply preview
          if (message.repliedToMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: MessageReplyPreview(
                repliedMessage: message.repliedToMessage!,
                onTap: () {
                  if (onReplyTap != null &&
                      message.repliedToMessageId != null) {
                    onReplyTap!(message.repliedToMessageId!);
                  }
                },
              ),
            ),

          // Image
          if (hasImage) _buildImageContent(context, isFromCustomer),

          // Text + time row
          Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              hasImage ? 4 : (message.repliedToMessage != null ? 4 : 8),
              12,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasText)
                  Text(
                    message.message,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1B1B1B),
                      height: 1.35,
                    ),
                  ),
                const SizedBox(height: 3),
                // Time + read receipt aligned bottom-right
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (isFromCustomer) ...[
                      const SizedBox(width: 3),
                      Icon(
                        Icons.done_all_rounded,
                        size: 14,
                        color: message.isReadByMerchant == true
                            ? AppColors.primaryColor
                            : Colors.grey.shade400,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  Image content
  // ══════════════════════════════════════════════════════════
  Widget _buildImageContent(BuildContext context, bool isFromCustomer) {
    final imageData = message.attachments?['image'];
    if (imageData == null) return const SizedBox.shrink();
    final imageUrl = imageData['url'] as String?;
    if (imageUrl == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageUrl),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260, maxHeight: 320),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 220,
                  height: 160,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                width: 220,
                height: 160,
                color: Colors.grey.shade100,
                child: const Icon(Icons.broken_image_rounded,
                    color: Colors.grey, size: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  Merchant avatar
  // ══════════════════════════════════════════════════════════
  Widget _merchantAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondaryColor.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.secondaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(
        Icons.storefront_rounded,
        size: 14,
        color: AppColors.secondaryColor,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  Full-screen image viewer
  // ══════════════════════════════════════════════════════════
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black87),
            ),
            InteractiveViewer(
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon:
                    const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return intl.DateFormat('HH:mm').format(dateTime);
  }
}

