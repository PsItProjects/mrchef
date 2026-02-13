import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_order_details_controller.dart';
import 'package:mrsheaf/features/merchant/widgets/price_confirmation_modal.dart';

class MerchantOrderDetailsScreen extends StatelessWidget {
  MerchantOrderDetailsScreen({super.key}) {
    Get.put(MerchantOrderDetailsController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantOrderDetailsController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(controller);
        }

        final order = controller.order.value;
        if (order == null) {
          return _buildErrorState(controller);
        }

        return _buildContent(context, controller, order);
      }),
    );
  }

  Widget _buildContent(BuildContext context,
      MerchantOrderDetailsController controller, Map<String, dynamic> order) {
    final status = order['status']?.toString().toLowerCase() ?? 'pending';
    final statusColor = controller.getStatusColor(status);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Collapsing App Bar with order info
        _buildSliverAppBar(controller, order, status, statusColor),

        // Order Status Timeline
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildStatusTimeline(controller, order, status),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildCustomerCard(order),
              const SizedBox(height: 12),
              _buildOrderItemsCard(order),
              const SizedBox(height: 12),
              _buildPriceSummaryCard(order),
              const SizedBox(height: 12),
              _buildDeliveryCard(order),
              if (order['notes'] != null &&
                  order['notes'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildNotesCard(order),
              ],
              const SizedBox(height: 16),
              _buildActionButtons(controller, order),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  // ─── SLIVER APP BAR ──────────────────────────────────────
  Widget _buildSliverAppBar(MerchantOrderDetailsController controller,
      Map<String, dynamic> order, String status, Color statusColor) {
    final createdAt = order['created_at'] != null
        ? DateTime.tryParse(order['created_at'].toString())
        : null;

    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      elevation: 0.5,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            TranslationHelper.isRTL
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_rounded,
            color: AppColors.textDarkColor,
            size: 18,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          if (controller.hasConversation) {
            return Padding(
              padding: const EdgeInsets.only(right: 8, left: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.secondaryColor, size: 18),
                ),
                onPressed: controller.openChatWithCustomer,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt,
                            color: AppColors.primaryColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${TranslationHelper.isArabic ? 'طلب' : 'Order'} ${_getOrderNumber(order)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDarkColor,
                              ),
                            ),
                            if (createdAt != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.schedule_rounded,
                                      size: 13, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy - HH:mm')
                                        .format(createdAt),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500]),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.payments_rounded,
                                      size: 13, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getPaymentMethod(order),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildStatusChip(controller, order, status, statusColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── STATUS CHIP ─────────────────────────────────────────
  Widget _buildStatusChip(MerchantOrderDetailsController controller,
      Map<String, dynamic> order, String status, Color statusColor) {
    final isTerminal =
        ['delivered', 'completed', 'cancelled', 'rejected'].contains(status);

    if (isTerminal) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              controller.getStatusText(status),
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      if (controller.isUpdatingStatus.value) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: () => _showStatusUpdateBottomSheet(controller, order),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                controller.getStatusText(status),
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: statusColor, size: 16),
            ],
          ),
        ),
      );
    });
  }

  // ─── STATUS TIMELINE ─────────────────────────────────────
  Widget _buildStatusTimeline(MerchantOrderDetailsController controller,
      Map<String, dynamic> order, String currentStatus) {
    if (['cancelled', 'rejected'].contains(currentStatus)) {
      return const SizedBox.shrink();
    }

    final allSteps = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'out_for_delivery',
      'delivered',
    ];

    final currentIndex = allSteps.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(allSteps.length, (index) {
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == allSteps.length - 1;
              final stepColor = controller.getStatusColor(allSteps[index]);

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: isCurrent ? 24 : 16,
                      height: isCurrent ? 24 : 16,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? stepColor
                            : Colors.grey.withAlpha(40),
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(
                                color: stepColor.withAlpha(80), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                isCurrent
                                    ? _getStatusIcon(allSteps[index])
                                    : Icons.check_rounded,
                                color: Colors.white,
                                size: isCurrent ? 12 : 9,
                              )
                            : null,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: index < currentIndex
                                ? stepColor
                                : Colors.grey.withAlpha(30),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            controller.getStatusText(
                allSteps[currentIndex < 0 ? 0 : currentIndex]),
            style: TextStyle(
              fontSize: 12,
              color: controller.getStatusColor(
                  allSteps[currentIndex < 0 ? 0 : currentIndex]),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'confirmed':
        return Icons.thumb_up_alt_rounded;
      case 'preparing':
        return Icons.restaurant_rounded;
      case 'ready':
        return Icons.check_circle_rounded;
      case 'out_for_delivery':
        return Icons.delivery_dining_rounded;
      case 'delivered':
        return Icons.done_all_rounded;
      default:
        return Icons.circle;
    }
  }

  // ─── CUSTOMER CARD ───────────────────────────────────────
  Widget _buildCustomerCard(Map<String, dynamic> order) {
    final customerData = order['customer'];
    if (customerData == null) return const SizedBox.shrink();

    Map<String, dynamic>? customer;
    if (customerData is Map<String, dynamic>) {
      customer = customerData;
    } else if (customerData is Map) {
      customer = Map<String, dynamic>.from(customerData);
    } else {
      return const SizedBox.shrink();
    }

    String name = 'customer'.tr;
    final nameData = customer['name'];
    if (nameData is String) {
      name = nameData;
    } else if (nameData is Map) {
      name = nameData['current']?.toString() ??
          (TranslationHelper.isArabic
              ? nameData['ar']?.toString()
              : nameData['en']?.toString()) ??
          nameData['en']?.toString() ??
          'customer'.tr;
    } else {
      name = customer['full_name']?.toString() ??
          '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'
              .trim();
    }
    if (name.isEmpty) name = 'customer'.tr;

    final phone = customer['phone_number']?.toString() ??
        customer['phone']?.toString() ??
        '';
    final countryCode = customer['country_code']?.toString() ?? '';

    return _buildCard(
      icon: Icons.person_rounded,
      iconColor: AppColors.secondaryColor,
      title: 'customer_info'.tr,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondaryColor,
                  AppColors.secondaryColor.withAlpha(180),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkColor,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        '$countryCode $phone',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ORDER ITEMS CARD ────────────────────────────────────
  Widget _buildOrderItemsCard(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];

    return _buildCard(
      icon: Icons.receipt_long_rounded,
      iconColor: Colors.deepOrange,
      title: 'order_items'.tr,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${items.length} ${'items'.tr}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange,
          ),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          return Column(
            children: [
              if (index > 0)
                Divider(color: Colors.grey.withAlpha(30), height: 1),
              _buildOrderItemRow(item),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderItemRow(Map<String, dynamic> item) {
    final nameData = item['product_name'] ?? item['name'] ?? '';
    String name;
    if (nameData is Map) {
      name = (TranslationHelper.isArabic
              ? nameData['ar']?.toString()
              : nameData['en']?.toString()) ??
          nameData['current']?.toString() ??
          nameData['en']?.toString() ??
          '';
    } else {
      name = TranslationHelper.isArabic
          ? (item['product_name_ar'] ??
              item['product_name'] ??
              item['name'] ??
              '')
          : (item['product_name_en'] ??
              item['product_name'] ??
              item['name'] ??
              '');
    }

    final quantity = item['quantity'] ?? 1;
    final price = _parseDouble(item['unit_price'] ?? item['price']);
    final total = _parseDouble(
        item['total'] ?? item['total_price'] ?? (price * quantity));

    final size = item['size']?.toString();
    final options = item['selected_options'] as List<dynamic>?;
    final instructions = item['special_instructions']?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkColor,
                  ),
                ),
                if (size != null && size.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    size,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
                if (options != null && options.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 4,
                    children: options.map((opt) {
                      final optName = opt is Map
                          ? (opt['name']?.toString() ?? '')
                          : opt.toString();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          optName,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey[600]),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (instructions != null && instructions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.note_rounded,
                          size: 12, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          instructions,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber[800],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Price
          Text(
            TranslationHelper.formatCurrency(total),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDarkColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── PRICE SUMMARY CARD ──────────────────────────────────
  Widget _buildPriceSummaryCard(Map<String, dynamic> order) {
    final subtotal = _parseDouble(order['subtotal']);
    final deliveryFee = _parseDouble(order['delivery_fee']);
    final serviceFee = _parseDouble(order['service_fee']);
    final taxAmount = _parseDouble(order['tax_amount']);
    final discount = _parseDouble(order['discount_amount'] ?? order['discount']);
    final total = _parseDouble(order['total_amount'] ?? order['total']);
    final agreedPrice = order['agreed_price'] != null
        ? _parseDouble(order['agreed_price'])
        : null;
    final agreedDeliveryFee = order['agreed_delivery_fee'] != null
        ? _parseDouble(order['agreed_delivery_fee'])
        : null;
    final deliveryFeeType =
        order['restaurant']?['delivery_fee_type']?.toString() ??
            order['delivery_fee_type']?.toString() ??
            'negotiable';

    return _buildCard(
      icon: Icons.receipt_rounded,
      iconColor: Colors.teal,
      title: 'order_summary'.tr,
      child: Column(
        children: [
          _buildPriceRow('subtotal'.tr, subtotal),
          // Show delivery fee based on type
          if (deliveryFeeType == 'free')
            _buildPriceRow('free_delivery'.tr, 0)
          else if (deliveryFeeType == 'negotiable' &&
              agreedDeliveryFee != null &&
              agreedDeliveryFee > 0)
            _buildPriceRow(
                'agreed_delivery_fee'.tr, agreedDeliveryFee,
                isAgreed: true)
          else
            _buildPriceRow('delivery_fee'.tr, deliveryFee),
          if (serviceFee > 0) _buildPriceRow('service_fee'.tr, serviceFee),
          if (taxAmount > 0) _buildPriceRow('tax'.tr, taxAmount),
          if (discount > 0)
            _buildPriceRow('discount'.tr, -discount, isDiscount: true),
          if (agreedPrice != null && agreedPrice > 0)
            _buildPriceRow('agreed_price'.tr, agreedPrice, isAgreed: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.withAlpha(60),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDarkColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    TranslationHelper.formatCurrency(total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryColor,
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

  Widget _buildPriceRow(String label, double amount,
      {bool isDiscount = false, bool isAgreed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            isDiscount
                ? '-${TranslationHelper.formatCurrency(amount.abs())}'
                : TranslationHelper.formatCurrency(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDiscount
                  ? Colors.green[600]
                  : isAgreed
                      ? AppColors.primaryColor
                      : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // ─── DELIVERY CARD ───────────────────────────────────────
  Widget _buildDeliveryCard(Map<String, dynamic> order) {
    final address = order['delivery_address'] ?? order['address'];
    if (address == null) return const SizedBox.shrink();

    String addressText = '';
    String addressType = '';
    if (address is Map) {
      addressText = address['full_address'] ??
          address['address'] ??
          '${address['street'] ?? ''}, ${address['city'] ?? ''}'.trim();
      addressType = address['type']?.toString() ?? '';
    } else if (address is String) {
      addressText = address;
    }

    if (addressText.isEmpty) return const SizedBox.shrink();

    final deliveryType = order['delivery_type']?.toString() ?? 'delivery';

    return _buildCard(
      icon: deliveryType == 'pickup'
          ? Icons.storefront_rounded
          : Icons.location_on_rounded,
      iconColor: Colors.blue[700]!,
      title: 'delivery_info'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (addressType.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getAddressTypeLabel(addressType),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.pin_drop_rounded, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  addressText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── NOTES CARD ──────────────────────────────────────────
  Widget _buildNotesCard(Map<String, dynamic> order) {
    final notes = order['notes']?.toString() ?? '';

    return _buildCard(
      icon: Icons.sticky_note_2_rounded,
      iconColor: Colors.amber[700]!,
      title: 'special_notes'.tr,
      child: Text(
        notes,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      ),
    );
  }

  // ─── ACTION BUTTONS ──────────────────────────────────────
  Widget _buildActionButtons(
      MerchantOrderDetailsController controller, Map<String, dynamic> order) {
    final status = order['status']?.toString().toLowerCase() ?? 'pending';
    final isTerminal =
        ['delivered', 'completed', 'cancelled', 'rejected'].contains(status);

    return Column(
      children: [
        // Update Status button
        if (!isTerminal) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _showStatusUpdateBottomSheet(controller, order),
              icon: const Icon(Icons.update_rounded, size: 20),
              label: Text(
                'update_status'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.secondaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Awaiting customer confirmation for delivered
        if (status == 'delivered') ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withAlpha(60)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_bottom_rounded,
                    color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'awaiting_customer_confirmation'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Chat with customer button
        if (controller.hasConversation) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: controller.openChatWithCustomer,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(
                'chat_with_customer'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Cancel button
        if (!isTerminal && status != 'pending') ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showStatusChangeDialog(controller, 'cancelled'),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(
                'cancel_order'.tr,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[400],
                side: BorderSide(color: Colors.red[300]!),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── REUSABLE CARD WRAPPER ───────────────────────────────
  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkColor,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.grey.withAlpha(30), height: 1),
          ),
          child,
        ],
      ),
    );
  }

  // ─── SHIMMER LOADING ─────────────────────────────────────
  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 130,
          pinned: true,
          elevation: 0.5,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                TranslationHelper.isRTL
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_rounded,
                color: AppColors.textDarkColor,
                size: 18,
              ),
            ),
            onPressed: () => Get.back(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Colors.white,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildShimmerCard(100),
              const SizedBox(height: 12),
              _buildShimmerCard(80),
              const SizedBox(height: 12),
              _buildShimmerCard(120),
              const SizedBox(height: 12),
              _buildShimmerCard(100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor.withAlpha(120),
          ),
        ),
      ),
    );
  }

  // ─── ERROR STATE ─────────────────────────────────────────
  Widget _buildErrorState(MerchantOrderDetailsController controller) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0.5,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                TranslationHelper.isRTL
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_rounded,
                color: AppColors.textDarkColor,
                size: 18,
              ),
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'order_details'.tr,
            style: const TextStyle(color: AppColors.textDarkColor, fontSize: 18),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.error_outline_rounded,
                        size: 40, color: Colors.red[300]),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.loadOrderDetails,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('retry'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── STATUS UPDATE BOTTOM SHEET ────────────────────────────
  void _showStatusUpdateBottomSheet(
      MerchantOrderDetailsController controller, Map<String, dynamic> order) {
    final currentStatus = order['status']?.toString().toLowerCase() ?? 'pending';
    final nextStatuses = controller.getNextStatuses(currentStatus);

    if (nextStatuses.isEmpty) return;

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
            ...nextStatuses.map((status) {
              final color = controller.getStatusColor(status);
              return ListTile(
                leading: Icon(_getStatusIcon(status), color: color),
                title: Text(controller.getStatusText(status)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onTap: () {
                  Get.back(); // Close bottom sheet
                  if (status == 'confirmed' && currentStatus == 'pending') {
                    _showPriceConfirmationForOrder(controller, order);
                  } else {
                    _showStatusChangeDialog(controller, status);
                  }
                },
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showPriceConfirmationForOrder(
      MerchantOrderDetailsController controller, Map<String, dynamic> order) {
    final totalAmount =
        _parseDouble(order['total_amount'] ?? order['total']);

    PriceConfirmationModal.show(
      context: Get.context!,
      orderNumber: _getOrderNumber(order),
      defaultPrice: totalAmount,
      deliveryFeeType:
          order['restaurant']?['delivery_fee_type']?.toString() ??
              order['delivery_fee_type']?.toString() ??
              'negotiable',
      onConfirm: (agreedPrice, agreedDeliveryFee) async {
        // Close modal immediately
        Get.back();
        // Then update status
        await controller.updateOrderStatus(
          'confirmed',
          agreedPrice: agreedPrice,
          agreedDeliveryFee: agreedDeliveryFee,
        );
      },
    );
  }

  // ─── STATUS CHANGE DIALOG ────────────────────────────────
  void _showStatusChangeDialog(
      MerchantOrderDetailsController controller, String newStatus) {
    if (newStatus == 'cancelled') {
      Get.dialog(
        AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red[400], size: 24),
              const SizedBox(width: 10),
              Text('cancel_order'.tr,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Text('confirm_cancel_order'.tr,
              style: TextStyle(color: Colors.grey[600], height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('no'.tr,
                  style: TextStyle(
                      color: Colors.grey[500], fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.updateOrderStatus(newStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('yes'.tr),
            ),
          ],
        ),
      );
    } else {
      controller.updateOrderStatus(newStatus);
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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

  String _getPaymentMethod(Map<String, dynamic> order) {
    final method = order['payment_method']?.toString() ?? 'cash';
    switch (method.toLowerCase()) {
      case 'cash':
        return TranslationHelper.isArabic ? 'نقدي' : 'Cash';
      case 'card':
      case 'credit_card':
        return TranslationHelper.isArabic ? 'بطاقة' : 'Card';
      case 'wallet':
        return TranslationHelper.isArabic ? 'محفظة' : 'Wallet';
      default:
        return method;
    }
  }

  String _getAddressTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return TranslationHelper.isArabic ? '🏠 المنزل' : '🏠 Home';
      case 'work':
        return TranslationHelper.isArabic ? '🏢 العمل' : '🏢 Work';
      case 'other':
        return TranslationHelper.isArabic ? '📍 آخر' : '📍 Other';
      default:
        return type;
    }
  }
}
