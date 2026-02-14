import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/order_details_model.dart';
import 'package:mrsheaf/features/profile/models/order_model.dart';
import 'package:mrsheaf/features/profile/controllers/order_details_controller.dart';
import 'package:mrsheaf/shared/widgets/order_review_widgets.dart';

class OrderActionsBar extends StatelessWidget {
  final OrderDetailsModel order;

  const OrderActionsBar({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Get controller explicitly
    final controller = Get.find<OrderDetailsController>();
    final isCompleted = order.status == OrderStatus.completed;
    final isAwaitingConfirmation = order.status == OrderStatus.delivered;
    final isAwaitingPriceApproval = order.status == OrderStatus.awaitingCustomerApproval;
    final canCancel = order.status == OrderStatus.pending || 
                      order.status == OrderStatus.confirmed ||
                      order.status == OrderStatus.awaitingCustomerApproval;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Accept/Reject price buttons (only for awaiting_customer_approval orders)
            if (isAwaitingPriceApproval) ...[
              // Price summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.price_check_rounded, color: AppColors.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'price_proposal_pending'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Accept button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAcceptPriceDialog(context, controller),
                        icon: const Icon(Icons.check_circle_outline, size: 22),
                        label: Text(
                          'accept_price'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Reject button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => _showRejectPriceDialog(context, controller),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorColor,
                          side: const BorderSide(color: AppColors.errorColor, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'reject'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // Confirm Delivery button (only for delivered/awaiting confirmation orders)
            if (isAwaitingConfirmation) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showConfirmDeliveryDialog(context, controller),
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  label: Text(
                    'confirm_delivery'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Rate Order button (only for completed orders)
            if (isCompleted) ...[
              Obx(() {
                // Check if all products in this order have been reviewed
                final allReviewed = order.items.every((item) =>
                  controller.reviewedProducts[item.productId] ?? false
                );

                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: allReviewed ? null : () => _showReviewDialog(context, controller),
                    icon: Icon(
                      allReviewed ? Icons.check_circle : Icons.star_rounded,
                      size: 22,
                    ),
                    label: Text(
                      allReviewed ? 'order_reviewed'.tr : 'rate_order'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allReviewed
                        ? AppColors.successColor
                        : AppColors.primaryColor,
                      foregroundColor: AppColors.secondaryColor,
                      disabledBackgroundColor: AppColors.successColor,
                      disabledForegroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
            
            Row(
              children: [
                // Chat button
                Expanded(
                  flex: canCancel ? 1 : 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.openChat();
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 20),
                      label: Text(
                        'chat_with_restaurant'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isCompleted || isAwaitingConfirmation) 
                            ? AppColors.secondaryColor.withOpacity(0.1)
                            : AppColors.primaryColor,
                        foregroundColor: (isCompleted || isAwaitingConfirmation)
                            ? AppColors.secondaryColor
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),

                // Cancel button (only for pending/confirmed orders)
                if (canCancel) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorColor,
                        side: const BorderSide(color: AppColors.errorColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'cancel_order'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showConfirmDeliveryDialog(BuildContext context, OrderDetailsController controller) {
    HapticFeedback.lightImpact();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'confirm_delivery'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'confirm_delivery_message'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Lato',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.confirmDelivery();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'confirm'.tr,
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
  
  void _showReviewDialog(BuildContext context, OrderDetailsController controller) {
    HapticFeedback.lightImpact();

    // Convert order items to reviewable items
    final itemsToReview = order.items.map((item) => OrderItemToReview(
      productId: item.productId,
      name: item.productName,
      imageUrl: item.productImage,
      isReviewed: controller.reviewedProducts[item.productId] ?? false,
    )).toList();

    OrderReviewPromptDialog.show(
      orderNumber: order.orderNumber,
      items: itemsToReview,
      onLater: () {
        // User chose to review later
      },
      onReview: (productId, rating, comment, images) async {
        await controller.submitProductReview(
          productId: productId,
          rating: rating,
          comment: comment,
          images: images,
        );
      },
    );
  }

  void _showAcceptPriceDialog(BuildContext context, OrderDetailsController controller) {
    HapticFeedback.lightImpact();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'accept_price'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'accept_price_confirmation'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Lato',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.acceptPrice();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'confirm'.tr,
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

  void _showRejectPriceDialog(BuildContext context, OrderDetailsController controller) {
    HapticFeedback.lightImpact();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'reject_price'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            color: AppColors.errorColor,
          ),
        ),
        content: Text(
          'reject_price_confirmation'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Lato',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.rejectPrice();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'reject'.tr,
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

  void _showCancelDialog(BuildContext context) {
    final controller = Get.find<OrderDetailsController>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'cancel_order'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextColor,
          ),
        ),
        content: Text(
          'cancel_order_confirmation'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.darkTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'No',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.lightGreyTextColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

