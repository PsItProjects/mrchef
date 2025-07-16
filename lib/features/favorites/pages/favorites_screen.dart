import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';
import 'package:mrsheaf/features/favorites/widgets/favorites_header.dart';
import 'package:mrsheaf/features/favorites/widgets/favorites_tabs.dart';
import 'package:mrsheaf/features/favorites/widgets/empty_favorites_widget.dart';
import 'package:mrsheaf/features/favorites/widgets/favorite_stores_list.dart';
import 'package:mrsheaf/features/favorites/widgets/favorite_products_list.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const FavoritesHeader(),
            
            // Tabs
            const FavoritesTabs(),
            
            // Content
            Expanded(
              child: Obx(() {
                if (controller.showEmptyState) {
                  return const EmptyFavoritesWidget();
                } else {
                  return controller.isStoresTabSelected
                      ? const FavoriteStoresList()
                      : const FavoriteProductsList();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
