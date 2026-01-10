import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:dio/dio.dart' as dio;
import 'package:mrsheaf/features/auth/services/auth_service.dart';

class NotificationsService extends GetxService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get the correct base path based on user type
  String get _basePath {
    try {
      final authService = Get.find<AuthService>();
      final userType = authService.userType.value;
      if (userType == 'merchant') {
        return '/merchant'; // Merchant notifications are at /merchant/notifications
      }
    } catch (_) {}
    return '/customer/shopping'; // Customer notifications are at /customer/shopping/notifications
  }

  /// Get all notifications with pagination
  Future<Map<String, dynamic>?> getNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final path = '$_basePath/notifications';
      print('🔔 Loading notifications from $path...');
      
      final response = await _apiClient.get(
        path,
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
      print('⚠️ Notifications response: ${response.data}');
      return null;
    } on dio.DioException catch (e) {
      print('❌ Error loading notifications: ${e.message}');
      print('❌ Status code: ${e.response?.statusCode}');
      print('❌ Response: ${e.response?.data}');
      return null;
    }
  }

  /// Mark a single notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.post(
        '$_basePath/notifications/$notificationId/read',
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
        '$_basePath/notifications/read-all',
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

