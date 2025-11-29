import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_statistics_controller.dart';
import 'package:mrsheaf/features/merchant/widgets/statistics_filter_modal.dart';

class MerchantStatisticsScreen extends StatelessWidget {
  const MerchantStatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantStatisticsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        if (controller.hasError.value) {
          return _buildErrorState(controller);
        }
        return RefreshIndicator(
          onRefresh: controller.loadStatistics,
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterInfo(controller),
                const SizedBox(height: 16),
                _buildMainStats(controller),
                const SizedBox(height: 16),
                _buildOrderStatusCards(controller),
                const SizedBox(height: 16),
                _buildComparisonCard(controller),
                const SizedBox(height: 16),
                _buildTopProductsCard(controller),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(MerchantStatisticsController controller) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      title: Text(
        'statistics'.tr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
          onPressed: () => _showFilterModal(controller),
        ),
      ],
    );
  }

  void _showFilterModal(MerchantStatisticsController controller) {
    Get.bottomSheet(
      StatisticsFilterModal(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }

  Widget _buildErrorState(MerchantStatisticsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'error_loading_statistics'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.loadStatistics,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInfo(MerchantStatisticsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.filterLabel.isNotEmpty
                  ? controller.filterLabel
                  : controller.getFilterName(controller.selectedFilter.value),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showFilterModal(controller),
            child: Text(
              'change'.tr,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats(MerchantStatisticsController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'total_orders'.tr,
            value: '${controller.totalOrders}',
            icon: Icons.shopping_cart_rounded,
            color: const Color(0xFF2196F3),
            backgroundColor: const Color(0xFFE3F2FD),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'total_revenue'.tr,
            value: TranslationHelper.formatCurrency(controller.totalRevenue),
            icon: Icons.monetization_on_rounded,
            color: const Color(0xFF4CAF50),
            backgroundColor: const Color(0xFFE8F5E9),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusCards(MerchantStatisticsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'order_status'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                title: 'completed'.tr,
                value: '${controller.completedOrders}',
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStatCard(
                title: 'pending'.tr,
                value: '${controller.pendingOrders}',
                color: const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStatCard(
                title: 'cancelled'.tr,
                value: '${controller.cancelledOrders}',
                color: const Color(0xFFF44336),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(MerchantStatisticsController controller) {
    final ordersChange = controller.ordersChange;
    final revenueChange = controller.revenueChange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'comparison_with_previous'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComparisonItem(
                  title: 'orders'.tr,
                  change: ordersChange,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildComparisonItem(
                  title: 'revenue'.tr,
                  change: revenueChange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem({required String title, required double change}) {
    final isPositive = change >= 0;
    final color =
        isPositive ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsCard(MerchantStatisticsController controller) {
    final topProducts = controller.topProducts ?? [];

    if (topProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'top_products'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          ...topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            final name = product['name'] is Map
                ? (product['name']['ar'] ?? product['name']['en'] ?? 'Product')
                : product['name'] ?? 'Product';
            return _buildProductItem(
              rank: index + 1,
              name: name,
              quantity: product['quantity'] ?? 0,
              revenue: (product['revenue'] ?? 0).toDouble(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required int rank,
    required String name,
    required int quantity,
    required double revenue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${'sold'.tr}: $quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            TranslationHelper.formatCurrency(revenue),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primaryColor;
    }
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
