import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_order_details_controller.dart';

class MerchantOrderDetailsScreen extends StatelessWidget {
  MerchantOrderDetailsScreen({super.key}) {
    Get.put(MerchantOrderDetailsController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantOrderDetailsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(controller);
        }

        final order = controller.order.value;
        if (order == null) {
          return _buildErrorState(controller);
        }

        return RefreshIndicator(
          onRefresh: controller.loadOrderDetails,
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order, controller),
                const SizedBox(height: 16),
                _buildCustomerInfo(order),
                const SizedBox(height: 16),
                _buildOrderItems(order),
                const SizedBox(height: 16),
                _buildOrderSummary(order),
                const SizedBox(height: 16),
                _buildDeliveryInfo(order),
                const SizedBox(height: 16),
                _buildActionButtons(controller, order),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(MerchantOrderDetailsController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          TranslationHelper.isRTL
              ? Icons.arrow_forward_ios
              : Icons.arrow_back_ios,
          color: AppColors.textDarkColor,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final order = controller.order.value;
        String orderTitle = 'order_details'.tr;
        if (order != null) {
          final orderNum = order['order_number'];
          if (orderNum is String) {
            orderTitle = orderNum;
          } else if (orderNum is Map) {
            orderTitle = orderNum['current']?.toString() ??
                orderNum['en']?.toString() ??
                '#${order['id']}';
          } else {
            orderTitle = '#${order['id']}';
          }
        }
        return Text(
          orderTitle,
          style: const TextStyle(
            color: AppColors.textDarkColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
      }),
      actions: [
        Obx(() {
          if (controller.hasConversation) {
            return IconButton(
              icon: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.primaryColor),
              onPressed: controller.openChatWithCustomer,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildErrorState(MerchantOrderDetailsController controller) {
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.loadOrderDetails,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(
      Map<String, dynamic> order, MerchantOrderDetailsController controller) {
    final status = order['status'] ?? 'pending';
    final statusColor = controller.getStatusColor(status);
    final createdAt = order['created_at'] != null
        ? DateTime.tryParse(order['created_at'].toString())
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('order_number'.tr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(_getOrderNumber(order),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              _buildStatusDropdown(order, controller, status, statusColor),
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy - HH:mm').format(createdAt),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(
      Map<String, dynamic> order,
      MerchantOrderDetailsController controller,
      String status,
      Color statusColor) {
    final isTerminalStatus =
        ['delivered', 'cancelled', 'rejected'].contains(status.toLowerCase());

    if (isTerminalStatus) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          controller.getStatusText(status),
          style: TextStyle(
              fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Obx(() {
      if (controller.isUpdatingStatus.value) {
        return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2));
      }

      return PopupMenuButton<String>(
        onSelected: (newStatus) =>
            _showStatusChangeDialog(controller, newStatus),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withAlpha(51)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.getStatusText(status),
                  style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: statusColor, size: 20),
            ],
          ),
        ),
        itemBuilder: (context) {
          return controller.availableStatuses
              .where((s) => s != status)
              .map((s) {
            final color = controller.getStatusColor(s);
            return PopupMenuItem<String>(
              value: s,
              child: Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(controller.getStatusText(s)),
                ],
              ),
            );
          }).toList();
        },
      );
    });
  }

  void _showStatusChangeDialog(
      MerchantOrderDetailsController controller, String newStatus) {
    if (newStatus == 'cancelled') {
      Get.dialog(
        AlertDialog(
          title: Text('cancel_order'.tr),
          content: Text('confirm_cancel_order'.tr),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('no'.tr)),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.updateOrderStatus(newStatus);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('yes'.tr),
            ),
          ],
        ),
      );
    } else {
      controller.updateOrderStatus(newStatus);
    }
  }

  Widget _buildCustomerInfo(Map<String, dynamic> order) {
    final customerData = order['customer'];
    if (customerData == null) return const SizedBox.shrink();

    // Handle customer as Map
    Map<String, dynamic>? customer;
    if (customerData is Map<String, dynamic>) {
      customer = customerData;
    } else if (customerData is Map) {
      customer = Map<String, dynamic>.from(customerData);
    } else {
      return const SizedBox.shrink();
    }

    // Handle name - could be String or Map
    String name = 'customer'.tr;
    final nameData = customer['name'];
    if (nameData is String) {
      name = nameData;
    } else if (nameData is Map) {
      name = nameData['current']?.toString() ??
          nameData['en']?.toString() ??
          'customer'.tr;
    } else {
      name = customer['full_name']?.toString() ??
          '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'
              .trim();
    }
    if (name.isEmpty) name = 'customer'.tr;

    final phone = customer['phone']?.toString() ?? '';
    final email = customer['email']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('customer_info'.tr,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Divider(),
          _buildInfoRow(Icons.person_outline, name),
          if (phone.isNotEmpty) _buildInfoRow(Icons.phone_outlined, phone),
          if (email.isNotEmpty) _buildInfoRow(Icons.email_outlined, email),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _buildOrderItems(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('order_items'.tr,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text('${items.length} ${'items'.tr}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
          const Divider(),
          ...items
              .map((item) => _buildOrderItemRow(item as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(Map<String, dynamic> item) {
    final name = TranslationHelper.isArabic
        ? (item['product_name_ar'] ??
            item['product_name'] ??
            item['name'] ??
            '')
        : (item['product_name_en'] ??
            item['product_name'] ??
            item['name'] ??
            '');
    final quantity = item['quantity'] ?? 1;
    final price = _parseDouble(item['unit_price'] ?? item['price']);
    final total = _parseDouble(
        item['total'] ?? item['total_price'] ?? (price * quantity));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
                child: Text('$quantity',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
          Text(TranslationHelper.formatCurrency(total),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Map<String, dynamic> order) {
    final subtotal = _parseDouble(order['subtotal']);
    final deliveryFee = _parseDouble(order['delivery_fee']);
    final discount = _parseDouble(order['discount']);
    final total = _parseDouble(order['total_amount'] ?? order['total']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('order_summary'.tr,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Divider(),
          _buildSummaryRow(
              'subtotal'.tr, TranslationHelper.formatCurrency(subtotal)),
          _buildSummaryRow(
              'delivery_fee'.tr, TranslationHelper.formatCurrency(deliveryFee)),
          if (discount > 0)
            _buildSummaryRow(
                'discount'.tr, '-${TranslationHelper.formatCurrency(discount)}',
                isDiscount: true),
          const Divider(),
          _buildSummaryRow('total'.tr, TranslationHelper.formatCurrency(total),
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey[700],
              )),
          Text(value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isDiscount
                    ? Colors.green
                    : (isTotal ? AppColors.primaryColor : Colors.grey[800]),
              )),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(Map<String, dynamic> order) {
    final address = order['delivery_address'] ?? order['address'];
    if (address == null) return const SizedBox.shrink();

    String addressText = '';
    if (address is Map) {
      addressText = address['full_address'] ??
          address['address'] ??
          '${address['street'] ?? ''}, ${address['city'] ?? ''}'.trim();
    } else if (address is String) {
      addressText = address;
    }

    final notes = order['notes'] ?? order['delivery_notes'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('delivery_info'.tr,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Divider(),
          if (addressText.isNotEmpty)
            _buildInfoRow(Icons.location_on_outlined, addressText),
          if (notes.isNotEmpty) _buildInfoRow(Icons.note_outlined, notes),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      MerchantOrderDetailsController controller, Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final hasConversation = order['conversation'] != null;

    return Column(
      children: [
        if (hasConversation)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.openChatWithCustomer,
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text('chat_with_customer'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (!['delivered', 'cancelled', 'rejected']
            .contains(status.toLowerCase())) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showStatusChangeDialog(controller, 'cancelled'),
              icon: const Icon(Icons.cancel_outlined),
              label: Text('cancel_order'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Get order number handling both String and Map types
  String _getOrderNumber(Map<String, dynamic> order) {
    final orderNum = order['order_number'];
    if (orderNum is String) {
      return orderNum;
    } else if (orderNum is Map) {
      return orderNum['current']?.toString() ??
          orderNum['en']?.toString() ??
          '#${order['id']}';
    }
    return '#${order['id']}';
  }
}
