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
  final Function(String status,
      {double? agreedPrice, double? agreedDeliveryFee})? onStatusChange;
  final Function(int orderId, String status,
      {double? agreedPrice, double? agreedDeliveryFee})?
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

  // ─── HELPERS ───────────────────────────────────────────────
  bool get _isArabic => Get.locale?.languageCode == 'ar';

  String _resolveOrderStatus() {
    String status = attachments['status']?.toString() ?? 'pending';
    final orderId = attachments['order_id'];
    if (orderId != null && Get.isRegistered<MerchantChatController>()) {
      final controller = Get.find<MerchantChatController>();
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

  bool get _isThisOrderUpdating {
    if (isUpdating) return true;
    final orderId = attachments['order_id'];
    if (orderId != null && Get.isRegistered<MerchantChatController>()) {
      return Get.find<MerchantChatController>().isOrderUpdating(orderId);
    }
    return false;
  }

  double _parseDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0;

  // ─── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final items = attachments['items'] as List<dynamic>? ?? [];
    final orderId = attachments['order_id'];
    final orderStatus = _resolveOrderStatus();
    final order = _mergedOrder;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusColor(orderStatus).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with status ──
          _buildHeader(order, orderId, orderStatus),

          // ── Status progress bar ──
          if (!['rejected', 'cancelled'].contains(orderStatus))
            _buildStatusProgress(orderStatus),

          // ── Items list ──
          _buildItemsList(items),

          // ── Delivery address ──
          _buildDeliveryAddress(order),

          // ── Pricing breakdown ──
          _buildPricingSummary(order, orderStatus),

          // ── Actions based on status ──
          _buildActions(order, orderId, orderStatus),
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
            _statusColor(status).withOpacity(0.12),
            _statusColor(status).withOpacity(0.04),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          // Icon
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
          // Title + count
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
          // Status badge
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
            // Connector line
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
          // Dot
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
                      color: _statusColor(current).withOpacity(0.3),
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
          // Image
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
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: const BorderRadius.only(
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
                // Unit price
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
                // Item total
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_isArabic ? 'الإجمالي' : 'Total'}: $totalPrice ${_isArabic ? 'ر.س' : 'SAR'}',
                    style: TextStyle(
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
          color: Colors.blue.shade50.withOpacity(0.5),
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
              AppColors.primaryColor.withOpacity(0.08),
              AppColors.primaryColor.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            // Subtotal
            if (subtotal != total)
              _priceRow(
                  _isArabic ? 'المجموع الفرعي' : 'Subtotal', subtotal),
            // Delivery fee display based on type
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
            // Service fee
            if (serviceFee > 0)
              _priceRow(
                  _isArabic ? 'رسوم الخدمة' : 'Service fee', serviceFee),
            // Discount
            if (discount > 0)
              _priceRow(
                _isArabic ? 'خصم' : 'Discount',
                -discount,
                noteColor: Colors.green,
              ),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Divider(
                  color: AppColors.primaryColor.withOpacity(0.15),
                  height: 1),
            ),
            // Total / Agreed total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_rounded,
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
                    color: (noteColor ?? Colors.grey).withOpacity(0.1),
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
  //  ACTIONS
  // ═══════════════════════════════════════════════════════════
  Widget _buildActions(
      Map<String, dynamic> order, dynamic orderId, String status) {
    final updating = _isThisOrderUpdating;

    // Pending → approve / reject
    if (status == 'pending') {
      return _pendingActions(order, orderId, updating);
    }

    // Delivered = awaiting customer confirmation — show info banner
    if (status == 'delivered') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_top_rounded,
                  size: 20, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isArabic
                      ? 'بانتظار تأكيد الاستلام من الزبون'
                      : 'Waiting for customer to confirm receipt',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Completed = final state — no actions
    if (status == 'completed') {
      return const SizedBox(height: 10);
    }

    // Get next available statuses
    final nextStatus = _nextStatuses(status);
    if (nextStatus.isEmpty) return const SizedBox(height: 10);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Row(
        children: nextStatus.map((ns) {
          final isAdvance = _isAdvanceStatus(status, ns);
          final color = isAdvance ? _statusColor(ns) : Colors.red;
          final icon = isAdvance ? _statusIcon(ns) : Icons.cancel_rounded;
          final label = _statusLabel(ns);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _actionButton(
                label: label,
                icon: icon,
                color: color,
                isLoading: updating,
                outlined: !isAdvance,
                onTap: () => _handleStatusChange(orderId, ns),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _pendingActions(
      Map<String, dynamic> order, dynamic orderId, bool updating) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Row(
        children: [
          // Reject
          Expanded(
            child: _actionButton(
              label: _isArabic ? 'رفض' : 'Reject',
              icon: Icons.close_rounded,
              color: Colors.red,
              isLoading: updating,
              outlined: true,
              onTap: () => _handleStatusChange(orderId, 'rejected'),
            ),
          ),
          const SizedBox(width: 10),
          // Approve
          Expanded(
            flex: 2,
            child: _actionButton(
              label: _isArabic ? 'قبول الطلب' : 'Accept Order',
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              isLoading: updating,
              onTap: () => _showApproveModal(order, orderId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
    bool outlined = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(10),
            border: outlined ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        outlined ? color : Colors.white),
                  ),
                )
              else
                Icon(icon,
                    size: 16, color: outlined ? color : Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: outlined ? color : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        return Colors.amber.shade700; // Awaiting customer confirmation
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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
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
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  List<String> _nextStatuses(String current) {
    // Must match backend Order model transition rules exactly
    switch (current) {
      case 'confirmed':
        return ['preparing', 'cancelled']; // canBePreparing + canBeCancelled
      case 'preparing':
        return ['ready']; // canBeReady only
      case 'ready':
        return ['out_for_delivery', 'delivered']; // canBeOutForDelivery + canBeDelivered
      case 'out_for_delivery':
        return ['delivered']; // canBeDelivered
      // 'delivered' = awaiting customer confirmation — merchant has no actions
      // 'completed' = customer confirmed — final state
      default:
        return [];
    }
  }

  bool _isAdvanceStatus(String current, String next) {
    const order = [
      'pending',
      'awaiting_customer_approval',
      'confirmed',
      'preparing',
      'ready',
      'out_for_delivery',
      'delivered',
      'completed'
    ];
    return order.indexOf(next) > order.indexOf(current);
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

  // ─── Private helpers ───────────────────────────────────────
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

  void _handleStatusChange(dynamic orderId, String status,
      {double? agreedPrice, double? agreedDeliveryFee}) {
    if (orderId != null && onOrderStatusChange != null) {
      onOrderStatusChange!(
          orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0,
          status,
          agreedPrice: agreedPrice,
          agreedDeliveryFee: agreedDeliveryFee);
    } else if (onStatusChange != null) {
      onStatusChange!(status,
          agreedPrice: agreedPrice,
          agreedDeliveryFee: agreedDeliveryFee);
    }
  }

  void _showApproveModal(Map<String, dynamic> order, dynamic orderId) {
    final orderNum = order['order_number']?.toString() ?? '#$orderId';
    final defaultPrice =
        double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0;

    PriceConfirmationModal.show(
      context: Get.context!,
      orderNumber: orderNum,
      defaultPrice: defaultPrice,
      deliveryFeeType:
          order['restaurant']?['delivery_fee_type']?.toString() ??
              order['delivery_fee_type']?.toString() ??
              'negotiable',
      onConfirm: (agreedPrice, agreedDeliveryFee) async {
        _handleStatusChange(orderId, 'confirmed',
            agreedPrice: agreedPrice,
            agreedDeliveryFee: agreedDeliveryFee);
        Get.back();
      },
    );
  }
}
