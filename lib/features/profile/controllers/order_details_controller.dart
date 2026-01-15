import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/core/services/review_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/order_details_model.dart';
import 'package:mrsheaf/features/profile/models/order_model.dart';
import 'package:mrsheaf/features/profile/services/order_service.dart';
import 'package:mrsheaf/features/chat/services/chat_service.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/shared/widgets/order_review_widgets.dart';

class OrderDetailsController extends GetxController {
  late final OrderService _orderService;
  late final ReviewService _reviewService;
  final ChatService _chatService = ChatService();
  late int _currentOrderId;

  // Observables
  final Rx<OrderDetailsModel?> orderDetails = Rx<OrderDetailsModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<int, bool> reviewedProducts = <int, bool>{}.obs; // Track which products have been reviewed

  // Constructor - Initialize services
  OrderDetailsController() {
    _orderService = OrderService(Get.find<ApiClient>());
    _reviewService = ReviewService();
  }

  /// Load order details from API
  Future<void> loadOrderDetails(int orderId) async {
    try {
      _currentOrderId = orderId;
      isLoading.value = true;
      errorMessage.value = '';

      if (kDebugMode) {
        print('📦 ORDER DETAILS: Loading order #$orderId...');
      }

      final data = await _orderService.getOrderDetails(orderId);
      orderDetails.value = OrderDetailsModel.fromJson(data);

      // Load review status for each product
      await _loadReviewStatus();

      if (kDebugMode) {
        print('✅ ORDER DETAILS: Loaded successfully');
        print('📦 ORDER: ${orderDetails.value?.orderNumber}');
        print('🍽️ ITEMS: ${orderDetails.value?.items.length}');
        print('⭐ REVIEWED PRODUCTS: ${reviewedProducts.length}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load order details';
      if (kDebugMode) {
        print('❌ ORDER DETAILS: Error loading - $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh order details
  Future<void> refreshOrderDetails() async {
    await loadOrderDetails(_currentOrderId);
  }

  /// Load review status for products in this order from API
  Future<void> _loadReviewStatus() async {
    try {
      final order = orderDetails.value;
      if (order == null) return;

      // Get user's reviews
      final reviews = await _reviewService.getMyReviews();

      // Mark products that have been reviewed for this order
      for (final item in order.items) {
        final hasReview = reviews.any((review) =>
          review.productId == item.productId &&
          review.orderId == _currentOrderId
        );
        reviewedProducts[item.productId] = hasReview;
      }

      if (kDebugMode) {
        print('⭐ REVIEW STATUS: ${reviewedProducts.entries.where((e) => e.value).length} products reviewed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ REVIEW STATUS: Error loading - $e');
      }
    }
  }

  /// Cancel order
  Future<void> cancelOrder({String? reason}) async {
    try {
      if (kDebugMode) {
        print('🚫 ORDER DETAILS: Cancelling order #$_currentOrderId...');
      }

      final success = await _orderService.cancelOrder(_currentOrderId, reason: reason);

      if (success) {
        if (kDebugMode) {
          print('✅ ORDER DETAILS: Order cancelled successfully');
        }

        // Reload order details to get updated status
        await loadOrderDetails(_currentOrderId);

        Get.snackbar(
          'Success',
          'Order cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ORDER DETAILS: Error cancelling order - $e');
      }

      Get.snackbar(
        'Error',
        'Failed to cancel order',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Confirm delivery of order
  Future<void> confirmDelivery() async {
    try {
      if (kDebugMode) {
        print('✅ ORDER DETAILS: Confirming delivery for order #$_currentOrderId...');
      }

      isLoading.value = true;

      await _orderService.confirmDelivery(_currentOrderId);

      if (kDebugMode) {
        print('✅ ORDER DETAILS: Delivery confirmed successfully');
      }

      // Reload order details to get updated status
      await loadOrderDetails(_currentOrderId);

      Get.snackbar(
        'delivery_confirmed'.tr,
        'order_confirmed_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ORDER DETAILS: Error confirming delivery - $e');
      }

      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to chat with restaurant for this order
  Future<void> openChat() async {
    try {
      if (kDebugMode) {
        print('💬 Opening chat for order #$_currentOrderId...');
      }

      final order = orderDetails.value;
      if (order == null) {
        if (kDebugMode) {
          print('❌ No order details available');
        }
        return;
      }

      // Check if order has conversation_id
      final conversationId = order.conversationId;

      if (conversationId == null) {
        if (kDebugMode) {
          print('⚠️ Order has no conversation_id, creating new conversation...');
        }

        // Show loading indicator
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFACD02),
            ),
          ),
          barrierDismissible: false,
        );

        // Get or create conversation for this order
        final result = await _chatService.getOrCreateOrderConversation(_currentOrderId);
        final conversation = result['conversation'] as ConversationModel;
        final orderMessageId = result['orderMessageId'] as int?;

        // Close loading dialog
        Get.back();

        // Close order details bottom sheet
        Get.back();

        // Navigate to chat screen with arguments
        Get.toNamed(
          AppRoutes.CHAT,
          arguments: {
            'conversationId': conversation.id,
            'conversation_id': conversation.id, // Also pass snake_case for compatibility
            'orderMessageId': orderMessageId,
          },
        );

        if (kDebugMode) {
          print('✅ Navigated to new conversation #${conversation.id}');
          print('✅ Order message ID: $orderMessageId');
        }
      } else {
        // Order has conversation_id, navigate directly to it
        if (kDebugMode) {
          print('✅ Order has conversation_id: $conversationId, navigating...');
        }

        // Close order details bottom sheet
        Get.back();

        // Navigate to chat screen with the conversation ID
        Get.toNamed(
          AppRoutes.CHAT,
          arguments: {
            'conversationId': conversationId,
            'conversation_id': conversationId, // Also pass snake_case for compatibility
            'fromOrder': true,
          },
        );

        if (kDebugMode) {
          print('✅ Navigated to original conversation #$conversationId');
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (kDebugMode) {
        print('❌ Error opening chat: $e');
      }

      Get.snackbar(
        'Error',
        'Failed to open chat. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Show review prompt dialog for delivered orders
  void showReviewPrompt() {
    final order = orderDetails.value;
    if (order == null) return;

    // Only show for delivered or completed orders
    if (order.status != OrderStatus.delivered && order.status != OrderStatus.completed) {
      if (kDebugMode) {
        print('⚠️ Order not eligible for review. Status: ${order.status}');
      }
      return;
    }

    // Build list of items to review
    final itemsToReview = order.items.map((item) {
      return OrderItemToReview(
        productId: item.productId,
        name: item.productName,
        imageUrl: item.productImage,
        isReviewed: reviewedProducts[item.productId] ?? false,
      );
    }).toList();

    OrderReviewPromptDialog.show(
      orderNumber: order.orderNumber,
      items: itemsToReview,
      onLater: () {
        if (kDebugMode) {
          print('⏰ User chose to review later');
        }
      },
      onReview: (productId, rating, comment, images) async {
        await submitProductReview(
          productId: productId,
          rating: rating,
          comment: comment,
          images: images,
        );
      },
    );
  }

  /// Submit a review for a specific product
  Future<void> submitProductReview({
    required int productId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    try {
      if (kDebugMode) {
        print('⭐ Submitting review for product #$productId, rating: $rating');
        print('📝 Comment: $comment');
        print('🖼️ Images: ${images?.length ?? 0}');
        print('📦 Order ID: $_currentOrderId');
      }

      // Convert image paths to Files
      List<Map<String, dynamic>> reviews = [
        {
          'product_id': productId,
          'rating': rating,
          'comment': comment,
          if (images != null && images.isNotEmpty)
            'images': images.map((path) => File(path)).toList(),
        }
      ];

      if (kDebugMode) {
        print('📤 Sending review to API...');
      }

      final response = await _reviewService.submitOrderReviews(
        orderId: _currentOrderId,
        reviews: reviews,
      );

      // Mark as reviewed
      reviewedProducts[productId] = true;

      if (kDebugMode) {
        print('✅ Review submitted successfully');
        print('📊 Response: $response');
      }

      // Close the review bottom sheet
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      // Show success dialog
      await Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
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
                    color: AppColors.successColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.successColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'review_submitted_successfully'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF262626),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'thank_you_for_review'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF5E5E5E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // OK button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ok'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Reload order details to update button state
      await loadOrderDetails(_currentOrderId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error submitting review: $e');
        print('❌ Error type: ${e.runtimeType}');
      }

      // Close the review bottom sheet if open
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      // Show more specific error message
      String errorMessage = 'failed_to_submit_review'.tr;
      if (e.toString().contains('401') || e.toString().contains('Unauthenticated')) {
        errorMessage = 'please_login_first'.tr;
      } else if (e.toString().contains('Already reviewed')) {
        errorMessage = 'already_reviewed'.tr;
      }

      // Show error dialog
      await Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: AppColors.errorColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'error'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF262626),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  errorMessage,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF5E5E5E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // OK button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ok'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      rethrow;
    }
  }
}

