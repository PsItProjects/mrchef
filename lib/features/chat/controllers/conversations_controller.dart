import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/chat/services/chat_service.dart';

class ConversationsController extends GetxController {
  final ChatService _chatService = ChatService();

  // Observable state
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  /// Load all conversations
  Future<void> loadConversations() async {
    try {
      isLoading.value = true;

      final fetchedConversations = await _chatService.getConversations();
      conversations.value = fetchedConversations;
    } catch (e) {
      String errorMessage = e.toString();
      
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh conversations (pull to refresh)
  Future<void> refreshConversations() async {
    try {
      isRefreshing.value = true;

      final fetchedConversations = await _chatService.getConversations();
      conversations.value = fetchedConversations;
    } catch (e) {
      String errorMessage = e.toString();
      
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Navigate to chat screen
  void openConversation(ConversationModel conversation) {
    Get.toNamed('/chat', arguments: {
      'conversationId': conversation.id,
      'conversation_id': conversation.id, // Also pass snake_case for compatibility
      'conversation': conversation, // Pass the conversation object
    });
  }

  /// Get total unread count
  int get totalUnreadCount {
    return conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }
}

