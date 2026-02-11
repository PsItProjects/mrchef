import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/widgets/product_card.dart';
import 'package:mrsheaf/features/home/models/restaurant_model.dart';
import 'package:mrsheaf/features/restaurants/widgets/restaurant_grid_item.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';

class SearchResultsList extends StatefulWidget {
  final RxList<Map<String, dynamic>> results;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final String searchType; // 'products' or 'restaurants'

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onLoadMore,
    required this.hasMore,
    this.searchType = 'products',
  });

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: widget.searchType == 'restaurants' ? 0.85 : 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: widget.results.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == widget.results.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            );
          }

          final item = widget.results[index];

          // Show restaurant card or product card based on search type
          if (widget.searchType == 'restaurants') {
            final restaurant = RestaurantModel.fromJson(item);
            return RestaurantGridItem(
              restaurant: restaurant,
              onTap: () => Get.toNamed(
                AppRoutes.STORE_DETAILS,
                arguments: {'restaurant': restaurant},
              ),
            );
          }

          return ProductCard(
            product: item,
            section: 'search',
          );
        },
      );
    });
  }
}

