import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:dio/dio.dart' as dio;

class MerchantOrderDetailsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable state
  final Rx<Map<String, dynamic>?> order = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxString errorMessage = ''.obs;

  late int orderId;

  // Order statuses that merchant can set
  final List<String> availableStatuses = [
    'confirmed',
    'preparing',
    'ready',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    // Get order ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['orderId'] != null) {
      orderId = args['orderId'] as int;
      loadOrderDetails();
    } else {
      errorMessage.value = 'order_not_found'.tr;
    }
  }

  /// Load order details from API
  Future<void> loadOrderDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiClient.get('/merchant/orders/$orderId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        order.value = response.data['data']['order'];
        print('Order loaded: ${order.value}');
      } else {
        errorMessage.value = response.data['message'] ?? 'error'.tr;
      }
    } on dio.DioException catch (e) {
      print('Error loading order: ${e.message}');
      errorMessage.value = 'error_loading_order'.tr;
    } catch (e) {
      print('Unexpected error: $e');
      errorMessage.value = 'unexpected_error'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String newStatus,
      {String? rejectionReason}) async {
    try {
      isUpdatingStatus.value = true;

      final data = <String, dynamic>{'status': newStatus};
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        data['rejection_reason'] = rejectionReason;
      }

      final response = await _apiClient.patch(
        '/merchant/orders/$orderId/status',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        order.value = response.data['data']['order'];
        Get.snackbar(
          'success'.tr,
          'order_status_updated'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'error'.tr,
          response.data['message'] ?? 'error_updating_status'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } on dio.DioException catch (e) {
      print('Error updating status: ${e.message}');
      Get.snackbar(
        'error'.tr,
        'error_updating_status'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  /// Get translated status text
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TranslationHelper.isArabic ? 'معلق' : 'Pending';
      case 'confirmed':
        return TranslationHelper.isArabic ? 'مؤكد' : 'Confirmed';
      case 'preparing':
        return TranslationHelper.isArabic ? 'قيد التحضير' : 'Preparing';
      case 'ready':
        return TranslationHelper.isArabic ? 'جاهز' : 'Ready';
      case 'out_for_delivery':
        return TranslationHelper.isArabic ? 'في الطريق' : 'Out for Delivery';
      case 'delivered':
        return TranslationHelper.isArabic ? 'تم التوصيل' : 'Delivered';
      case 'cancelled':
        return TranslationHelper.isArabic ? 'ملغي' : 'Cancelled';
      case 'rejected':
        return TranslationHelper.isArabic ? 'مرفوض' : 'Rejected';
      default:
        return status;
    }
  }

  /// Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'out_for_delivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Navigate to chat with customer
  void openChatWithCustomer() {
    final orderData = order.value;
    if (orderData == null) return;

    // Check for conversation_id (integer) or conversation (map)
    int? conversationId;

    // First check if there's a conversation_id field
    if (orderData['conversation_id'] != null) {
      conversationId = orderData['conversation_id'] is int
          ? orderData['conversation_id']
          : int.tryParse(orderData['conversation_id'].toString());
    }
    // If not, check if conversation is a map with id
    else if (orderData['conversation'] != null &&
        orderData['conversation'] is Map) {
      conversationId = orderData['conversation']['id'];
    }

    if (conversationId != null) {
      Get.toNamed(
        '/merchant/chat/$conversationId',
        arguments: {
          'order': orderData,
        },
      );
    } else {
      Get.snackbar(
        'info'.tr,
        'no_conversation_available'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Check if conversation is available
  bool get hasConversation {
    final orderData = order.value;
    if (orderData == null) return false;
    return orderData['conversation_id'] != null ||
        (orderData['conversation'] != null && orderData['conversation'] is Map);
  }
}
