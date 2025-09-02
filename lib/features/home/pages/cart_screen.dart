import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/cart/controllers/cart_controller.dart';
import 'package:mrsheaf/features/cart/widgets/cart_header.dart';
import 'package:mrsheaf/features/cart/widgets/empty_cart_widget.dart';
import 'package:mrsheaf/features/cart/widgets/cart_items_list.dart';
import 'package:mrsheaf/features/cart/widgets/cart_summary_section.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const CartHeader(),

            // Cart content
            Expanded(
              child: Obx(() {
                if (controller.cartItems.isEmpty) {
                  return const EmptyCartWidget();
                } else {
                  return Column(
                    children: [
                      // Store info section - as per Figma
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Master chef',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Color(0xFF262626),
                                letterSpacing: -0.005,
                              ),
                            ),
                            Text(
                              TranslationHelper.getQuantityText(controller.totalItemsCount, 'item'.tr),
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Color(0xFF262626),
                                letterSpacing: -0.005,
                              ),
                            ),
                          ],
                        )),
                      ),

                      // Cart items list
                      Expanded(
                        child: const CartItemsList(),
                      ),
                      // Cart summary and checkout
                      const CartSummarySection(),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
