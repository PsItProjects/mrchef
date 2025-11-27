import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';
import 'package:mrsheaf/features/profile/widgets/order_item_widget.dart';

class OrdersList extends GetView<MyOrdersController> {
  const OrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Access observables to trigger reactivity
      final orders = controller.filteredOrders;

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrderItemWidget(
              order: order,
              onViewDetails: () => controller.viewOrderDetails(order),
            ),
          );
        },
      );
    });
  }
}
