import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/merchant/services/merchant_chat_service.dart';

class MerchantConversationsController extends GetxController {
  final MerchantChatService _chatService = MerchantChatService();

  // Observable state
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  /// Total unread count from all conversations
  int get totalUnreadCount {
    return conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  /// Load conversations from the backend
  Future<void> loadConversations() async {
    try {
      isLoading.value = true;

      final result = await _chatService.getConversations();
      conversations.assignAll(result);

      if (kDebugMode) {
        print('MERCHANT CONVERSATIONS: Loaded ${result.length} conversations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('MERCHANT CONVERSATIONS ERROR: $e');
      }
      Get.snackbar(
        'error'.tr,
        'error_loading_conversations'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh conversations (for pull-to-refresh)
  Future<void> refreshConversations() async {
    try {
      isRefreshing.value = true;

      final result = await _chatService.getConversations();
      conversations.assignAll(result);

      if (kDebugMode) {
        print(
            'MERCHANT CONVERSATIONS: Refreshed ${result.length} conversations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('MERCHANT CONVERSATIONS REFRESH ERROR: $e');
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Open a specific conversation
  Future<void> openConversation(ConversationModel conversation) async {
    // Navigate to the chat screen
    await Get.toNamed(
      '/merchant/chat/${conversation.id}',
      arguments: {
        'conversation_id': conversation.id,
        'customer_name': conversation.customer.name,
        'customer_avatar': conversation.customer.avatar,
      },
    );

    // When returning from chat, mark conversation as read locally
    // and refresh to get updated data from backend
    _markConversationAsRead(conversation.id);
  }

  /// Mark a conversation as read locally
  void _markConversationAsRead(int conversationId) {
    final index = conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final conv = conversations[index];
      // Create a copy with unreadCount = 0
      conversations[index] = ConversationModel(
        id: conv.id,
        orderId: conv.orderId,
        customer: conv.customer,
        merchant: conv.merchant,
        restaurant: conv.restaurant,
        conversationType: conv.conversationType,
        productDetails: conv.productDetails,
        status: conv.status,
        lastMessage: conv.lastMessage,
        lastMessageAt: conv.lastMessageAt,
        unreadCount: 0, // Mark as read
      );
    }
  }

  /// Refresh conversations when returning to the screen
  @override
  void onReady() {
    super.onReady();
    // Refresh when screen becomes visible again
    ever(conversations, (_) {
      // This keeps the list reactive
    });
  }
}
