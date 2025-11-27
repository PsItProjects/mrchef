import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/order_details_model.dart';

class OrderDeliveryInfo extends StatelessWidget {
  final OrderDetailsModel order;

  const OrderDeliveryInfo({super.key, required this.order});

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
          // Restaurant Info
          Row(
            children: [
              // Restaurant Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  image: order.restaurantLogo != null
                      ? DecorationImage(
                          image: NetworkImage(order.restaurantLogo!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: order.restaurantLogo == null
                    ? const Icon(
                        Icons.restaurant,
                        size: 30,
                        color: AppColors.lightGreyTextColor,
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Restaurant Name and Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName ?? 'Restaurant',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    if (order.restaurantAddress != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        order.restaurantAddress!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightGreyTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.backgroundColor),
          const SizedBox(height: 20),
          
          // Delivery Address
          const Text(
            'Delivery Address',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddressText,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkTextColor,
                  ),
                ),
              ),
            ],
          ),
          
          // Notes (if any)
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Notes',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.notes!,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.darkTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

