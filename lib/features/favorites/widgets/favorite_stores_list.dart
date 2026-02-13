import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';
import 'package:mrsheaf/features/favorites/widgets/favorite_store_widget.dart';

class FavoriteStoresList extends GetView<FavoritesController> {
  const FavoriteStoresList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.only(top: 6, bottom: 16),
          itemCount: controller.favoriteStores.length,
          itemBuilder: (context, index) {
            final store = controller.favoriteStores[index];
            return FavoriteStoreWidget(
              store: store,
              onRemove: () => controller.removeStoreFromFavorites(store.id),
              onTap: () => controller.navigateToStoreDetails(store.id),
            );
          },
        ));
  }
}
