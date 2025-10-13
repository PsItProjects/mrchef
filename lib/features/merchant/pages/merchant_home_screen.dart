import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/auth/services/auth_service.dart';
import 'package:mrsheaf/core/widgets/merchant_language_switcher.dart';
import 'package:mrsheaf/features/merchant/services/merchant_settings_service.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_dashboard_controller.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_main_controller.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';

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
      final merchantService = Get.put(MerchantSettingsService(), permanent: true);

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
        print('🔄 MERCHANT HOME: Onboarding required - MerchantSettingsService should handle redirect');

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
    
    return Directionality(
      textDirection: TranslationHelper.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 30),
              
              // Stats Cards
              _buildStatsCards(),
              
              const SizedBox(height: 30),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: 30),
              
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome_merchant'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Lato',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'manage_store_easily'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.85),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          MerchantLanguageSwitcher(
            backgroundColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
            iconColor: Colors.white,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      // Show loading state
      if (dashboardController.isLoading.value) {
        return Row(
          children: [
            Expanded(child: _buildStatCardSkeleton()),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCardSkeleton()),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'orders_today'.tr,
              value: '${dashboardController.todayOrders.value}',
              subtitle: 'orders_today'.tr,
              icon: Icons.shopping_cart_rounded,
              color: const Color(0xFF2196F3),
              backgroundColor: const Color(0xFFE3F2FD),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'sales_amount'.tr,
              value: TranslationHelper.formatCurrency(dashboardController.todayRevenue.value),
              subtitle: TranslationHelper.isArabic ? 'ر.س' : 'SAR',
              icon: Icons.monetization_on_rounded,
              color: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E8),
            ),
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
            color: Colors.black.withOpacity(0.05),
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
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(height: 16),

          // Value and subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontFamily: 'Lato',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Lato',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              fontSize: 14,
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
            // Add Product & Manage Products - Hidden until implemented
            // Expanded(
            //   child: _buildActionCard(
            //     title: 'إضافة منتج',
            //     icon: Icons.add_circle_outline_rounded,
            //     color: const Color(0xFFFF9800),
            //     backgroundColor: const Color(0xFFFFF3E0),
            //     onTap: () {
            //       // TODO: Navigate to add product screen
            //     },
            //   ),
            // ),
            // const SizedBox(width: 16),
            // Expanded(
            //   child: _buildActionCard(
            //     title: 'إدارة المنتجات',
            //     icon: Icons.inventory_2_outlined,
            //     color: const Color(0xFF9C27B0),
            //     backgroundColor: const Color(0xFFF3E5F5),
            //     onTap: () {
            //       // TODO: Navigate to manage products screen
            //     },
            //   ),
            // ),
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
              color: Colors.black.withOpacity(0.08),
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
                style: TextStyle(
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
                    style: TextStyle(
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
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
                          dashboardController.recentOrders.length > 3
                              ? 3
                              : dashboardController.recentOrders.length,
                          (index) {
                            final order = dashboardController.recentOrders[index];
                            return Column(
                              children: [
                                if (index > 0) const Divider(),
                                _buildOrderItem(
                                  '#${order['id'] ?? ''}',
                                  TranslationHelper.formatCurrency(
                                    (order['total_amount'] ?? 0).toDouble()
                                  ),
                                  _getOrderStatusText(order['status'] ?? 'pending'),
                                  _getOrderStatusColor(order['status'] ?? 'pending'),
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

  Widget _buildOrderItem(String orderNumber, String amount, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              orderNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
