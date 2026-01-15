import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/shared/widgets/add_review_bottom_sheet.dart';

/// Order Review Prompt Dialog shown after order is delivered
class OrderReviewPromptDialog extends StatelessWidget {
  final String orderNumber;
  final List<OrderItemToReview> items;
  final VoidCallback? onLater;
  final Future<void> Function(int productId, int rating, String comment, List<String>? images)? onReview;

  const OrderReviewPromptDialog({
    super.key,
    required this.orderNumber,
    required this.items,
    this.onLater,
    this.onReview,
  });

  /// Show the dialog
  static Future<void> show({
    required String orderNumber,
    required List<OrderItemToReview> items,
    VoidCallback? onLater,
    Future<void> Function(int productId, int rating, String comment, List<String>? images)? onReview,
  }) {
    return Get.dialog(
      OrderReviewPromptDialog(
        orderNumber: orderNumber,
        items: items,
        onLater: onLater,
        onReview: onReview,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.successColor,
                size: 48,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              'order_delivered'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Color(0xFF262626),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'how_was_your_order'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF999999),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Items to review (show first 3)
            if (items.isNotEmpty) ...[
              ...items.take(3).map((item) => _buildItemPreview(item)),
              if (items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${items.length - 3} ${'more_items'.tr}',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
            
            // Rate Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  _showReviewFlow();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'rate_order'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Later button
            TextButton(
              onPressed: () {
                Get.back();
                onLater?.call();
              },
              child: Text(
                'later'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPreview(OrderItemToReview item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Product image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF5F5F5),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fastfood_rounded,
                      color: Color(0xFFBDBDBD),
                      size: 24,
                    ),
                  )
                : const Icon(
                    Icons.fastfood_rounded,
                    color: Color(0xFFBDBDBD),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          
          // Product name
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF262626),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Review status
          if (item.isReviewed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check,
                    color: AppColors.successColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'reviewed'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.successColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showReviewFlow() {
    // Show review for the first unreviewed item
    final unreviewedItems = items.where((item) => !item.isReviewed).toList();
    
    if (unreviewedItems.isEmpty) {
      Get.snackbar(
        'info'.tr,
        'all_items_reviewed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _showReviewForItem(unreviewedItems.first, 0, unreviewedItems.length);
  }

  void _showReviewForItem(OrderItemToReview item, int currentIndex, int totalCount) {
    AddReviewBottomSheet.show(
      productId: item.productId,
      productName: item.name,
      productImage: item.imageUrl,
      onSubmit: (rating, comment, images) async {
        try {
          await onReview?.call(item.productId, rating, comment, images);
          
          // Show next item if there are more
          final unreviewedItems = items.where((i) => !i.isReviewed && i.productId != item.productId).toList();
          if (unreviewedItems.isNotEmpty && currentIndex + 1 < totalCount) {
            // Ask if user wants to review next item
            await Future.delayed(const Duration(milliseconds: 500));
            _showNextItemPrompt(unreviewedItems.first, currentIndex + 1, totalCount);
          }
          
          return true;
        } catch (e) {
          return false;
        }
      },
    );
  }

  void _showNextItemPrompt(OrderItemToReview nextItem, int currentIndex, int totalCount) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'review_next_item'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          '${'would_you_like_to_review'.tr} "${nextItem.name}"?',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'no_thanks'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                color: Color(0xFF999999),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showReviewForItem(nextItem, currentIndex, totalCount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'yes'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Model for items that can be reviewed
class OrderItemToReview {
  final int productId;
  final String name;
  final String? imageUrl;
  final bool isReviewed;

  OrderItemToReview({
    required this.productId,
    required this.name,
    this.imageUrl,
    this.isReviewed = false,
  });
}

/// Simple button widget to add to order details for reviewing
class ReviewOrderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCompact;

  const ReviewOrderButton({
    super.key,
    required this.onPressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        icon: const Icon(Icons.star_rounded, size: 18),
        label: Text('rate_order'.tr),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        icon: const Icon(Icons.star_rounded),
        label: Text(
          'rate_order'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
