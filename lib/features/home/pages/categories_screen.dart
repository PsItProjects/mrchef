import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/categories/controllers/categories_controller.dart';
import 'package:mrsheaf/features/categories/widgets/categories_header.dart';
import 'package:mrsheaf/features/categories/widgets/search_bar_with_filter.dart';
import 'package:mrsheaf/features/categories/widgets/category_tabs.dart';
import 'package:mrsheaf/features/categories/widgets/category_filter_chips.dart';
import 'package:mrsheaf/features/categories/widgets/filter_result_chips.dart';
import 'package:mrsheaf/features/home/widgets/product_card.dart';
import 'package:mrsheaf/features/categories/widgets/kitchen_card.dart';

class CategoriesScreen extends GetView<CategoriesController> {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Background color from Figma
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header
            const CategoriesHeader(),

            const SizedBox(height: 24),

            // Search bar with filter
            const SearchBarWithFilter(),

            const SizedBox(height: 24),

            // Category tabs (Meals/Kitchens)
            const CategoryTabs(),

            const SizedBox(height: 24),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  // Meals tab with RefreshIndicator
                  RefreshIndicator(
                    onRefresh: () async {
                      await controller.refreshCategoriesPageData();
                    },
                    color: const Color(0xFFFACD02), // Primary yellow color
                    backgroundColor: Colors.white,
                    child: CustomScrollView(
                      slivers: [
                        // Category filter chips
                        const SliverToBoxAdapter(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CategoryFilterChips(),
                              SizedBox(height: 16),
                              FilterResultChips(),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Products grid as SliverGrid
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          sliver: Obx(() => SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 182 / 223,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = controller.filteredProducts[index];
                                return ProductCard(
                                  product: {
                                    'id': product.id,
                                    'name': product.name,
                                    'price': product.price,
                                    'originalPrice': product.originalPrice,
                                    'image': product.image,
                                    'rating': product.rating,
                                    'reviewCount': product.reviewCount,
                                  },
                                  section: 'categories',
                                );
                              },
                              childCount: controller.filteredProducts.length,
                            ),
                          )),
                        ),

                        // Bottom padding
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
                  ),

                  // Kitchens tab with RefreshIndicator
                  RefreshIndicator(
                    onRefresh: () async {
                      await controller.refreshKitchens();
                    },
                    color: const Color(0xFFFACD02), // Primary yellow color
                    backgroundColor: Colors.white,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          sliver: Obx(() => SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 182 / 223,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return KitchenCard(
                                  kitchen: controller.kitchens[index],
                                );
                              },
                              childCount: controller.kitchens.length,
                            ),
                          )),
                        ),

                        // Bottom padding
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
