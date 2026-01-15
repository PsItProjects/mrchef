import 'package:get/get.dart';
import 'package:mrsheaf/features/merchant/services/merchant_notifications_service.dart';

class MerchantNotificationsController extends GetxController {
  static const String tag = 'merchant_notifications';

  final MerchantNotificationsService _notificationsService =
      Get.find<MerchantNotificationsService>();

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
        
        // Format notifications - data comes flat from API (not nested)
        final formatted = notificationsList.map((n) {
          // Backend returns flat data, not nested in 'data' key
          return {
            'id': n['id'] ?? '',
            'type': n['type'] ?? 'general',
            'title': n['title'] ?? '',
            'message': n['message'] ?? '',
            'order_id': n['order_id'],
            'order_number': n['order_number'],
            'ticket_id': n['ticket_id'],
            'report_id': n['report_id'],
            'conversation_id': n['conversation_id'],
            'status': n['status'],
            'is_read': n['is_read'] == true || n['read_at'] != null,
            'created_at': n['created_at'],
            'time_ago': n['time_ago'],
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
      // Update local state
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['is_read'] = true;
        notifications.refresh();
      }
      // Decrease unread count
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final success = await _notificationsService.markAllAsRead();
    if (success) {
      // Update local state
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
    final ticketId = notification['ticket_id'];
    final reportId = notification['report_id'];
    final conversationId = notification['conversation_id'];
    
    print('🔔 Merchant Notification tap: type=$type, orderId=$orderId, ticketId=$ticketId, reportId=$reportId');

    // Mark as read
    if (notification['is_read'] != true) {
      markAsRead(notification['id']);
    }

    // Navigate based on notification type
    switch (type) {
      case 'new_order':
      case 'order_status_changed':
      case 'order_cancelled':
      case 'order_confirmed':
        if (orderId != null) {
          // Merchant uses arguments instead of route parameters
          Get.toNamed('/merchant/order-details', arguments: {'orderId': orderId});
        }
        break;
      case 'support_reply':
      case 'support_status_changed':
      case 'support_closed':
      case 'new_ticket':
        if (ticketId != null) {
          Get.toNamed('/support/tickets/$ticketId');
        }
        break;
      case 'report_reply':
      case 'report_status_changed':
      case 'report_resolved':
      case 'new_report':
        if (reportId != null) {
          Get.toNamed('/support/reports/$reportId');
        }
        break;
      case 'new_message':
        if (conversationId != null) {
          Get.toNamed('/merchant/chat', arguments: {
            'conversationId': int.tryParse(conversationId.toString()),
            'conversation_id': int.tryParse(conversationId.toString()),
          });
        }
        break;
      case 'system':
      case 'promotion':
      default:
        // Just mark as read, no navigation
        break;
    }
  }

  /// Get icon for notification type
  String getNotificationIcon(String type) {
    switch (type) {
      case 'new_order':
        return '🛒';
      case 'order_status_changed':
      case 'order_cancelled':
      case 'order_confirmed':
        return '📦';
      case 'support_reply':
      case 'support_status_changed':
      case 'support_closed':
      case 'new_ticket':
        return '🎫';
      case 'report_reply':
      case 'report_status_changed':
      case 'report_resolved':
      case 'new_report':
        return '📋';
      case 'new_message':
        return '💬';
      case 'system':
        return '⚙️';
      case 'promotion':
        return '🎉';
      default:
        return '🔔';
    }
  }
}
