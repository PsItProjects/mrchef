import 'package:flutter/material.dart';
import 'package:mrsheaf/features/profile/models/order_model.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onViewDetails;

  const OrderItemWidget({
    super.key,
    required this.order,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E3E3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order header section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Order code and date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Order code section
                    Row(
                      children: [
                        const Text(
                          'Order Code',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF262626),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.orderCode,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF262626),
                          ),
                        ),
                      ],
                    ),
                    
                    // Order date
                    Text(
                      order.formattedDate,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF5E5E5E),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Divider line
                Container(
                  height: 1,
                  color: const Color(0xFFE3E3E3),
                ),
              ],
            ),
          ),
          
          // Order details section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Quantity and total amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.formattedQuantity,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFFFACD02),
                      ),
                    ),
                    Text(
                      order.formattedAmount,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Detail button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFACD02),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: onViewDetails,
                        child: const Text(
                          'Detail',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Status button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        order.statusText,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: order.statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
