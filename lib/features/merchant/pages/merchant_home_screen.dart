import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/widgets/merchant_language_switcher.dart';
import 'package:mrsheaf/features/merchant/services/merchant_settings_service.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_dashboard_controller.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_main_controller.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:intl/intl.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({Key? key}) : super(key: key);

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  final authService = Get.find<AuthService>();
  late final MerchantDashboardController dashboardController;
  bool _isCheckingOnboarding = true;

  @override
  void initState() {
    super.initState();
    // Initialize dashboard controller
    dashboardController = Get.put(MerchantDashboardController());
    _checkOnboardingStatus();
  }

  /// Check onboarding status immediately when screen loads
  Future<void> _checkOnboardingStatus() async {
    try {
      print('🔍 MERCHANT HOME: Checking onboarding status...');

      // Initialize MerchantSettingsService - this will check onboarding
      final merchantService =
          Get.put(MerchantSettingsService(), permanent: true);

      // Try to load merchant profile - this will redirect if onboarding incomplete
      await merchantService.loadMerchantProfile();

      // If we reach here, onboarding is complete
      print('✅ MERCHANT HOME: Onboarding complete, showing dashboard');
      if (mounted) {
        setState(() {
          _isCheckingOnboarding = false;
        });
      }
    } catch (e) {
      print('❌ MERCHANT HOME: Onboarding check failed: $e');

      // Check if it's an onboarding error
      if (e.toString().contains('403') && e.toString().contains('onboarding')) {
        print(
            '🔄 MERCHANT HOME: Onboarding required - MerchantSettingsService should handle redirect');

        // Wait a bit for MerchantSettingsService to handle the redirect
        await Future.delayed(const Duration(seconds: 2));

        // If we're still here, the redirect didn't work - force redirect manually
        if (mounted) {
          print('🔄 MERCHANT HOME: Manual redirect to onboarding');
          Get.offAllNamed('/vendor-step1');
        }
      } else {
        // Unknown error - show dashboard anyway
        print('⚠️ MERCHANT HOME: Unknown error, showing dashboard');
        if (mounted) {
          setState(() {
            _isCheckingOnboarding = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking onboarding
    if (_isCheckingOnboarding) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await dashboardController.loadDashboardData();
          },
          color: AppColors.primaryColor,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Notification Bell
                _buildTopBar(),

                const SizedBox(height: 16),

                // Header
                _buildHeader(),

                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsCards(),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: 24),

                // Recent Orders
                _buildRecentOrders(),

                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      // Get restaurant data from dashboard controller
      final restaurantData = dashboardController.restaurantData.value;

      // Handle business_name as either String or Map
      String restaurantName = 'welcome_merchant'.tr;
      final businessName = restaurantData?['business_name'];
      if (businessName != null) {
        if (businessName is String) {
          restaurantName = businessName;
        } else if (businessName is Map) {
          restaurantName = TranslationHelper.isArabic
              ? (businessName['ar'] ??
                  businessName['current'] ??
                  'welcome_merchant'.tr)
              : (businessName['en'] ??
                  businessName['current'] ??
                  'welcome_merchant'.tr);
        }
      }

      final restaurantLogo = restaurantData?['logo'];

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withAlpha(217),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withAlpha(77),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Restaurant Logo or Icon
                Container(
                  padding: EdgeInsets.all(restaurantLogo != null ? 0 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(64),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withAlpha(77),
                      width: 1,
                    ),
                  ),
                  child: restaurantLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            restaurantLogo,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.store_rounded,
                                color: Colors.white,
                                size: 24,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Lato',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'manage_store_easily'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(217),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Language Switcher
                MerchantLanguageSwitcher(
                  backgroundColor: Colors.white.withAlpha(51),
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  fontSize: 11,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Build top bar with notification bell
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App Title or Welcome
        Text(
          'app_name'.tr,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDarkColor,
            fontFamily: 'Lato',
          ),
        ),
        // Notification Bell - positioned at top right/left based on language
        _buildNotificationBell(),
      ],
    );
  }

  /// Build notification bell icon with badge
  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: () {
        // Navigate to notifications
        Get.snackbar(
          'notifications'.tr,
          'coming_soon'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryColor,
              size: 24,
            ),
            // Badge for unread notifications
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      // Show loading state
      if (dashboardController.isLoading.value) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCardSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCardSkeleton()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCardSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCardSkeleton()),
              ],
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Stats Header
          Text(
            'today_stats'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: 'Lato',
            ),
          ),
          const SizedBox(height: 12),
          // Today Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'orders_today'.tr,
                  value: '${dashboardController.todayOrders.value}',
                  icon: Icons.shopping_cart_rounded,
                  color: const Color(0xFF2196F3),
                  backgroundColor: const Color(0xFFE3F2FD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'sales_today'.tr,
                  value: TranslationHelper.formatCurrency(
                      dashboardController.todayRevenue.value),
                  icon: Icons.monetization_on_rounded,
                  color: const Color(0xFF4CAF50),
                  backgroundColor: const Color(0xFFE8F5E9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Week's Stats Header
          Text(
            'this_week'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: 'Lato',
            ),
          ),
          const SizedBox(height: 12),
          // Week Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'weekly_orders'.tr,
                  value: '${dashboardController.weekOrders.value}',
                  icon: Icons.calendar_today_rounded,
                  color: const Color(0xFF9C27B0),
                  backgroundColor: const Color(0xFFF3E5F5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'weekly_sales'.tr,
                  value: TranslationHelper.formatCurrency(
                      dashboardController.weekRevenue.value),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFFFF9800),
                  backgroundColor: const Color(0xFFFFF3E0),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              // Trend indicator (placeholder)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 12,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '+5%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'Lato',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_actions'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontFamily: 'Lato',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'add_product'.tr,
                icon: Icons.add_circle_outline_rounded,
                color: const Color(0xFFFF9800),
                backgroundColor: const Color(0xFFFFF3E0),
                onTap: () {
                  Get.toNamed('/merchant/products/add');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'manage_products'.tr,
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF9C27B0),
                backgroundColor: const Color(0xFFF3E5F5),
                onTap: () {
                  Get.toNamed('/merchant/products');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontFamily: 'Lato',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'recent_orders'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                  fontFamily: 'Lato',
                ),
              ),
              if (dashboardController.recentOrders.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // Navigate to orders tab
                    final mainController = Get.find<MerchantMainController>();
                    mainController.changeTab(1); // Switch to Orders tab
                  },
                  child: Text(
                    'see_all'.tr,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: dashboardController.isLoading.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : dashboardController.recentOrders.isEmpty
                    ? _buildEmptyOrders()
                    : Column(
                        children: List.generate(
                          dashboardController.recentOrders.length > 5
                              ? 5
                              : dashboardController.recentOrders.length,
                          (index) {
                            final order =
                                dashboardController.recentOrders[index];
                            return Column(
                              children: [
                                if (index > 0)
                                  Divider(
                                    height: 1,
                                    color: Colors.grey.withAlpha(51),
                                  ),
                                _buildOrderItem(
                                  order,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyOrders() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'no_orders_yet'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'Lato',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TranslationHelper.isArabic
                ? 'ستظهر الطلبات هنا عندما يبدأ العملاء بالطلب'
                : 'Orders will appear here when customers start ordering',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Lato',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getOrderStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TranslationHelper.isArabic ? 'جديد' : 'New';
      case 'confirmed':
        return TranslationHelper.isArabic ? 'مؤكد' : 'Confirmed';
      case 'preparing':
        return TranslationHelper.isArabic ? 'قيد التحضير' : 'Preparing';
      case 'ready':
        return TranslationHelper.isArabic ? 'جاهز' : 'Ready';
      case 'delivered':
        return TranslationHelper.isArabic ? 'مكتمل' : 'Delivered';
      case 'cancelled':
        return TranslationHelper.isArabic ? 'ملغي' : 'Cancelled';
      default:
        return status;
    }
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final orderId = order['id']?.toString() ?? '';

    // Handle order_number as either String or Map
    String orderNumber = '#$orderId';
    final orderNum = order['order_number'];
    if (orderNum != null) {
      if (orderNum is String) {
        orderNumber = orderNum;
      } else if (orderNum is Map) {
        orderNumber = orderNum['current']?.toString() ??
            orderNum['en']?.toString() ??
            '#$orderId';
      }
    }

    final amount =
        TranslationHelper.formatCurrency(_parseDouble(order['total_amount']));
    final status = order['status']?.toString() ?? 'pending';
    final statusText = _getOrderStatusText(status);
    final statusColor = _getOrderStatusColor(status);

    // Parse customer name
    final customer = order['customer'];
    String customerName = 'customer'.tr;
    if (customer != null) {
      if (customer is Map) {
        final name = customer['name'];
        if (name is String) {
          customerName = name;
        } else if (name is Map) {
          customerName = name['current']?.toString() ??
              name['en']?.toString() ??
              'customer'.tr;
        } else {
          customerName = customer['full_name']?.toString() ??
              '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'
                  .trim();
        }
      } else if (customer is String) {
        customerName = customer;
      }
    }

    // Parse order time
    String orderTime = '';
    if (order['created_at'] != null) {
      try {
        final dateTime = DateTime.parse(order['created_at'].toString());
        orderTime = DateFormat('HH:mm').format(dateTime);
      } catch (e) {
        orderTime = '';
      }
    }

    return InkWell(
      onTap: () {
        // Navigate to order details
        Get.toNamed(
          '/merchant/order-details',
          arguments: {'orderId': int.parse(orderId)},
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Order icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderNumber,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          customerName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (orderTime.isNotEmpty)
                        Text(
                          orderTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow
            Icon(
              TranslationHelper.isRTL
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// Parse dynamic value to double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
