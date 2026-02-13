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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Get.locale?.languageCode == 'ar'
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_rounded,
            size: 20,
            color: AppColors.textDarkColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'favorites'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textDarkColor,
          ),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                  size: 22,
                  color: AppColors.textDarkColor,
                ),
                onPressed: controller.toggleSearch,
              )),
        ],
      ),
      body: Column(
        children: [
          // Search bar (conditional)
          const FavoritesHeader(),

          // Tabs
          const FavoritesTabs(),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              } else if (controller.showEmptyState) {
                return const EmptyFavoritesWidget();
              } else {
                return RefreshIndicator(
                  onRefresh: controller.refreshFavorites,
                  color: AppColors.primaryColor,
                  child: controller.isStoresTabSelected
                      ? const FavoriteStoresList()
                      : const FavoriteProductsList(),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
