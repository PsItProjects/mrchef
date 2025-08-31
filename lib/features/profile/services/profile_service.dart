import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';

class ProfileService extends GetxService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get('/customer/profile');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Profile loaded successfully',
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      print('Error loading user profile: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  /// Update customer language preference
  Future<Map<String, dynamic>> updateLanguage(String language) async {
    try {
      final response = await _apiClient.put(
        '/customer/profile/language',
        data: {
          'preferred_language': language,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Language updated successfully',
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update language',
        };
      }
    } catch (e) {
      print('Error updating language: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  /// Get customer profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get('/customer/profile');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      print('Error getting profile: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }
}
