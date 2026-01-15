import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_notifications_controller.dart';
import 'package:mrsheaf/features/notifications/controllers/notifications_controller.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message received: ${message.messageId}');
}

class FCMService extends GetxService {
  static FCMService get instance => Get.find<FCMService>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _deviceToken;
  String get deviceToken => _deviceToken ?? '';

  // Track current conversation for real-time messaging
  int? _currentConversationId;

  /// Initialize FCM Service
  Future<FCMService> init() async {
    await _requestPermissions();
    await _initLocalNotifications();
    await _getAndRegisterToken();
    _setupMessageHandlers();
    return this;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('🔔 FCM Permission status: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications for foreground
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Get FCM token and register with backend
  Future<void> _getAndRegisterToken() async {
    try {
      _deviceToken = await _messaging.getToken();
      print('🔔 FCM Token: $_deviceToken');

      if (_deviceToken != null) {
        await _registerTokenWithBackend();
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _deviceToken = newToken;
        _registerTokenWithBackend();
      });
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Register token with backend
  Future<void> _registerTokenWithBackend() async {
    if (_deviceToken == null) return;

    try {
      final apiClient = Get.find<ApiClient>();
      final language = Get.find<LanguageService>().currentLanguage;

      await apiClient.post('/device/register-token', data: {
        'device_token': _deviceToken,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
        'device_name': Platform.localHostname,
        'language': language,
      });
      print('✅ Device token registered with backend (lang: $language)');
    } catch (e) {
      print('❌ Error registering token: $e');
    }
  }

  /// Update device language when user changes language
  Future<void> updateLanguage(String language) async {
    if (_deviceToken == null) return;

    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.post('/device/update-language', data: {
        'device_token': _deviceToken,
        'language': language,
      });
      print('✅ Device language updated to: $language');
    } catch (e) {
      print('❌ Error updating language: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // When app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Foreground message: ${message.notification?.title}');

    final data = message.data;
    final type = data['type'] ?? '';

    // Don't show notification if user is in the same chat
    if (type == 'new_message') {
      final conversationId = int.tryParse(data['conversation_id'] ?? '');
      if (conversationId == _currentConversationId) {
        return; // User is in this chat, don't show notification
      }
    }

    // Don't show notification if user is viewing this support ticket
    if (type == 'support_reply' || type == 'support_status_changed') {
      final ticketId = data['ticket_id']?.toString();
      if (ticketId != null && Get.currentRoute.contains('/support/tickets/$ticketId')) {
        // Just trigger refresh, don't show notification
        _refreshSupportTicketDetail();
        return;
      }
    }

    // Show local notification
    _showLocalNotification(message);

    // Trigger notifications screen refresh for system notifications
    if (type == 'system' ||
        type == 'promotion' ||
        type == 'new_order' ||
        type == 'order_status_changed' ||
        type == 'support_reply' ||
        type == 'support_status_changed' ||
        type == 'support_closed') {
      _triggerNotificationsRefresh();
    }
  }

  /// Trigger notifications screen refresh
  void _triggerNotificationsRefresh() {
    // Notify any listening controllers to refresh using GetX
    _refreshMerchantNotifications();
    _refreshCustomerNotifications();
  }

  void _refreshMerchantNotifications() {
    try {
      if (Get.isRegistered<MerchantNotificationsController>(
          tag: MerchantNotificationsController.tag)) {
        final controller = Get.find<MerchantNotificationsController>(
            tag: MerchantNotificationsController.tag);
        controller.refreshNotifications();
      }
    } catch (_) {
      // Controller not registered, ignore
    }
  }

  void _refreshCustomerNotifications() {
    try {
      if (Get.isRegistered<NotificationsController>(
          tag: NotificationsController.tag)) {
        final controller =
            Get.find<NotificationsController>(tag: NotificationsController.tag);
        controller.refreshNotifications();
      }
    } catch (_) {
      // Controller not registered, ignore
    }
  }

  /// Refresh support ticket detail if viewing
  void _refreshSupportTicketDetail() {
    try {
      // The controller will auto-refresh via polling, but we can trigger immediate refresh
      // by checking if SupportTicketDetailController is registered
      print('🔔 Support ticket update received - auto-refresh active');
    } catch (_) {
      // Controller not registered, ignore
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap from background/terminated
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? '';

    _navigateBasedOnType(type, data);
  }

  /// Handle notification tap from local notification
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    
    if (response.payload == null || response.payload!.isEmpty) return;
    
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final type = data['type'] ?? '';
      _navigateBasedOnType(type, data);
    } catch (e) {
      print('❌ Error parsing notification payload: $e');
    }
  }

  /// Navigate based on notification type
  void _navigateBasedOnType(String type, Map<String, dynamic> data) {
    final orderId = data['order_id'];
    final ticketId = data['ticket_id'];
    final reportId = data['report_id'];
    final conversationId = data['conversation_id'];
    final recipientType = data['recipient_type'];
    
    print('🔔 Merchant Notification tap: type=$type, orderId=$orderId, ticketId=$ticketId, reportId=$reportId');
    
    // Determine if user is merchant or customer
    final isMerchant = recipientType == 'merchant';
    
    switch (type) {
      // Order notifications (both merchant and customer)
      case 'new_order':
        // Merchant receives new order
        if (orderId != null) {
          Get.toNamed('/merchant/order-details', arguments: {'orderId': int.tryParse(orderId.toString())});
        }
        break;
      
      case 'order_status_changed':
      case 'order_confirmed':
      case 'order_preparing':
      case 'order_ready':
      case 'order_out_for_delivery':
      case 'order_delivered':
      case 'delivery_confirmed':
      case 'confirm_delivery_required':
      case 'order_completed':
      case 'order_cancelled':
      case 'order_rejected':
        if (orderId != null) {
          // Customer order details
          Get.toNamed('/orders/${orderId.toString()}');
        }
        break;
      
      // Chat notifications
      case 'new_message':
        if (conversationId != null) {
          if (isMerchant) {
            // Merchant chat screen
            Get.toNamed('/merchant/chat', arguments: {'conversationId': int.tryParse(conversationId.toString())});
          } else {
            // Customer chat screen
            Get.toNamed('/chat', arguments: {'conversationId': int.tryParse(conversationId.toString())});
          }
        }
        break;
      
      // Support ticket notifications (both merchant and customer)
      case 'support_reply':
      case 'support_status_changed':
      case 'support_closed':
      case 'new_ticket':
        if (ticketId != null) {
          Get.toNamed('/support/tickets/${ticketId.toString()}');
        }
        break;
      
      // Report notifications (both merchant and customer)
      case 'report_reply':
      case 'report_status_changed':
      case 'report_resolved':
      case 'new_report':
        if (reportId != null) {
          Get.toNamed('/support/reports/${reportId.toString()}');
        }
        break;
      
      // General notifications
      case 'system':
      case 'promotion':
      case 'announcement':
        // Navigate to appropriate notifications screen
        if (isMerchant) {
          Get.toNamed('/merchant/notifications');
        } else {
          Get.toNamed('/notifications');
        }
        break;
      
      default:
        // Default navigation based on user type
        if (isMerchant) {
          Get.toNamed('/merchant/notifications');
        } else {
          Get.toNamed('/notifications');
        }
        break;
    }
  }

  /// Associate token with authenticated user
  Future<void> associateWithUser() async {
    if (_deviceToken == null) return;

    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.post('/device/associate', data: {
        'device_token': _deviceToken,
      });
      print('✅ Device token associated with user');
    } catch (e) {
      print('❌ Error associating token: $e');
    }
  }

  /// Enter chat (for real-time - don't send notifications for this chat)
  Future<void> enterChat(int conversationId) async {
    _currentConversationId = conversationId;

    if (_deviceToken == null) return;

    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.post('/device/enter-chat', data: {
        'device_token': _deviceToken,
        'conversation_id': conversationId,
      });
    } catch (e) {
      print('❌ Error entering chat: $e');
    }
  }

  /// Leave chat
  Future<void> leaveChat() async {
    _currentConversationId = null;

    if (_deviceToken == null) return;

    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.post('/device/leave-chat', data: {
        'device_token': _deviceToken,
      });
    } catch (e) {
      print('❌ Error leaving chat: $e');
    }
  }

  /// Deactivate token on logout
  Future<void> deactivate() async {
    if (_deviceToken == null) return;

    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.post('/device/deactivate', data: {
        'device_token': _deviceToken,
      });
      print('✅ Device token deactivated');
    } catch (e) {
      print('❌ Error deactivating token: $e');
    }
  }
}
