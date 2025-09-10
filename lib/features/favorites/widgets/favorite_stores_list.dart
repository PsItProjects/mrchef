import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';
import 'package:mrsheaf/features/favorites/widgets/favorite_store_widget.dart';

class FavoriteStoresList extends GetView<FavoritesController> {
  const FavoriteStoresList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: controller.favoriteStores.length,
        itemBuilder: (context, index) {
          final store = controller.favoriteStores[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FavoriteStoreWidget(
              store: store,
              onRemove: () => controller.removeStoreFromFavorites(store.id),
              onTap: () => controller.navigateToStoreDetails(store.id),
            ),
          );
        },
      )),
    );
  }
}
