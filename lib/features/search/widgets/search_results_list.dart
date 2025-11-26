import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/home/widgets/product_card.dart';

class SearchResultsList extends StatefulWidget {
  final RxList<Map<String, dynamic>> results;
  final VoidCallback onLoadMore;
  final bool hasMore;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onLoadMore,
    required this.hasMore,
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two items per row
          childAspectRatio: 0.68, // Width to height ratio (adjusted for better look)
          crossAxisSpacing: 12, // Horizontal spacing between items
          mainAxisSpacing: 16, // Vertical spacing between items
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

          final product = widget.results[index];

          return ProductCard(
            product: product,
            section: 'search',
          );
        },
      );
    });
  }
}

