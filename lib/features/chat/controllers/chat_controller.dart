import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/services/fcm_service.dart';
import 'package:mrsheaf/core/services/realtime_chat_service.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/chat/services/chat_service.dart';
import 'package:mrsheaf/features/support/services/support_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final SupportService _supportService = SupportService();

  // Observable state
  final Rx<ConversationModel?> conversation = Rx<ConversationModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxInt highlightedMessageId = 0.obs;
  final RxBool isOtherTyping = false.obs;

  // Text controller for message input
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // GlobalKeys for each message to enable scrolling to specific messages
  final Map<int, GlobalKey> messageKeys = {};

  // Real-time subscriptions
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;

  late int conversationId;
  int? repliedToMessageId; // For storing the message ID to reply to

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
        final args = Get.arguments as Map<String, dynamic>;

        // Check if conversation data is passed
        if (args.containsKey('conversation')) {
          conversation.value = ConversationModel.fromJson(args['conversation']);
        }

        // Check if orderMessageId is passed (when navigating from order details)
        if (args.containsKey('orderMessageId')) {
          repliedToMessageId = args['orderMessageId'] as int?;
          if (kDebugMode) {
            print('💬 Order message ID set for reply: $repliedToMessageId');
          }
        }
      }
    }

    loadMessages();

    // Notify backend that user entered this chat
    _enterChat();

    // Setup real-time listeners
    _setupRealtimeListeners();
  }

  Future<void> reportConversation({required String reason, String? details}) async {
    try {
      await _supportService.reportConversation(
        userType: 'customer',
        conversationId: conversationId,
        reason: reason,
        details: details,
      );
      Get.snackbar(
        TranslationHelper.tr('success'),
        'report_submitted'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.2),
      );
    } catch (e) {
      Get.snackbar(
        TranslationHelper.tr('error'),
        TranslationHelper.tr('error'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
      );
    }
  }

  @override
  void onClose() {
    // Cancel subscriptions
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();

    // Notify backend that user left this chat
    _leaveChat();

    // Clean up realtime service
    if (Get.isRegistered<RealtimeChatService>()) {
      RealtimeChatService.instance.disposeConversation(conversationId);
    }

    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Setup real-time listeners for messages and typing
  void _setupRealtimeListeners() {
    if (!Get.isRegistered<RealtimeChatService>()) return;

    final realtimeService = RealtimeChatService.instance;

    // Listen to new messages
    _messagesSubscription =
        realtimeService.listenToMessages(conversationId).listen((newMessages) {
      // Only add new messages that we don't have
      for (var msg in newMessages) {
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
          messageKeys[msg.id] = GlobalKey();
          _scrollToBottom();
        }
      }
    });

    // Listen to typing indicator
    _typingSubscription = realtimeService
        .listenToTyping(conversationId, 'merchant')
        .listen((isTyping) {
      isOtherTyping.value = isTyping;
    });
  }

  /// Notify backend that user entered this chat (to prevent push notifications)
  Future<void> _enterChat() async {
    try {
      if (Get.isRegistered<FCMService>()) {
        await FCMService.instance.enterChat(conversationId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error entering chat: $e');
      }
    }
  }

  /// Notify backend that user left this chat
  Future<void> _leaveChat() async {
    try {
      if (Get.isRegistered<FCMService>()) {
        await FCMService.instance.leaveChat();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving chat: $e');
      }
    }
  }

  /// Load messages for this conversation
  Future<void> loadMessages() async {
    try {
      isLoading.value = true;

      final fetchedMessages = await _chatService.getMessages(conversationId);
      final seenIds = <int>{};
      final deduped = <MessageModel>[];
      for (final msg in fetchedMessages) {
        if (seenIds.add(msg.id)) {
          deduped.add(msg);
        }
      }
      messages.value = deduped;

      // Create GlobalKeys for each message
      messageKeys.clear();
      for (var message in messages) {
        messageKeys[message.id] = GlobalKey();
      }

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

      // Send message with optional replied_to_message_id
      final newMessage = await _chatService.sendMessage(
        conversationId,
        messageText,
        repliedToMessageId: repliedToMessageId,
      );

      // Add message to list
      messages.add(newMessage);

      // Create GlobalKey for new message
      messageKeys[newMessage.id] = GlobalKey();

      // Sync to Firestore for real-time
      if (Get.isRegistered<RealtimeChatService>()) {
        RealtimeChatService.instance
            .syncMessageToFirestore(conversationId, newMessage);
      }

      // Clear replied message reference
      repliedToMessageId = null;

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

  /// Scroll to a specific message by ID
  void scrollToMessage(int messageId) {
    final key = messageKeys[messageId];
    if (key == null || key.currentContext == null) {
      print(
          '⚠️ Message key not found or context is null for message #$messageId');
      return;
    }

    // Highlight the message
    highlightedMessageId.value = messageId;

    // Scroll to the message
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.2, // Position message at 20% from top of viewport
    );

    // Remove highlight after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      highlightedMessageId.value = 0;
    });
  }

  /// Refresh messages (pull to refresh)
  Future<void> refreshMessages() async {
    await loadMessages();
  }

  /// Notify that user is typing
  void setTyping(bool isTyping) {
    if (Get.isRegistered<RealtimeChatService>()) {
      RealtimeChatService.instance
          .setTyping(conversationId, 'customer', isTyping);
    }
  }
}
