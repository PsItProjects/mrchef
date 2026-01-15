import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/my_reviews_controller.dart';

class MyReviewsHeader extends GetView<MyReviewsController> {
  const MyReviewsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Color(0xFF262626),
              ),
            ),
          ),

          // Title or Search Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: controller.isSearching.value
                  ? _buildSearchField()
                  : Center(
                      child: Text(
                        'my_reviews'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF262626),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
            ),
          ),

          // Search button
          GestureDetector(
            onTap: controller.toggleSearch,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                size: 20,
                color: const Color(0xFF262626),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  /// Build inline search field
  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      onChanged: controller.updateSearchQuery,
      decoration: InputDecoration(
        hintText: 'search_by_product_or_review'.tr,
        hintStyle: const TextStyle(
          fontFamily: 'Lato',
          fontSize: 14,
          color: Color(0xFFCCCCCC),
        ),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        isDense: true,
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF999999),
          size: 20,
        ),
        suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF999999),
                  size: 20,
                ),
                onPressed: controller.clearSearch,
              )
            : const SizedBox.shrink()),
      ),
      style: const TextStyle(
        fontFamily: 'Lato',
        fontSize: 14,
        color: Color(0xFF262626),
      ),
    );
  }
}
