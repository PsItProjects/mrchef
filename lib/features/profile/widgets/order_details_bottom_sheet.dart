import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/order_details_controller.dart';
import 'package:mrsheaf/features/profile/widgets/order_details_header.dart';
import 'package:mrsheaf/features/profile/widgets/order_status_timeline.dart';
import 'package:mrsheaf/features/profile/widgets/order_delivery_info.dart';
import 'package:mrsheaf/features/profile/widgets/order_items_list.dart';
import 'package:mrsheaf/features/profile/widgets/order_pricing_summary.dart';
import 'package:mrsheaf/features/profile/widgets/order_actions_bar.dart';

class OrderDetailsBottomSheet extends StatelessWidget {
  final int orderId;

  const OrderDetailsBottomSheet({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with unique tag
    final controller = Get.put(
      OrderDetailsController(),
      tag: 'order_details_$orderId',
    );

    // Load order details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadOrderDetails(orderId);
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFACD02),
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => controller.loadOrderDetails(orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFACD02),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final order = controller.orderDetails.value;
              if (order == null) {
                return const Center(
                  child: Text('Order not found'),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshOrderDetails(),
                color: const Color(0xFFFACD02),
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: OrderDetailsHeader(order: order),
                    ),

                    // Timeline
                    SliverToBoxAdapter(
                      child: OrderStatusTimeline(order: order),
                    ),

                    // Delivery Info
                    SliverToBoxAdapter(
                      child: OrderDeliveryInfo(order: order),
                    ),

                    // Items List
                    SliverToBoxAdapter(
                      child: OrderItemsList(items: order.items),
                    ),

                    // Pricing Summary
                    SliverToBoxAdapter(
                      child: OrderPricingSummary(order: order),
                    ),

                    // Bottom padding for actions bar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ),
              );
            }),
          ),

          // Actions Bar
          Obx(() {
            final order = controller.orderDetails.value;
            if (order != null) {
              return OrderActionsBar(order: order);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

