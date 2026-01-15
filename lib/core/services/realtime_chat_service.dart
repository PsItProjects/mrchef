import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';
import 'package:mrsheaf/features/chat/services/chat_service.dart';
import 'package:mrsheaf/features/merchant/services/merchant_chat_service.dart';

/// Service for real-time chat using API polling (Firestore disabled)
class RealtimeChatService extends GetxService {
  static RealtimeChatService get instance => Get.find<RealtimeChatService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();
  final MerchantChatService _merchantChatService = MerchantChatService();
  
  // IMPORTANT: Firestore is DISABLED - using API polling only
  // Set to false because Firestore database doesn't exist for this project
  bool _isFirestoreAvailable = false;

  // Active subscriptions and polling
  final Map<int, StreamSubscription> _messageSubscriptions = {};
  final Map<int, Timer> _pollingTimers = {};
  final Map<int, StreamController<List<MessageModel>>> _messageControllers = {};
  final Map<int, int> _lastMessageIds = {};
  final Map<int, List<MessageModel>> _cachedMessages = {};
  final Map<int, String> _userTypes = {};
  final Map<int, int> _errorCounts = {};
  final Map<int, bool> _isPollingPaused = {};
  final Map<int, DateTime> _lastErrorTime = {};

  // Polling settings
  static const Duration _pollingInterval = Duration(seconds: 3);
  static const int _maxConsecutiveErrors = 5;

  Future<RealtimeChatService> init() async {
    // Skip Firestore test - we know it's not available
    _isFirestoreAvailable = false;
    if (kDebugMode) {
      print('RealtimeChatService: Using API polling (Firestore disabled)');
    }
    return this;
  }

  bool get isFirestoreAvailable => _isFirestoreAvailable;

  CollectionReference<Map<String, dynamic>> _messagesCollection(int conversationId) {
    return _firestore.collection('conversations').doc(conversationId.toString()).collection('messages');
  }

  /// Listen to messages - ALWAYS uses API polling since Firestore is disabled
  Stream<List<MessageModel>> listenToMessages(int conversationId, {String userType = 'customer'}) {
    // Always use API polling - Firestore is disabled
    return _startPollingForMessages(conversationId, userType: userType);
  }

  void addMessageToCache(int conversationId, MessageModel message) {
    if (_cachedMessages.containsKey(conversationId)) {
      final existingIndex = _cachedMessages[conversationId]!.indexWhere((m) => m.id == message.id);
      if (existingIndex == -1) {
        _cachedMessages[conversationId]!.add(message);
        _messageControllers[conversationId]?.add(List.from(_cachedMessages[conversationId]!));
      }
    }
  }

  Stream<List<MessageModel>> _startPollingForMessages(int conversationId, {String userType = 'customer'}) {
    _userTypes[conversationId] = userType;
    _errorCounts[conversationId] = 0;
    _isPollingPaused[conversationId] = false;

    if (!_messageControllers.containsKey(conversationId)) {
      _messageControllers[conversationId] = StreamController<List<MessageModel>>.broadcast();
      _cachedMessages[conversationId] = [];
      
      // Start polling with reasonable interval
      _pollingTimers[conversationId] = Timer.periodic(_pollingInterval, (timer) async {
        await _fetchAndEmitMessages(conversationId);
      });
      
      // Do immediate fetch
      _fetchAndEmitMessages(conversationId);
    }
    return _messageControllers[conversationId]!.stream;
  }

  Duration _calculateBackoffDuration(int errorCount) {
    if (errorCount == 0) return _pollingInterval;
    final backoffSeconds = (3.0 * (1 << (errorCount - 1))).clamp(3.0, 30.0);
    return Duration(milliseconds: (backoffSeconds * 1000).toInt());
  }

  bool _shouldSkipPoll(int conversationId) {
    if (_isPollingPaused[conversationId] == true) return true;
    final errorCount = _errorCounts[conversationId] ?? 0;
    if (errorCount == 0) return false;
    final lastError = _lastErrorTime[conversationId];
    if (lastError == null) return false;
    return DateTime.now().difference(lastError) < _calculateBackoffDuration(errorCount);
  }

  bool _isAuthError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return statusCode == 401 || statusCode == 403;
    }
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('401') || errorStr.contains('403') || 
           errorStr.contains('unauthorized') || errorStr.contains('forbidden');
  }

  Future<void> _fetchAndEmitMessages(int conversationId) async {
    if (_shouldSkipPoll(conversationId)) return;

    try {
      final userType = _userTypes[conversationId] ?? 'customer';
      List<MessageModel> messages;
      
      if (userType == 'merchant') {
        messages = await _merchantChatService.getMessages(conversationId);
      } else {
        messages = await _chatService.getMessages(conversationId);
      }

      // Reset error count on success
      _errorCounts[conversationId] = 0;
      _isPollingPaused[conversationId] = false;

      // IMPORTANT: Only emit if we have messages (don't emit empty list)
      if (messages.isNotEmpty) {
        final currentMaxId = _lastMessageIds[conversationId] ?? 0;
        final newMaxId = messages.map((msg) => msg.id).reduce((a, b) => a > b ? a : b);
        
        _lastMessageIds[conversationId] = newMaxId;
        _cachedMessages[conversationId] = messages;
        _messageControllers[conversationId]?.add(messages);
        
        if (kDebugMode && newMaxId > currentMaxId) {
          print('Polling: New messages detected (count: ${messages.length})');
        }
      }
    } catch (e) {
      _lastErrorTime[conversationId] = DateTime.now();
      _errorCounts[conversationId] = (_errorCounts[conversationId] ?? 0) + 1;

      if (_isAuthError(e)) {
        if (kDebugMode) print('Auth error - pausing polling for conversation $conversationId');
        _isPollingPaused[conversationId] = true;
        _pollingTimers[conversationId]?.cancel();
        _pollingTimers.remove(conversationId);
        return;
      }

      if ((_errorCounts[conversationId] ?? 0) >= _maxConsecutiveErrors) {
        if (kDebugMode) print('Max errors - pausing polling for conversation $conversationId');
        _isPollingPaused[conversationId] = true;
      }
    }
  }

  /// Sync message - just triggers refresh since Firestore is disabled
  Future<void> syncMessageToFirestore(int conversationId, MessageModel message) async {
    // Firestore is disabled - just trigger a manual refresh
    await Future.delayed(const Duration(milliseconds: 300));
    await triggerManualRefresh(conversationId);
  }

  Future<void> triggerManualRefresh(int conversationId) async {
    if (_messageControllers.containsKey(conversationId)) {
      try {
        final userType = _userTypes[conversationId] ?? 'customer';
        List<MessageModel> messages;
        
        if (userType == 'merchant') {
          messages = await _merchantChatService.getMessages(conversationId);
        } else {
          messages = await _chatService.getMessages(conversationId);
        }
        
        // Only emit if we have messages
        if (messages.isNotEmpty) {
          final maxMessageId = messages.map((msg) => msg.id).reduce((a, b) => a > b ? a : b);
          _lastMessageIds[conversationId] = maxMessageId;
          _cachedMessages[conversationId] = messages;
          _messageControllers[conversationId]!.add(messages);
        }
      } catch (e) {
        if (kDebugMode) print('Error in manual refresh: $e');
      }
    }
  }

  Future<void> markMessagesAsRead(int conversationId, String readerType) async {
    // No-op since Firestore is disabled
  }

  Stream<bool> listenToTyping(int conversationId, String otherUserType) {
    // Always return false since Firestore is disabled
    return Stream.value(false);
  }

  Future<void> setTyping(int conversationId, String userType, bool isTyping) async {
    // No-op since Firestore is disabled
  }

  void resumePolling(int conversationId) {
    if (_isPollingPaused[conversationId] == true) {
      _isPollingPaused[conversationId] = false;
      _errorCounts[conversationId] = 0;
      if (!_pollingTimers.containsKey(conversationId)) {
        _pollingTimers[conversationId] = Timer.periodic(_pollingInterval, (timer) async {
          await _fetchAndEmitMessages(conversationId);
        });
      }
      if (kDebugMode) print('Resumed polling for conversation $conversationId');
    }
  }

  void disposeConversation(int conversationId) {
    if (kDebugMode) print('Disposing conversation #$conversationId resources');
    _messageSubscriptions[conversationId]?.cancel();
    _messageSubscriptions.remove(conversationId);
    _pollingTimers[conversationId]?.cancel();
    _pollingTimers.remove(conversationId);
    _messageControllers[conversationId]?.close();
    _messageControllers.remove(conversationId);
    _lastMessageIds.remove(conversationId);
    _cachedMessages.remove(conversationId);
    _userTypes.remove(conversationId);
    _errorCounts.remove(conversationId);
    _isPollingPaused.remove(conversationId);
    _lastErrorTime.remove(conversationId);
  }

  @override
  void onClose() {
    for (var subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();
    for (var timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();
    for (var controller in _messageControllers.values) {
      controller.close();
    }
    _messageControllers.clear();
    _cachedMessages.clear();
    _userTypes.clear();
    _lastMessageIds.clear();
    _errorCounts.clear();
    _isPollingPaused.clear();
    _lastErrorTime.clear();
    super.onClose();
  }
}
