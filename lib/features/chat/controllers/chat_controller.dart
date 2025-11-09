import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/chat/services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();

  // Observable state
  final Rx<ConversationModel?> conversation = Rx<ConversationModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  // Text controller for message input
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late int conversationId;

  @override
  void onInit() {
    super.onInit();

    // Get conversation ID from route parameters
    conversationId = int.parse(Get.parameters['id'] ?? '0');

    // Get conversation from arguments if passed
    if (Get.arguments != null) {
      if (Get.arguments is ConversationModel) {
        conversation.value = Get.arguments as ConversationModel;
      } else if (Get.arguments is Map<String, dynamic>) {
        // Convert from JSON if passed as Map
        conversation.value = ConversationModel.fromJson(Get.arguments as Map<String, dynamic>);
      }
    }

    loadMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Load messages for this conversation
  Future<void> loadMessages() async {
    try {
      isLoading.value = true;

      final fetchedMessages = await _chatService.getMessages(conversationId);
      messages.value = fetchedMessages;

      // Scroll to bottom after loading messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
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

  /// Send a message
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    
    if (messageText.isEmpty) return;

    try {
      isSending.value = true;

      // Clear input immediately for better UX
      messageController.clear();

      // Send message
      final newMessage = await _chatService.sendMessage(conversationId, messageText);

      // Add message to list
      messages.add(newMessage);

      // Scroll to bottom
      _scrollToBottom();
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

      // Restore message text on error
      messageController.text = messageText;
    } finally {
      isSending.value = false;
    }
  }

  /// Scroll to bottom of messages
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Refresh messages (pull to refresh)
  Future<void> refreshMessages() async {
    await loadMessages();
  }
}

