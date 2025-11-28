import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/chat/models/conversation_model.dart';

class MerchantChatService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all conversations for the merchant
  Future<List<ConversationModel>> getConversations() async {
    try {
      if (kDebugMode) {
        print('MERCHANT CHAT: Fetching conversations...');
      }

      final response = await _apiClient.get('/merchant/chat/conversations');

      if (response.data['success'] == true) {
        final List<dynamic> conversationsData = response.data['data']['conversations'];
        
        if (kDebugMode) {
          print('MERCHANT CHAT: Fetched ${conversationsData.length} conversations');
        }

        return conversationsData
            .map((json) => ConversationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch conversations');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('MERCHANT CHAT ERROR: ${e.response?.statusCode} ${e.message}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        final message = e.response?.data['message'] ?? 'Failed to fetch conversations';
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('MERCHANT CHAT ERROR: $e');
      }
      rethrow;
    }
  }

  /// Get messages for a specific conversation
  Future<List<MessageModel>> getMessages(int conversationId) async {
    try {
      if (kDebugMode) {
        print('MERCHANT CHAT: Fetching messages for conversation $conversationId...');
      }

      final response = await _apiClient.get(
        '/merchant/chat/conversations/$conversationId/messages',
      );

      if (response.data['success'] == true) {
        final List<dynamic> messagesData = response.data['data']['messages'];
        
        if (kDebugMode) {
          print('MERCHANT CHAT: Fetched ${messagesData.length} messages');
        }

        return messagesData
            .map((json) => MessageModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch messages');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('MERCHANT CHAT ERROR: ${e.response?.statusCode} ${e.message}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Conversation not found');
      } else {
        final message = e.response?.data['message'] ?? 'Failed to fetch messages';
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('MERCHANT CHAT ERROR: $e');
      }
      rethrow;
    }
  }

  /// Send a message in a conversation
  Future<MessageModel> sendMessage(int conversationId, String message) async {
    try {
      if (kDebugMode) {
        print('MERCHANT CHAT: Sending message to conversation $conversationId...');
      }

      final response = await _apiClient.post(
        '/merchant/chat/conversations/$conversationId/messages',
        data: {'message': message},
      );

      if (response.data['success'] == true) {
        if (kDebugMode) {
          print('MERCHANT CHAT: Message sent successfully');
        }

        return MessageModel.fromJson(response.data['data']['message']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send message');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('MERCHANT CHAT ERROR: ${e.response?.statusCode} ${e.message}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Conversation not found');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors['message'] != null) {
          throw Exception(errors['message'][0]);
        }
        throw Exception('Message is required');
      } else {
        final message = e.response?.data['message'] ?? 'Failed to send message';
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('MERCHANT CHAT ERROR: $e');
      }
      rethrow;
    }
  }
}

