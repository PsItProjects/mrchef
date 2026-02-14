import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_orders_controller.dart';
import 'package:mrsheaf/features/merchant/widgets/price_confirmation_modal.dart';

class MerchantOrdersScreen extends GetView<MerchantOrdersController> {
  const MerchantOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Filter Tabs
            _buildFilterTabs(),

            // Orders List
            Expanded(
              child: _buildOrdersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'orders'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
          const Spacer(),
          Obx(() {
            final count = controller.pendingOrdersCount.value;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                TranslationHelper.isArabic
                    ? '$count طلبات جديدة'
                    : '$count new orders',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() => Row(
              children: List.generate(
                controller.filterLabels.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                      right: TranslationHelper.isRTL ? 0 : 10,
                      left: TranslationHelper.isRTL ? 10 : 0),
                  child: _buildFilterTab(
                    controller.getFilterLabel(index),
                    controller.selectedFilterIndex.value == index,
                    () => controller.changeFilter(index),
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? AppColors.secondaryColor : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'no_orders'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshOrders,
        color: AppColors.primaryColor,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                !controller.isLoadingMore.value) {
              controller.loadMoreOrders();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.orders.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                        color: AppColors.primaryColor),
                  ),
                );
              }
              return _buildOrderCard(controller.orders[index]);
            },
          ),
        ),
      );
    });
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'];
    final status = order['status']?.toString() ?? 'pending';
    final statusColor = controller.getStatusColor(status);
    final statusText = controller.getStatusText(status);

    // Parse order number
    String orderNumber = '#$orderId';
    final orderNum = order['order_number'];
    if (orderNum is String) {
      orderNumber = orderNum;
    } else if (orderNum is Map) {
      orderNumber = orderNum['current']?.toString() ??
          orderNum['en']?.toString() ??
          '#$orderId';
    }

    // Parse customer name
    String customerName = 'customer_name'.tr;
    final customer = order['customer'];
    if (customer is Map) {
      final nameData = customer['name'];
      if (nameData is String) {
        customerName = nameData;
      } else if (nameData is Map) {
        customerName = nameData['current']?.toString() ??
            (TranslationHelper.isArabic
                ? nameData['ar']?.toString()
                : nameData['en']?.toString()) ??
            'customer_name'.tr;
      } else {
        customerName = customer['full_name']?.toString() ?? 'customer_name'.tr;
      }
    }

    // Parse items count
    final items = order['items'];
    int itemsCount = 0;
    if (items is List) {
      itemsCount = items.length;
    } else if (order['items_count'] != null) {
      itemsCount = int.tryParse(order['items_count'].toString()) ?? 0;
    }

    // Parse total amount
    double totalAmount = 0;
    final total = order['total_amount'] ?? order['agreed_price'];
    if (total != null) {
      totalAmount = double.tryParse(total.toString()) ?? 0;
    }

    // Parse created_at
    DateTime? createdAt;
    if (order['created_at'] != null) {
      createdAt = DateTime.tryParse(order['created_at'].toString());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: Column(
        children: [
          // Order header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${TranslationHelper.isArabic ? 'طلب' : 'Order'} $orderNumber',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        customerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Order details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    TranslationHelper.isArabic
                        ? '$itemsCount عناصر'
                        : '$itemsCount items',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 20),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    createdAt != null
                        ? DateFormat('HH:mm').format(createdAt)
                        : '--:--',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              Text(
                '${totalAmount.toStringAsFixed(2)} ${TranslationHelper.isArabic ? 'ر.س' : 'SAR'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.openOrderDetails(orderId),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'view_details'.tr,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // Only show Update Status button if order is not in final state
              if (!['delivered', 'completed', 'cancelled', 'rejected'].contains(status)) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showStatusUpdateModal(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'update_status'.tr,
                      style: const TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              // Show awaiting confirmation text for delivered orders
              if (status == 'delivered') ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warningColor),
                    ),
                    child: Text(
                      'awaiting_customer_confirmation'.tr,
                      style: const TextStyle(
                        color: AppColors.warningColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              // Show awaiting price approval text for awaiting_customer_approval orders
              if (status == 'awaiting_customer_approval') ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      TranslationHelper.isArabic
                          ? 'بانتظار موافقة العميل'
                          : 'Awaiting Approval',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateModal(Map<String, dynamic> order) {
    final orderId = order['id'];
    final currentStatus = order['status']?.toString() ?? 'pending';
    final totalAmount =
        double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0;

    // If order is pending, show price confirmation modal to set price and await customer approval
    if (currentStatus == 'pending') {
      PriceConfirmationModal.show(
        context: Get.context!,
        orderNumber: _getOrderNumber(order),
        defaultPrice: totalAmount,
        deliveryFeeType:
            order['restaurant']?['delivery_fee_type']?.toString() ??
                order['delivery_fee_type']?.toString() ??
                'negotiable',
        onConfirm: (agreedPrice, agreedDeliveryFee) async {
          final success = await controller.updateOrderStatus(
            orderId,
            'awaiting_customer_approval',
            agreedPrice: agreedPrice,
            agreedDeliveryFee: agreedDeliveryFee,
          );
          if (success) {
            Get.back();
          }
        },
      );
    } else {
      // Show regular status update dialog
      _showStatusSelectionDialog(order);
    }
  }

  String _getOrderNumber(Map<String, dynamic> order) {
    final orderNum = order['order_number'];
    if (orderNum is String) return orderNum;
    if (orderNum is Map) {
      return orderNum['current']?.toString() ??
          orderNum['en']?.toString() ??
          '#${order['id']}';
    }
    return '#${order['id']}';
  }

  void _showStatusSelectionDialog(Map<String, dynamic> order) {
    final orderId = order['id'];
    final currentStatus = order['status']?.toString() ?? 'pending';

    // Get next possible statuses
    final nextStatuses = _getNextStatuses(currentStatus);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'update_status'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...nextStatuses.map((status) => ListTile(
                  leading: Icon(
                    _getStatusIcon(status),
                    color: controller.getStatusColor(status),
                  ),
                  title: Text(controller.getStatusText(status)),
                  onTap: () async {
                    Get.back();
                    await controller.updateOrderStatus(orderId, status);
                  },
                )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  List<String> _getNextStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['awaiting_customer_approval', 'confirmed', 'rejected'];
      case 'awaiting_customer_approval':
        // Merchant CANNOT advance — must wait for customer to accept/reject
        return ['cancelled'];
      case 'confirmed':
        return ['preparing', 'cancelled'];
      case 'preparing':
        return ['ready', 'cancelled'];
      case 'ready':
        return ['out_for_delivery', 'delivered'];
      case 'out_for_delivery':
        return ['delivered'];
      default:
        return [];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'awaiting_customer_approval':
        return Icons.hourglass_bottom_rounded;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.done_all;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'rejected':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }
}
