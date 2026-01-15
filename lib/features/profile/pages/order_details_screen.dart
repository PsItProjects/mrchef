import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/order_details_controller.dart';
import 'package:mrsheaf/features/profile/widgets/order_details_header.dart';
import 'package:mrsheaf/features/profile/widgets/order_status_timeline.dart';
import 'package:mrsheaf/features/profile/widgets/order_delivery_info.dart';
import 'package:mrsheaf/features/profile/widgets/order_items_list.dart';
import 'package:mrsheaf/features/profile/widgets/order_pricing_summary.dart';
import 'package:mrsheaf/features/profile/widgets/order_actions_bar.dart';

/// Full screen order details for customer
/// Used when navigating from notifications
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late final OrderDetailsController controller;
  late final int orderId;

  @override
  void initState() {
    super.initState();

    // Get order ID from route parameters
    final idParam = Get.parameters['id'];
    orderId = int.tryParse(idParam ?? '') ?? 0;

    // Initialize and register controller in GetX
    controller = Get.put(OrderDetailsController());

    // Load order details
    if (orderId > 0) {
      controller.loadOrderDetails(orderId);
    }
  }

  @override
  void dispose() {
    // Clean up controller when screen is closed
    Get.delete<OrderDetailsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: const Color(0xFF2D2D2D),
        ),
        title: Text(
          'order_details'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
        ),
        centerTitle: true,
      ),
      body: orderId <= 0
          ? Center(
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
                    'invalid_order_id'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
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
                              child: Text('retry'.tr),
                            ),
                          ],
                        ),
                      );
                    }

                    final order = controller.orderDetails.value;
                    if (order == null) {
                      return Center(
                        child: Text('order_not_found'.tr),
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
                            child: SizedBox(height: 100),
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
