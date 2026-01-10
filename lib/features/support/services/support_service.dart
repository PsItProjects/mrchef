import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mrsheaf/core/network/api_client.dart';

class SupportService {
  final ApiClient _apiClient = ApiClient.instance;

  String _basePathForUserType(String userType) {
    if (userType == 'merchant') return '/merchant';
    return '/customer';
  }

  Future<void> reportConversation({
    required String userType,
    required int conversationId,
    required String reason,
    String? details,
  }) async {
    final base = _basePathForUserType(userType);
    await _apiClient.post(
      '$base/chat/conversations/$conversationId/report',
      data: {
        'reason': reason,
        if (details != null) 'details': details,
      },
    );
  }

  Future<List<Map<String, dynamic>>> listTickets({required String userType}) async {
    final base = _basePathForUserType(userType);
    final res = await _apiClient.get('$base/support/tickets');
    final data = res.data;
    if (data is Map && data['success'] == true) {
      final tickets = (data['data']?['tickets'] as List?) ?? const [];
      return tickets.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: data,
      type: DioExceptionType.badResponse,
    );
  }

  Future<int> createTicket({
    required String userType,
    required String subject,
    String? description,
    File? imageFile,
  }) async {
    final base = _basePathForUserType(userType);
    
    // Use FormData if image is provided
    if (imageFile != null) {
      final formData = FormData.fromMap({
        'subject': subject,
        if (description != null) 'description': description,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      
      final res = await _apiClient.post(
        '$base/support/tickets',
        data: formData,
      );

      final data = res.data;
      if (data is Map && data['success'] == true) {
        return (data['data']?['ticket_id'] as num).toInt();
      }
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: data,
        type: DioExceptionType.badResponse,
      );
    }
    
    // Regular JSON request without image
    final res = await _apiClient.post(
      '$base/support/tickets',
      data: {
        'subject': subject,
        if (description != null) 'description': description,
      },
    );

    final data = res.data;
    if (data is Map && data['success'] == true) {
      return (data['data']?['ticket_id'] as num).toInt();
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: data,
      type: DioExceptionType.badResponse,
    );
  }

  Future<Map<String, dynamic>> getTicket({
    required String userType,
    required int ticketId,
  }) async {
    final base = _basePathForUserType(userType);
    final res = await _apiClient.get('$base/support/tickets/$ticketId');
    final data = res.data;
    if (data is Map && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']?['ticket'] as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: data,
      type: DioExceptionType.badResponse,
    );
  }

  Future<Map<String, dynamic>> sendTicketMessage({
    required String userType,
    required int ticketId,
    required String message,
  }) async {
    final base = _basePathForUserType(userType);
    final res = await _apiClient.post(
      '$base/support/tickets/$ticketId/messages',
      data: {
        'message': message,
      },
    );
    final data = res.data;
    if (data is Map && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']?['message'] as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: data,
      type: DioExceptionType.badResponse,
    );
  }

  /// Send an image message to a support ticket
  Future<Map<String, dynamic>> sendTicketImageMessage({
    required String userType,
    required int ticketId,
    required File imageFile,
    String? caption,
  }) async {
    final base = _basePathForUserType(userType);
    
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
      if (caption != null && caption.isNotEmpty) 'message': caption,
      'type': 'image',
    });

    final res = await _apiClient.post(
      '$base/support/tickets/$ticketId/messages',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
    
    final data = res.data;
    if (data is Map && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']?['message'] as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: data,
      type: DioExceptionType.badResponse,
    );
  }
}
