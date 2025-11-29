import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';

/// Service for real-time chat using Cloud Firestore
class RealtimeChatService extends GetxService {
  static RealtimeChatService get instance => Get.find<RealtimeChatService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Active subscriptions
  final Map<int, StreamSubscription> _messageSubscriptions = {};
  
  /// Initialize the service
  Future<RealtimeChatService> init() async {
    return this;
  }

  /// Get collection reference for a conversation's messages
  CollectionReference<Map<String, dynamic>> _messagesCollection(int conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId.toString())
        .collection('messages');
  }

  /// Listen to new messages in a conversation
  Stream<List<MessageModel>> listenToMessages(int conversationId) {
    return _messagesCollection(conversationId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MessageModel.fromFirestore(data, doc.id);
          }).toList();
        });
  }

  /// Send a message to Firestore (for real-time sync)
  Future<void> syncMessageToFirestore(int conversationId, MessageModel message) async {
    try {
      await _messagesCollection(conversationId)
          .doc(message.id.toString())
          .set(message.toFirestore());
      
      // Update conversation's last message
      await _firestore
          .collection('conversations')
          .doc(conversationId.toString())
          .set({
            'last_message': message.message,
            'last_message_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing message to Firestore: $e');
      }
    }
  }

  /// Mark messages as read in Firestore
  Future<void> markMessagesAsRead(int conversationId, String readerType) async {
    try {
      final field = readerType == 'customer' 
          ? 'is_read_by_customer' 
          : 'is_read_by_merchant';
      
      final unreadMessages = await _messagesCollection(conversationId)
          .where(field, isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {field: true});
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking messages as read: $e');
      }
    }
  }

  /// Subscribe to typing indicator
  Stream<bool> listenToTyping(int conversationId, String otherUserType) {
    return _firestore
        .collection('conversations')
        .doc(conversationId.toString())
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return false;
          final data = snapshot.data();
          final typingField = '${otherUserType}_is_typing';
          return data?[typingField] ?? false;
        });
  }

  /// Update typing status
  Future<void> setTyping(int conversationId, String userType, bool isTyping) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId.toString())
          .set({
            '${userType}_is_typing': isTyping,
          }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error setting typing status: $e');
      }
    }
  }

  /// Clean up subscriptions
  void disposeConversation(int conversationId) {
    _messageSubscriptions[conversationId]?.cancel();
    _messageSubscriptions.remove(conversationId);
  }

  @override
  void onClose() {
    for (var subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();
    super.onClose();
  }
}

