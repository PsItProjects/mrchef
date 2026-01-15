import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/order_details_model.dart';
import 'package:mrsheaf/features/profile/models/order_model.dart';

class OrderPricingSummary extends StatelessWidget {
  final OrderDetailsModel order;

  const OrderPricingSummary({super.key, required this.order});
  
  /// Get the effective payment status
  /// For cash on delivery, if order is completed, payment is considered paid
  String get _effectivePaymentStatus {
    if (order.paymentMethod == 'cash' && 
        (order.status == OrderStatus.completed || order.status == OrderStatus.delivered)) {
      return 'paid';
    }
    return order.paymentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_summary'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 20),

          // Price breakdown container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Subtotal
                _buildPriceRow(
                  label: 'subtotal'.tr,
                  value: '${order.subtotal.toStringAsFixed(2)} SAR',
                ),

                const SizedBox(height: 12),

                // Delivery Fee
                _buildPriceRow(
                  label: 'delivery_fee'.tr,
                  value: '${order.deliveryFee.toStringAsFixed(2)} SAR',
                ),

                // Service Fee
                if (order.serviceFee > 0) ...[
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    label: 'service_fee'.tr,
                    value: order.formattedServiceFee,
                  ),
                ],

                // Tax
                if (order.taxAmount > 0) ...[
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    label: 'tax'.tr,
                    value: '${order.taxAmount.toStringAsFixed(2)} SAR',
                  ),
                ],

                // Discount
                if (order.discountAmount > 0) ...[
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    label: 'discount'.tr,
                    value: '- ${order.formattedDiscountAmount}',
                    valueColor: AppColors.successColor,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildPriceRow(
              label: 'total_amount'.tr,
              value: '${order.totalAmount.toStringAsFixed(2)} SAR',
              labelStyle: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextColor,
              ),
              valueStyle: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment Method
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.backgroundColor,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    order.paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
                    size: 24,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'payment_method'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightGreyTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.paymentMethod == 'cash' ? 'cash_on_delivery'.tr : 'card_payment'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _effectivePaymentStatus == 'paid'
                        ? AppColors.successColor.withOpacity(0.1)
                        : AppColors.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _effectivePaymentStatus == 'paid' ? 'paid'.tr : 'pending'.tr,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _effectivePaymentStatus == 'paid'
                          ? AppColors.successColor
                          : AppColors.warningColor,
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

  Widget _buildPriceRow({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? const TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.lightGreyTextColor,
          ),
        ),
        Text(
          value,
          style: valueStyle ?? TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.darkTextColor,
          ),
        ),
      ],
    );
  }
}

