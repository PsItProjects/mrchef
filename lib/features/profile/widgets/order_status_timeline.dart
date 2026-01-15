import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/models/order_details_model.dart';
import 'package:mrsheaf/features/profile/models/order_model.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderDetailsModel order;

  const OrderStatusTimeline({super.key, required this.order});

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
            'order_status'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Timeline
          _buildTimelineItem(
            icon: Icons.shopping_bag,
            title: 'order_placed'.tr,
            isCompleted: true,
            isActive: order.status == OrderStatus.pending,
            time: order.formattedDate,
          ),
          
          _buildTimelineItem(
            icon: Icons.check_circle,
            title: 'confirmed'.tr,
            isCompleted: _isStatusCompleted(OrderStatus.confirmed),
            isActive: order.status == OrderStatus.confirmed,
            time: order.confirmedAt != null ? _formatDateTime(order.confirmedAt!) : null,
          ),
          
          _buildTimelineItem(
            icon: Icons.restaurant,
            title: 'preparing'.tr,
            isCompleted: _isStatusCompleted(OrderStatus.preparing),
            isActive: order.status == OrderStatus.preparing,
          ),
          
          _buildTimelineItem(
            icon: Icons.delivery_dining,
            title: 'out_for_delivery'.tr,
            isCompleted: _isStatusCompleted(OrderStatus.outForDelivery),
            isActive: order.status == OrderStatus.outForDelivery,
          ),
          
          _buildTimelineItem(
            icon: Icons.home,
            title: 'delivered'.tr,
            isCompleted: order.status == OrderStatus.delivered || order.status == OrderStatus.completed,
            isActive: order.status == OrderStatus.delivered || order.status == OrderStatus.completed,
            time: order.deliveredAt != null ? _formatDateTime(order.deliveredAt!) : null,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required bool isCompleted,
    required bool isActive,
    String? time,
    bool isLast = false,
  }) {
    final color = isCompleted || isActive ? AppColors.primaryColor : AppColors.lightGreyTextColor;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon and line
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted || isActive ? AppColors.primaryColor.withOpacity(0.1) : AppColors.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primaryColor : AppColors.lightGreyTextColor.withOpacity(0.3),
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Title and time
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: isCompleted || isActive ? AppColors.darkTextColor : AppColors.lightGreyTextColor,
                  ),
                ),
                if (time != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    time,
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
        ),
      ],
    );
  }

  bool _isStatusCompleted(OrderStatus status) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    
    final currentIndex = statusOrder.indexOf(order.status);
    final targetIndex = statusOrder.indexOf(status);
    
    return currentIndex >= targetIndex;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

