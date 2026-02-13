import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';
import 'package:mrsheaf/features/favorites/widgets/favorite_product_widget.dart';

class FavoriteProductsList extends GetView<FavoritesController> {
  const FavoriteProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Products list
        Expanded(
          child: Obx(() => ListView.builder(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                itemCount: controller.favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.favoriteProducts[index];
                  return FavoriteProductWidget(
                    product: product,
                    onRemove: () =>
                        controller.removeProductFromFavorites(product.id),
                    onTap: () =>
                        controller.navigateToProductDetails(product.id),
                  );
                },
              )),
        ),

        // Add to cart button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Obx(() {
              final isAdding = controller.isAddingToCart.value;
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () {
                          for (var product in controller.favoriteProducts) {
                            if (product.isAvailable) {
                              controller.addToCart(product);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor:
                        AppColors.primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: isAdding
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textDarkColor,
                          ),
                        )
                      : Text(
                          'add_to_cart'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textDarkColor,
                          ),
                        ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
