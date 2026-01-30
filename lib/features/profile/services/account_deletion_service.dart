import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:mrsheaf/core/network/api_client.dart';

class AccountDeletionService extends GetxService {
  final ApiClient _apiClient = ApiClient.instance;

  String _messageFromData(dynamic data) {
    if (data == null) return '';

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return '';

      // Sometimes the backend returns JSON as a string.
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          return _messageFromData(decoded);
        } catch (_) {
          // Not JSON, use raw string.
        }
      }

      return trimmed;
    }

    if (data is Map) {
      // Standard API shape: { success: false, message: "..." }
      final message = data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      // Validation shape: { errors: { field: ["..."] } }
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
        return errors.values.first.toString();
      }
    }

    return '';
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final extracted = _messageFromData(error.response?.data);
      if (extracted.isNotEmpty) return extracted;
    }

    return 'network_error'.tr;
  }

  Future<Map<String, dynamic>> sendOtp() async {
    try {
      final response = await _apiClient.post('/account-deletion/send-otp');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP sent successfully',
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to send OTP',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _extractErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> confirm({required String otp, String? reason}) async {
    try {
      final response = await _apiClient.post(
        '/account-deletion/confirm',
        data: {
          'otp': otp,
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Request submitted',
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to submit request',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _extractErrorMessage(e),
      };
    }
  }
}
