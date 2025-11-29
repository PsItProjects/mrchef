import 'package:get/get.dart';
import 'package:mrsheaf/features/notifications/services/notifications_service.dart';

class NotificationsController extends GetxController {
  static const String tag = 'notifications';

  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final RxInt unreadCount = 0.obs;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  bool get hasMore => _currentPage < _lastPage;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Refresh notifications (called from FCM when new notification arrives)
  void refreshNotifications() {
    loadNotifications(refresh: true);
  }

  /// Load notifications from API
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      notifications.clear();
    }

    if (_currentPage == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final data = await _notificationsService.getNotifications(
        page: _currentPage,
        perPage: 20,
      );

      if (data != null) {
        final List<dynamic> notificationsList = data['notifications'] ?? [];

        // Format notifications
        final formatted = notificationsList.map((n) {
          final notifData = n['data'] ?? n;
          return {
            'id': n['id'] ?? '',
            'type': notifData['type'] ?? 'general',
            'title': notifData['title'] ?? '',
            'message': notifData['message'] ?? '',
            'order_id': notifData['order_id'],
            'order_number': notifData['order_number'],
            'status': notifData['status'],
            'is_read': n['read_at'] != null,
            'created_at': n['created_at'] ?? notifData['created_at'],
            'time_ago': _getTimeAgo(n['created_at']),
          };
        }).toList();

        notifications.addAll(formatted.cast<Map<String, dynamic>>());

        // Update pagination info
        final pagination = data['pagination'];
        if (pagination != null) {
          _lastPage = pagination['last_page'] ?? 1;
        }

        // Update unread count
        unreadCount.value = data['unread_count'] ?? 0;
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  String _getTimeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return '';
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore.value) return;
    _currentPage++;
    await loadNotifications();
  }

  /// Refresh notifications (pull to refresh)
  Future<void> onRefresh() async {
    await loadNotifications(refresh: true);
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final success = await _notificationsService.markAsRead(notificationId);
    if (success) {
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['is_read'] = true;
        notifications.refresh();
      }
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final success = await _notificationsService.markAllAsRead();
    if (success) {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i]['is_read'] = true;
      }
      notifications.refresh();
      unreadCount.value = 0;
    }
  }

  /// Handle notification tap - navigate to appropriate screen
  void onNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'] ?? '';
    final orderId = notification['order_id'];

    // Mark as read
    if (notification['is_read'] != true) {
      markAsRead(notification['id']);
    }

    // Navigate based on notification type
    switch (type) {
      case 'order_status_changed':
        if (orderId != null) {
          Get.toNamed('/orders/$orderId');
        }
        break;
      case 'system':
      case 'promotion':
      default:
        break;
    }
  }

  /// Get icon for notification type
  String getNotificationIcon(String type) {
    switch (type) {
      case 'order_status_changed':
        return '📦';
      case 'system':
        return '⚙️';
      case 'promotion':
        return '🎉';
      default:
        return '🔔';
    }
  }
}
