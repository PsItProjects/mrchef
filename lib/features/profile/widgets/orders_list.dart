import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';
import 'package:mrsheaf/features/profile/widgets/order_item_widget.dart';

class OrdersList extends GetView<MyOrdersController> {
  const OrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: controller.filteredOrders.length,
        itemBuilder: (context, index) {
          final order = controller.filteredOrders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrderItemWidget(
              order: order,
              onViewDetails: () => controller.viewOrderDetails(order),
            ),
          );
        },
      )),
    );
  }
}
