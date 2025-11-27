import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all conversations for the authenticated customer
  Future<List<ConversationModel>> getConversations() async {
    try {
      if (kDebugMode) {
        print('💬 CHAT SERVICE: Fetching conversations...');
      }

      final response = await _apiClient.get('/customer/chat/conversations');

      if (response.data['success'] == true) {
        final List<dynamic> conversationsData = response.data['data']['conversations'];
        
        if (kDebugMode) {
          print('✅ CHAT SERVICE: Fetched ${conversationsData.length} conversations');
        }

        return conversationsData
            .map((json) => ConversationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch conversations');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CHAT SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
        print('❌ RESPONSE DATA: ${e.response?.data}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('يجب تسجيل الدخول أولاً');
      } else {
        final message = e.response?.data['message'] ?? 'فشل في جلب المحادثات';
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CHAT SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Get messages for a specific conversation
  Future<List<MessageModel>> getMessages(int conversationId) async {
    try {
      if (kDebugMode) {
        print('💬 CHAT SERVICE: Fetching messages for conversation $conversationId...');
      }

      final response = await _apiClient.get(
        '/customer/chat/conversations/$conversationId/messages',
      );

      if (response.data['success'] == true) {
        final List<dynamic> messagesData = response.data['data']['messages'];
        
        if (kDebugMode) {
          print('✅ CHAT SERVICE: Fetched ${messagesData.length} messages');
        }

        return messagesData
            .map((json) => MessageModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch messages');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CHAT SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
        print('❌ RESPONSE DATA: ${e.response?.data}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('يجب تسجيل الدخول أولاً');
      } else if (e.response?.statusCode == 404) {
        throw Exception('المحادثة غير موجودة');
      } else {
        final message = e.response?.data['message'] ?? 'فشل في جلب الرسائل';
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CHAT SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Send a message in a conversation
  Future<MessageModel> sendMessage(
    int conversationId,
    String message, {
    int? repliedToMessageId,
  }) async {
    try {
      if (kDebugMode) {
        print('💬 CHAT SERVICE: Sending message to conversation $conversationId...');
        print('💬 MESSAGE: $message');
        if (repliedToMessageId != null) {
          print('💬 REPLYING TO MESSAGE: $repliedToMessageId');
        }
      }

      final data = {
        'message': message,
        if (repliedToMessageId != null) 'replied_to_message_id': repliedToMessageId,
      };

      final response = await _apiClient.post(
        '/customer/chat/conversations/$conversationId/messages',
        data: data,
      );

      if (response.data['success'] == true) {
        if (kDebugMode) {
          print('✅ CHAT SERVICE: Message sent successfully');
        }

        return MessageModel.fromJson(response.data['data']['message']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send message');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CHAT SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
        print('❌ RESPONSE DATA: ${e.response?.data}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('يجب تسجيل الدخول أولاً');
      } else if (e.response?.statusCode == 404) {
        throw Exception('المحادثة غير موجودة');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors['message'] != null) {
          throw Exception(errors['message'][0]);
        }
        throw Exception('الرسالة مطلوبة');
      } else {
        final message = e.response?.data['message'] ?? 'فشل في إرسال الرسالة';
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CHAT SERVICE ERROR: $e');
      }
      rethrow;
    }
  }

  /// Get or create conversation for an order
  /// Returns a map with 'conversation' and 'orderMessageId'
  Future<Map<String, dynamic>> getOrCreateOrderConversation(int orderId) async {
    try {
      if (kDebugMode) {
        print('💬 CHAT SERVICE: Getting/creating conversation for order $orderId...');
      }

      final response = await _apiClient.get(
        '/customer/chat/orders/$orderId/conversation',
      );

      if (response.data['success'] == true) {
        if (kDebugMode) {
          print('✅ CHAT SERVICE: Conversation retrieved/created successfully');
          print('✅ ORDER MESSAGE ID: ${response.data['data']['order_message_id']}');
        }

        return {
          'conversation': ConversationModel.fromJson(response.data['data']['conversation']),
          'orderMessageId': response.data['data']['order_message_id'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get conversation');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ CHAT SERVICE ERROR: ${e.response?.statusCode} ${e.message}');
        print('❌ RESPONSE DATA: ${e.response?.data}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('يجب تسجيل الدخول أولاً');
      } else if (e.response?.statusCode == 404) {
        throw Exception('الطلب غير موجود');
      } else {
        final message = e.response?.data['message'] ?? 'فشل في الحصول على المحادثة';
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CHAT SERVICE ERROR: $e');
      }
      rethrow;
    }
  }
}

