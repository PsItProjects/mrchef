import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/order_item_model.dart';

class OrderItemsList extends StatelessWidget {
  final List<OrderItemModel> items;

  const OrderItemsList({super.key, required this.items});

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
            'Order Items',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 32,
              color: AppColors.backgroundColor,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildOrderItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItemModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            image: item.productImage != null
                ? DecorationImage(
                    image: NetworkImage(item.productImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: item.productImage == null
              ? const Icon(
                  Icons.fastfood,
                  size: 30,
                  color: AppColors.lightGreyTextColor,
                )
              : null,
        ),
        
        const SizedBox(width: 16),
        
        // Product Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.formattedUnitPrice} × ${item.quantity}',
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightGreyTextColor,
                ),
              ),
              
              // Special Instructions (if any)
              if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Note: ${item.specialInstructions}',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.lightGreyTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Total Price
        Text(
          item.formattedTotalPrice,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}

