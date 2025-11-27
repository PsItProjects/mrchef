import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/order_details_controller.dart';
import 'package:mrsheaf/features/profile/widgets/order_details_header.dart';
import 'package:mrsheaf/features/profile/widgets/order_status_timeline.dart';
import 'package:mrsheaf/features/profile/widgets/order_delivery_info.dart';
import 'package:mrsheaf/features/profile/widgets/order_items_list.dart';
import 'package:mrsheaf/features/profile/widgets/order_pricing_summary.dart';
import 'package:mrsheaf/features/profile/widgets/order_actions_bar.dart';

class OrderDetailsBottomSheet extends StatefulWidget {
  final int orderId;

  const OrderDetailsBottomSheet({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsBottomSheet> createState() => _OrderDetailsBottomSheetState();
}

class _OrderDetailsBottomSheetState extends State<OrderDetailsBottomSheet> {
  late final OrderDetailsController controller;

  @override
  void initState() {
    super.initState();

    // Initialize and register controller in GetX (without tag)
    controller = Get.put(OrderDetailsController());

    // Load order details
    controller.loadOrderDetails(widget.orderId);
  }

  @override
  void dispose() {
    // Clean up controller when bottom sheet is closed
    Get.delete<OrderDetailsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, size: 24),
                  color: const Color(0xFF2D2D2D),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
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
                        onPressed: () => controller.loadOrderDetails(widget.orderId),
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

