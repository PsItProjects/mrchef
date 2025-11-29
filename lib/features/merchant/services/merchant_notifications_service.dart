import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:dio/dio.dart' as dio;

class MerchantNotificationsService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get all notifications with pagination
  Future<Map<String, dynamic>?> getNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    try {
      print('🔔 Loading merchant notifications...');
      
      final response = await _apiClient.get(
        '/merchant/profile/notifications',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'unread_only': unreadOnly,
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ Notifications loaded successfully');
        return response.data['data'];
      }
      return null;
    } on dio.DioException catch (e) {
      print('❌ Error loading notifications: ${e.message}');
      return null;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        '/merchant/profile/notifications/unread-count',
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['unread_count'] ?? 0;
      }
      return 0;
    } on dio.DioException catch (e) {
      print('❌ Error getting unread count: ${e.message}');
      return 0;
    }
  }

  /// Mark a single notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.post(
        '/merchant/profile/notifications/$notificationId/read',
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ Notification marked as read');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error marking notification as read: ${e.message}');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.post(
        '/merchant/profile/notifications/read-all',
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ All notifications marked as read');
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('❌ Error marking all notifications as read: ${e.message}');
      return false;
    }
  }
}

