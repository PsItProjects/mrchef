import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/order_details_model.dart';

class OrderPricingSummary extends StatelessWidget {
  final OrderDetailsModel order;

  const OrderPricingSummary({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Subtotal
          _buildPriceRow(
            label: 'Subtotal',
            value: '${order.subtotal.toStringAsFixed(2)} SAR',
          ),
          
          const SizedBox(height: 12),
          
          // Delivery Fee
          _buildPriceRow(
            label: 'Delivery Fee',
            value: '${order.deliveryFee.toStringAsFixed(2)} SAR',
          ),
          
          const SizedBox(height: 12),
          
          // Service Fee
          if (order.serviceFee > 0) ...[
            _buildPriceRow(
              label: 'Service Fee',
              value: order.formattedServiceFee,
            ),
            const SizedBox(height: 12),
          ],
          
          // Tax
          if (order.taxAmount > 0) ...[
            _buildPriceRow(
              label: 'Tax',
              value: '${order.taxAmount.toStringAsFixed(2)} SAR',
            ),
            const SizedBox(height: 12),
          ],
          
          // Discount
          if (order.discountAmount > 0) ...[
            _buildPriceRow(
              label: 'Discount',
              value: '- ${order.formattedDiscountAmount}',
              valueColor: AppColors.successColor,
            ),
            const SizedBox(height: 12),
          ],
          
          const Divider(height: 24, color: AppColors.backgroundColor),
          
          // Total
          _buildPriceRow(
            label: 'Total',
            value: '${order.totalAmount.toStringAsFixed(2)} SAR',
            labelStyle: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
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
          
          const SizedBox(height: 16),
          
          // Payment Method
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  order.paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
                  size: 20,
                  color: AppColors.darkTextColor,
                ),
                const SizedBox(width: 12),
                Text(
                  order.paymentMethod == 'cash' ? 'Cash on Delivery' : 'Card Payment',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.paymentStatus == 'paid' 
                        ? AppColors.successColor.withOpacity(0.1)
                        : AppColors.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.paymentStatus == 'paid' ? 'Paid' : 'Pending',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: order.paymentStatus == 'paid' 
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

