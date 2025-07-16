import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/my_orders_controller.dart';
import 'package:mrsheaf/features/profile/widgets/my_orders_header.dart';
import 'package:mrsheaf/features/profile/widgets/my_orders_tabs.dart';
import 'package:mrsheaf/features/profile/widgets/empty_orders_widget.dart';
import 'package:mrsheaf/features/profile/widgets/orders_list.dart';

class MyOrdersScreen extends GetView<MyOrdersController> {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const MyOrdersHeader(),
            
            // Tabs
            const MyOrdersTabs(),
            
            // Content
            Expanded(
              child: Obx(() {
                if (!controller.hasOrdersInCurrentTab) {
                  return const EmptyOrdersWidget();
                } else {
                  return const OrdersList();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
