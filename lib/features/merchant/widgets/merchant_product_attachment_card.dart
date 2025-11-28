import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/features/merchant/widgets/price_confirmation_modal.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_chat_controller.dart';

class MerchantProductAttachmentCard extends StatelessWidget {
  final Map<String, dynamic> attachments;
  final Map<String, dynamic>? orderData;
  final bool canApprove;
  final bool isUpdating;
  final Function(String status, {double? agreedPrice})? onStatusChange;
  // New: for per-order status management
  final Function(int orderId, String status, {double? agreedPrice})?
      onOrderStatusChange;

  const MerchantProductAttachmentCard({
    super.key,
    required this.attachments,
    this.orderData,
    this.canApprove = false,
    this.isUpdating = false,
    this.onStatusChange,
    this.onOrderStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final items = attachments['items'] as List<dynamic>? ?? [];
    final totalAmount = attachments['total_amount'] ?? 0;
    final itemCount = attachments['item_count'] ?? items.length;
    final orderId = attachments['order_id'];
    final requestNumber = attachments['request_number'];

    // Get order status from attachments first, then from orderData
    String orderStatus = attachments['status']?.toString() ?? 'pending';

    // If we have orderId, try to get status from controller
    if (orderId != null && Get.isRegistered<MerchantChatController>()) {
      final controller = Get.find<MerchantChatController>();
      final storedStatus = controller.getOrderStatus(orderId);
      if (storedStatus != null) {
        orderStatus = storedStatus;
      }
    }

    // Fallback to orderData if available
    if (orderData != null) {
      orderStatus = orderData!['status']?.toString() ?? orderStatus;
    }

    final agreedPrice = orderData?['agreed_price'];

    // Check if this specific order is being updated
    bool isThisOrderUpdating = isUpdating;
    if (orderId != null && Get.isRegistered<MerchantChatController>()) {
      final controller = Get.find<MerchantChatController>();
      isThisOrderUpdating = controller.isOrderUpdating(orderId);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(
              isArabic, itemCount, orderId, requestNumber, orderStatus),

          // Items list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items
                  .map((item) => _buildProductItem(item, isArabic))
                  .toList(),
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: AppColors.primaryColor.withOpacity(0.2),
              height: 1,
              thickness: 1,
            ),
          ),

          // Total section
          _buildTotalSection(isArabic, totalAmount, agreedPrice),

          // Action buttons (approve/reject) - only for pending orders
          if (orderStatus == 'pending')
            _buildActionButtons(
                isArabic, totalAmount, orderId, isThisOrderUpdating),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isArabic, int itemCount, dynamic orderId,
      dynamic requestNumber, String orderStatus) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.15),
            AppColors.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                const Icon(Icons.receipt_long, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isArabic ? 'تفاصيل الطلب' : 'Order Details',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF262626),
                      ),
                    ),
                    if (orderId != null) ...[
                      const SizedBox(width: 8),
                      _buildBadge('#$orderId', const Color(0xFF4CAF50)),
                    ] else if (requestNumber != null) ...[
                      const SizedBox(width: 8),
                      _buildBadge('#$requestNumber', AppColors.primaryColor),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isArabic
                      ? '$itemCount ${itemCount == 1 ? 'منتج' : 'منتجات'}'
                      : '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          _buildStatusBadge(orderStatus),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    final isArabic = Get.locale?.languageCode == 'ar';

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = isArabic ? 'قيد الانتظار' : 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        text = isArabic ? 'مؤكد' : 'Confirmed';
        break;
      case 'preparing':
        color = Colors.purple;
        text = isArabic ? 'قيد التحضير' : 'Preparing';
        break;
      case 'ready':
        color = Colors.teal;
        text = isArabic ? 'جاهز' : 'Ready';
        break;
      case 'out_for_delivery':
        color = Colors.indigo;
        text = isArabic ? 'في الطريق' : 'On the way';
        break;
      case 'delivered':
        color = Colors.green;
        text = isArabic ? 'تم التوصيل' : 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        text = isArabic ? 'ملغي' : 'Cancelled';
        break;
      case 'rejected':
        color = Colors.red;
        text = isArabic ? 'مرفوض' : 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTotalSection(
      bool isArabic, dynamic totalAmount, dynamic agreedPrice) {
    final displayAmount = agreedPrice ?? totalAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.08),
            AppColors.primaryColor.withOpacity(0.03),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined,
                  size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'المجموع الكلي' : 'Total Amount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF262626),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$displayAmount ${isArabic ? 'ر.س' : 'SAR'}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isArabic, dynamic totalAmount,
      dynamic orderId, bool isUpdatingThisOrder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          // Reject button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isUpdatingThisOrder
                  ? null
                  : () => _handleStatusChange(orderId, 'rejected'),
              icon: const Icon(Icons.close, size: 18),
              label: Text(isArabic ? 'رفض' : 'Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Approve button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isUpdatingThisOrder
                  ? null
                  : () => _showApproveModal(isArabic, totalAmount, orderId),
              icon: isUpdatingThisOrder
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle,
                      size: 18, color: Colors.white),
              label: Text(
                isArabic ? 'قبول الطلب' : 'Approve Order',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStatusChange(dynamic orderId, String status,
      {double? agreedPrice}) {
    if (orderId != null && onOrderStatusChange != null) {
      onOrderStatusChange!(
          orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0,
          status,
          agreedPrice: agreedPrice);
    } else if (onStatusChange != null) {
      onStatusChange!(status, agreedPrice: agreedPrice);
    }
  }

  void _showApproveModal(bool isArabic, dynamic totalAmount, dynamic orderId) {
    final orderNum = orderData?['order_number']?.toString() ??
        attachments['order_number']?.toString() ??
        '#$orderId';
    final defaultPrice = double.tryParse(totalAmount?.toString() ?? '0') ?? 0;

    PriceConfirmationModal.show(
      context: Get.context!,
      orderNumber: orderNum,
      defaultPrice: defaultPrice,
      onConfirm: (agreedPrice) async {
        _handleStatusChange(orderId, 'confirmed', agreedPrice: agreedPrice);
        Get.back();
      },
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item, bool isArabic) {
    final productName = item['product_name'] ?? '';
    final productImage = item['product_image'];
    final quantity = item['quantity'] ?? 1;
    final totalPrice = item['total_price'] ?? 0;
    final unitPrice = item['unit_price'] ?? 0;
    final size = item['size'];
    final selectedOptions = item['selected_options'] as List<dynamic>? ?? [];
    final specialInstructions = item['special_instructions'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: productImage != null &&
                        productImage.toString().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: productImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildImagePlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              // Quantity badge
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${quantity}x',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Quantity info
                _buildInfoChip(
                  Icons.shopping_basket_outlined,
                  '${isArabic ? 'الكمية' : 'Qty'}: $quantity',
                ),
                const SizedBox(height: 6),
                // Unit price
                Text(
                  '${isArabic ? 'سعر الوحدة' : 'Unit'}: $unitPrice ${isArabic ? 'ر.س' : 'SAR'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                // Size
                if (size != null) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.straighten,
                      '${isArabic ? 'الحجم' : 'Size'}: $size'),
                ],
                // Options
                if (selectedOptions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.add_circle_outline,
                    '${isArabic ? 'الإضافات' : 'Options'}: ${selectedOptions.map((opt) => opt['name'] ?? opt['option_name']).join(', ')}',
                  ),
                ],
                // Notes
                if (specialInstructions != null &&
                    specialInstructions.toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.note_outlined,
                    '${isArabic ? 'ملاحظات' : 'Notes'}: $specialInstructions',
                    italic: true,
                  ),
                ],
                const SizedBox(height: 8),
                // Total
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isArabic ? 'الإجمالي' : 'Total'}: $totalPrice ${isArabic ? 'ر.س' : 'SAR'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: Icon(Icons.restaurant, size: 32, color: Colors.grey[400]),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withAlpha(38),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryColor.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool italic = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
