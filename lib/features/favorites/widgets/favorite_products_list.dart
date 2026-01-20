import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          child: Container(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              itemCount: controller.favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = controller.favoriteProducts[index];
                return FavoriteProductWidget(
                  product: product,
                  onRemove: () => controller.removeProductFromFavorites(product.id),
                  onTap: () => controller.navigateToProductDetails(product.id),
                );
              },
            )),
          ),
        ),
        
        // Add to cart button with loading state
        Container(
          margin: const EdgeInsets.all(24),
          child: Obx(() {
            final isAdding = controller.isAddingToCart.value;
            return ElevatedButton(
              onPressed: isAdding ? null : () {
                // Add all available products to cart
                for (var product in controller.favoriteProducts) {
                  if (product.isAvailable) {
                    controller.addToCart(product);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdding 
                    ? const Color(0xFFFACD02).withOpacity(0.6)
                    : const Color(0xFFFACD02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: isAdding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF592E2C)),
                      ),
                    )
                  : Text(
                      'add_to_cart'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF592E2C),
                        letterSpacing: -0.005,
                      ),
                    ),
            );
          }),
        ),
      ],
    );
  }
}
