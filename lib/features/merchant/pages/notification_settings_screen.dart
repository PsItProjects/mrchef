import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/services/merchant_settings_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _settingsService = MerchantSettingsService.instance;
  
  // Notification settings
  bool emailNotifications = true;
  bool smsNotifications = true;
  bool pushNotifications = true;
  bool orderNotifications = true;
  bool marketingNotifications = false;
  
  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }
  
  void _loadNotificationSettings() {
    final settings = _settingsService.notificationSettings.value;
    setState(() {
      emailNotifications = settings.emailNotifications;
      smsNotifications = settings.smsNotifications;
      pushNotifications = settings.pushNotifications;
      orderNotifications = settings.orderNotifications;
      marketingNotifications = settings.marketingNotifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom Header (like user screens)
          Container(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Title
                Text(
                  'notification_settings'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                // Save button
                GestureDetector(
                  onTap: _saveNotificationSettings,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'save'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
        if (_settingsService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildNotificationChannels(),
              const SizedBox(height: 24),
              _buildNotificationTypes(),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'manage_notifications'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'configure_notification_preferences'.tr,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationChannels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'notification_channels'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNotificationItem(
                icon: Icons.email_outlined,
                title: 'email_notifications'.tr,
                subtitle: 'receive_notifications_via_email'.tr,
                value: emailNotifications,
                onChanged: (value) {
                  setState(() {
                    emailNotifications = value;
                  });
                },
                iconColor: const Color(0xFF2196F3),
                isFirst: true,
              ),
              _buildNotificationItem(
                icon: Icons.sms_outlined,
                title: 'sms_notifications'.tr,
                subtitle: 'receive_notifications_via_sms'.tr,
                value: smsNotifications,
                onChanged: (value) {
                  setState(() {
                    smsNotifications = value;
                  });
                },
                iconColor: const Color(0xFF4CAF50),
              ),
              _buildNotificationItem(
                icon: Icons.notifications_outlined,
                title: 'push_notifications'.tr,
                subtitle: 'receive_push_notifications'.tr,
                value: pushNotifications,
                onChanged: (value) {
                  setState(() {
                    pushNotifications = value;
                  });
                },
                iconColor: const Color(0xFFFF9800),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotificationTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'notification_types'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNotificationItem(
                icon: Icons.shopping_cart_outlined,
                title: 'order_notifications'.tr,
                subtitle: 'new_orders_and_updates'.tr,
                value: orderNotifications,
                onChanged: (value) {
                  setState(() {
                    orderNotifications = value;
                  });
                },
                iconColor: AppColors.primaryColor,
                isFirst: true,
              ),
              _buildNotificationItem(
                icon: Icons.campaign_outlined,
                title: 'marketing_notifications'.tr,
                subtitle: 'promotions_and_offers'.tr,
                value: marketingNotifications,
                onChanged: (value) {
                  setState(() {
                    marketingNotifications = value;
                  });
                },
                iconColor: const Color(0xFF9C27B0),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        borderRadius: isFirst && isLast
            ? BorderRadius.circular(16)
            : isFirst
                ? const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  )
                : isLast
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      )
                    : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveNotificationSettings() async {
    final success = await _settingsService.updateNotificationSettings(
      emailNotifications: emailNotifications,
      smsNotifications: smsNotifications,
      pushNotifications: pushNotifications,
      orderNotifications: orderNotifications,
      marketingNotifications: marketingNotifications,
    );
    
    if (success) {
      Get.back();
    }
  }
}
