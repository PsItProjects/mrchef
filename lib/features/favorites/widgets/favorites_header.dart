import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/favorites/controllers/favorites_controller.dart';

class FavoritesHeader extends GetView<FavoritesController> {
  const FavoritesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isSearching.value) return const SizedBox.shrink();

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: TextField(
          controller: controller.searchTextController,
          autofocus: true,
          onChanged: controller.updateSearchQuery,
          decoration: InputDecoration(
            hintText: 'search_by_name'.tr,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            isDense: true,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade400,
              size: 20,
            ),
            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                    onPressed: () => controller.updateSearchQuery(''),
                  )
                : const SizedBox.shrink()),
          ),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textDarkColor,
          ),
        ),
      );
    });
  }
}
