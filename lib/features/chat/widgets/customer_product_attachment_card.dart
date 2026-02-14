import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/features/chat/controllers/chat_controller.dart';

/// Professional order card shown in customer chat — mirrors the merchant card
/// design but with customer-specific actions (confirm delivery).
class CustomerProductAttachmentCard extends StatelessWidget {
  final Map<String, dynamic> attachments;
  final Map<String, dynamic>? orderData;
  final bool isConfirming;
  final Function(int orderId)? onConfirmDelivery;

  const CustomerProductAttachmentCard({
    super.key,
    required this.attachments,
    this.orderData,
    this.isConfirming = false,
    this.onConfirmDelivery,
  });

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  String _resolveOrderStatus() {
    String status = attachments['status']?.toString() ?? 'pending';
    final orderId = attachments['order_id'];
    if (orderId != null && Get.isRegistered<ChatController>()) {
      final controller = Get.find<ChatController>();
      final stored = controller.getOrderStatus(orderId);
      if (stored != null) status = stored;
    }
    if (orderData != null) {
      status = orderData!['status']?.toString() ?? status;
    }
    return status;
  }

  Map<String, dynamic> get _mergedOrder {
    final merged = <String, dynamic>{...attachments};
    if (orderData != null) merged.addAll(orderData!);
    return merged;
  }

  bool get _isConfirmingThis {
    if (isConfirming) return true;
    final orderId = attachments['order_id'];
    if (orderId != null && Get.isRegistered<ChatController>()) {
      return Get.find<ChatController>().isOrderConfirming(orderId);
    }
    return false;
  }

  double _parseDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0;

  @override
  Widget build(BuildContext context) {
    final items = attachments['items'] as List<dynamic>? ?? [];
    final orderId = attachments['order_id'];
    final status = _resolveOrderStatus();
    final order = _mergedOrder;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusColor(status).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(order, orderId, status),
          if (!['rejected', 'cancelled'].contains(status))
            _buildStatusProgress(status),
          _buildItemsList(items),
          _buildDeliveryAddress(order),
          _buildPricingSummary(order, status),
          _buildActions(order, orderId, status),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader(
      Map<String, dynamic> order, dynamic orderId, String status) {
    final itemCount =
        order['item_count'] ?? (order['items'] as List?)?.length ?? 0;
    final orderNumber = order['order_number']?.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _statusColor(status).withValues(alpha: 0.12),
            _statusColor(status).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _statusColor(status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isArabic ? 'تفاصيل الطلب' : 'Order Details',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDarkColor,
                      ),
                    ),
                    if (orderNumber != null || orderId != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${orderNumber ?? orderId}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$itemCount ${_isArabic ? (itemCount == 1 ? 'منتج' : 'منتجات') : (itemCount == 1 ? 'item' : 'items')}',
                  style: TextStyle(
                      fontSize: 11.5, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  STATUS PROGRESS
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatusProgress(String current) {
    const stages = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'out_for_delivery',
      'delivered',
      'completed',
    ];
    final currentIdx = stages.indexOf(current);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Row(
        children: List.generate(stages.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stageIdx = i ~/ 2;
            final done = stageIdx < currentIdx;
            return Expanded(
              child: Container(
                height: 2.5,
                decoration: BoxDecoration(
                  color: done
                      ? _statusColor(current)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          final stageIdx = i ~/ 2;
          final done = stageIdx <= currentIdx;
          final isCurrent = stageIdx == currentIdx;
          return Container(
            width: isCurrent ? 16 : 10,
            height: isCurrent ? 16 : 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? _statusColor(current) : Colors.grey.shade200,
              border: isCurrent
                  ? Border.all(
                      color: _statusColor(current).withValues(alpha: 0.3),
                      width: 3)
                  : null,
            ),
            child: isCurrent
                ? Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  ITEMS LIST
  // ═══════════════════════════════════════════════════════════
  Widget _buildItemsList(List<dynamic> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Column(
        children: items.map((item) => _buildProductItem(item)).toList(),
      ),
    );
  }

  Widget _buildProductItem(dynamic rawItem) {
    final item =
        rawItem is Map<String, dynamic> ? rawItem : <String, dynamic>{};
    final name = item['product_name']?.toString() ?? '';
    final image = item['product_image']?.toString();
    final qty = item['quantity'] ?? 1;
    final unitPrice = item['unit_price'] ?? 0;
    final totalPrice = item['total_price'] ?? 0;
    final size = item['size'];
    final options = item['selected_options'] as List<dynamic>? ?? [];
    final notes = item['special_instructions']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with qty badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _productImage(image),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    '×$qty',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_isArabic ? 'سعر الوحدة' : 'Unit'}: $unitPrice ${_isArabic ? 'ر.س' : 'SAR'}',
                  style:
                      TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
                if (size != null) ...[
                  const SizedBox(height: 2),
                  _miniDetail(Icons.straighten_rounded,
                      '${_isArabic ? 'الحجم' : 'Size'}: $size'),
                ],
                if (options.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  _miniDetail(
                    Icons.add_circle_outline_rounded,
                    options
                        .map((o) => o['name'] ?? o['option_name'] ?? '')
                        .join(', '),
                  ),
                ],
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  _miniDetail(Icons.note_alt_outlined, notes, italic: true),
                ],
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_isArabic ? 'الإجمالي' : 'Total'}: $totalPrice ${_isArabic ? 'ر.س' : 'SAR'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  // ═══════════════════════════════════════════════════════════
  //  DELIVERY ADDRESS
  // ═══════════════════════════════════════════════════════════
  Widget _buildDeliveryAddress(Map<String, dynamic> order) {
    final address = order['delivery_address'] ?? order['address'];
    if (address == null) return const SizedBox.shrink();

    String addressText = '';
    String addressType = '';

    if (address is Map) {
      addressText = address['full_address']?.toString() ??
          address['address']?.toString() ??
          '${address['street'] ?? ''}, ${address['city'] ?? ''}'.trim();
      addressType = address['type']?.toString() ?? '';
    } else if (address is String) {
      addressText = address;
    }

    if (addressText.isEmpty && addressType.isEmpty) {
      return const SizedBox.shrink();
    }

    IconData typeIcon;
    switch (addressType.toLowerCase()) {
      case 'home':
        typeIcon = Icons.home_rounded;
        break;
      case 'work':
      case 'office':
        typeIcon = Icons.work_rounded;
        break;
      default:
        typeIcon = Icons.place_rounded;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(typeIcon, size: 16, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isArabic ? 'عنوان التوصيل' : 'Delivery Address',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    addressText,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (addressType.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _addressTypeLabel(addressType),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.blue.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  PRICING SUMMARY
  // ═══════════════════════════════════════════════════════════
  Widget _buildPricingSummary(Map<String, dynamic> order, String status) {
    final subtotal = _parseDouble(order['subtotal'] ?? order['total_amount']);
    final deliveryFee = _parseDouble(order['delivery_fee']);
    final serviceFee = _parseDouble(order['service_fee']);
    final discount =
        _parseDouble(order['discount_amount'] ?? order['discount']);
    final total = _parseDouble(order['total_amount'] ?? order['total']);
    final agreedPrice = order['agreed_price'] != null
        ? _parseDouble(order['agreed_price'])
        : null;
    final agreedDeliveryFee = order['agreed_delivery_fee'] != null
        ? _parseDouble(order['agreed_delivery_fee'])
        : null;
    final feeType =
        order['restaurant']?['delivery_fee_type']?.toString() ??
            order['delivery_fee_type']?.toString() ??
            'negotiable';

    final isConfirmed =
        !['pending', 'rejected', 'cancelled'].contains(status);
    final isFinalDelivered = status == 'completed';
    final displayTotal = agreedPrice ?? total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.08),
              AppColors.primaryColor.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            if (subtotal != total)
              _priceRow(
                  _isArabic ? 'المجموع الفرعي' : 'Subtotal', subtotal),
            if (feeType == 'free')
              _priceRow(
                _isArabic ? 'التوصيل' : 'Delivery',
                0,
                note: _isArabic ? 'مجاني' : 'Free',
                noteColor: Colors.green,
              )
            else if (isConfirmed &&
                agreedDeliveryFee != null &&
                agreedDeliveryFee > 0)
              _priceRow(
                _isArabic ? 'التوصيل (متفق عليه)' : 'Delivery (agreed)',
                agreedDeliveryFee,
                highlight: true,
              )
            else if (deliveryFee > 0)
              _priceRow(_isArabic ? 'التوصيل' : 'Delivery', deliveryFee)
            else if (feeType == 'negotiable')
              _priceRow(
                _isArabic ? 'التوصيل' : 'Delivery',
                0,
                note: _isArabic ? 'بالاتفاق' : 'Negotiable',
                noteColor: Colors.orange,
              ),
            if (serviceFee > 0)
              _priceRow(
                  _isArabic ? 'رسوم الخدمة' : 'Service fee', serviceFee),
            if (discount > 0)
              _priceRow(
                _isArabic ? 'خصم' : 'Discount',
                -discount,
                noteColor: Colors.green,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Divider(
                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                  height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payments_rounded,
                        size: 18, color: AppColors.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      isConfirmed && agreedPrice != null
                          ? (_isArabic
                              ? 'السعر المتفق عليه'
                              : 'Agreed Price')
                          : (_isArabic ? 'المجموع الكلي' : 'Total'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDarkColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isConfirmed && agreedPrice != null
                        ? Colors.green
                        : isFinalDelivered
                            ? Colors.green
                            : AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${displayTotal.toStringAsFixed(2)} ${_isArabic ? 'ر.س' : 'SAR'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double amount,
      {String? note, Color? noteColor, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: highlight
                  ? AppColors.primaryColor
                  : Colors.grey.shade600,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          note != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (noteColor ?? Colors.grey).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: noteColor ?? Colors.grey,
                    ),
                  ),
                )
              : Text(
                  amount < 0
                      ? '-${amount.abs().toStringAsFixed(2)}'
                      : amount.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: amount < 0
                        ? Colors.green
                        : highlight
                            ? AppColors.primaryColor
                            : Colors.grey.shade700,
                  ),
                ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  ACTIONS — customer can confirm delivery
  // ═══════════════════════════════════════════════════════════
  Widget _buildActions(
      Map<String, dynamic> order, dynamic orderId, String status) {
    // Awaiting customer approval — show accept/reject price buttons
    if (status == 'awaiting_customer_approval') {
      final confirming = _isConfirmingThis;
      final agreedPrice = _parseDouble(order['agreed_price'] ?? order['total_amount']);
      final deliveryFee = _parseDouble(order['delivery_fee'] ?? order['agreed_delivery_fee']);

      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          children: [
            // Price summary banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.price_check_rounded, size: 20, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        _isArabic ? 'عرض السعر من التاجر' : 'Price Proposal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isArabic ? 'سعر المنتجات' : 'Products Price',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      Text(
                        '$agreedPrice ${_isArabic ? 'ر.س' : 'SAR'}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isArabic ? 'رسوم التوصيل' : 'Delivery Fee',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      Text(
                        '$deliveryFee ${_isArabic ? 'ر.س' : 'SAR'}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Accept / Reject buttons
            Row(
              children: [
                // Accept button
                Expanded(
                  flex: 2,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: confirming ? null : () => _handleAcceptPrice(orderId),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade600, Colors.green.shade500],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (confirming)
                              const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              _isArabic ? 'قبول السعر' : 'Accept',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Reject button
                Expanded(
                  flex: 1,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: confirming ? null : () => _handleRejectPrice(orderId),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade400, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close_rounded, size: 20, color: Colors.red.shade600),
                            const SizedBox(width: 4),
                            Text(
                              _isArabic ? 'رفض' : 'Reject',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Delivered = awaiting customer confirmation — show confirm button
    if (status == 'delivered') {
      final confirming = _isConfirmingThis;
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: confirming
                ? null
                : () => _handleConfirmDelivery(orderId),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade600,
                    Colors.green.shade500,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (confirming)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Icon(Icons.check_circle_rounded,
                        size: 22, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _isArabic ? 'تأكيد الاستلام' : 'Confirm Receipt',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Completed — show success banner
    if (status == 'completed') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.done_all_rounded,
                  size: 20, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isArabic
                      ? 'تم تأكيد الاستلام بنجاح ✓'
                      : 'Delivery confirmed successfully ✓',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Cancelled/rejected — show info
    if (status == 'cancelled' || status == 'rejected') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.cancel_rounded,
                  size: 20, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isArabic
                      ? (status == 'rejected'
                          ? 'تم رفض الطلب'
                          : 'تم إلغاء الطلب')
                      : (status == 'rejected'
                          ? 'Order rejected'
                          : 'Order cancelled'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // For all other statuses — show a subtle status info
    if (['pending', 'confirmed', 'preparing', 'ready', 'out_for_delivery']
        .contains(status)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _statusColor(status).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: _statusColor(status).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(_statusIcon(status),
                  size: 16, color: _statusColor(status)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _statusDescription(status),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox(height: 10);
  }

  // ═══════════════════════════════════════════════════════════
  //  STATUS UTILITIES
  // ═══════════════════════════════════════════════════════════
  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'awaiting_customer_approval':
        return AppColors.primaryColor;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return const Color(0xFF9C27B0);
      case 'ready':
        return Colors.teal;
      case 'out_for_delivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.amber.shade700;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _statusLabel(status),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return _isArabic ? 'قيد الانتظار' : 'Pending';
      case 'awaiting_customer_approval':
        return _isArabic ? 'بانتظار موافقة العميل' : 'Awaiting Approval';
      case 'confirmed':
        return _isArabic ? 'مؤكد' : 'Confirmed';
      case 'preparing':
        return _isArabic ? 'قيد التحضير' : 'Preparing';
      case 'ready':
        return _isArabic ? 'جاهز' : 'Ready';
      case 'out_for_delivery':
        return _isArabic ? 'في الطريق' : 'On the Way';
      case 'delivered':
        return _isArabic ? 'بانتظار تأكيد الاستلام' : 'Awaiting Confirmation';
      case 'completed':
        return _isArabic ? 'تم التوصيل' : 'Delivered';
      case 'cancelled':
        return _isArabic ? 'ملغي' : 'Cancelled';
      case 'rejected':
        return _isArabic ? 'مرفوض' : 'Rejected';
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'awaiting_customer_approval':
        return Icons.price_check_rounded;
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'preparing':
        return Icons.restaurant_rounded;
      case 'ready':
        return Icons.check_box_rounded;
      case 'out_for_delivery':
        return Icons.delivery_dining_rounded;
      case 'delivered':
        return Icons.hourglass_top_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'pending':
        return _isArabic
            ? 'بانتظار موافقة التاجر على طلبك'
            : 'Waiting for merchant to accept your order';
      case 'confirmed':
        return _isArabic
            ? 'تم قبول طلبك من التاجر'
            : 'Your order has been accepted';
      case 'preparing':
        return _isArabic
            ? 'طلبك قيد التحضير الآن'
            : 'Your order is being prepared';
      case 'ready':
        return _isArabic ? 'طلبك جاهز للتوصيل' : 'Your order is ready';
      case 'out_for_delivery':
        return _isArabic
            ? 'طلبك في الطريق إليك'
            : 'Your order is on the way';
      default:
        return '';
    }
  }

  String _addressTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return _isArabic ? '🏠 منزل' : '🏠 Home';
      case 'work':
      case 'office':
        return _isArabic ? '🏢 عمل' : '🏢 Work';
      default:
        return _isArabic ? '📍 أخرى' : '📍 Other';
    }
  }

  Widget _productImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        placeholder: (_, __) => _imagePlaceholder(),
        errorWidget: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.restaurant_rounded,
          size: 28, color: Colors.grey.shade400),
    );
  }

  Widget _miniDetail(IconData icon, String text, {bool italic = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _handleAcceptPrice(dynamic orderId) {
    if (orderId == null) return;
    final id = orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isArabic ? 'قبول السعر' : 'Accept Price',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          _isArabic
              ? 'هل تؤكد موافقتك على السعر المقترح؟'
              : 'Do you confirm accepting the proposed price?',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              _isArabic ? 'إلغاء' : 'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (Get.isRegistered<ChatController>()) {
                Get.find<ChatController>().acceptPrice(id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_isArabic ? 'موافق' : 'Accept'),
          ),
        ],
      ),
    );
  }

  void _handleRejectPrice(dynamic orderId) {
    if (orderId == null) return;
    final id = orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red.shade600, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isArabic ? 'رفض السعر' : 'Reject Price',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          _isArabic
              ? 'هل تريد رفض السعر المقترح؟ سيتم إعادة الطلب للتفاوض مع التاجر.'
              : 'Reject the proposed price? The order will be reopened for negotiation.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              _isArabic ? 'إلغاء' : 'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (Get.isRegistered<ChatController>()) {
                Get.find<ChatController>().rejectPrice(id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_isArabic ? 'رفض' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _handleConfirmDelivery(dynamic orderId) {
    if (orderId == null) return;
    final id = orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0;

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.green.shade600, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isArabic ? 'تأكيد الاستلام' : 'Confirm Receipt',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          _isArabic
              ? 'هل تؤكد استلام الطلب؟ لا يمكن التراجع بعد التأكيد.'
              : 'Confirm you received the order? This cannot be undone.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              _isArabic ? 'إلغاء' : 'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (onConfirmDelivery != null) {
                onConfirmDelivery!(id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_isArabic ? 'تأكيد' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}
