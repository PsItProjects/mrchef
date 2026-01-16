import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/products/controllers/all_products_controller.dart';
import 'package:mrsheaf/features/home/widgets/product_card.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get product type from arguments
    final String productType = Get.arguments?['type'] ?? 'best_seller';
    
    // Initialize controller with product type
    final controller = Get.put(
      AllProductsController(productType: productType),
      tag: productType,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(controller),
            
            const SizedBox(height: 16),
            
            // Search bar
            _buildSearchBar(controller),
            
            const SizedBox(height: 16),
            
            // Products grid
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }
                
                if (controller.filteredProducts.isEmpty) {
                  return _buildEmptyState(controller);
                }
                
                return RefreshIndicator(
                  onRefresh: controller.refreshProducts,
                  color: AppColors.primaryColor,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: controller.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.filteredProducts[index];
                      return ProductCard(
                        product: product.toJson(),
                        section: controller.productType,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AllProductsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textDarkColor,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              controller.screenTitle,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textDarkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AllProductsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() => Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.searchProducts,
          decoration: InputDecoration(
            hintText: 'search_for_products'.tr,
            hintStyle: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              color: AppColors.lightGreyTextColor,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.lightGreyTextColor,
              size: 20,
            ),
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clearSearch,
                    child: const Icon(
                      Icons.close,
                      color: AppColors.lightGreyTextColor,
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      )),
    );
  }

  Widget _buildEmptyState(AllProductsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.searchQuery.value.isNotEmpty
                ? Icons.search_off_rounded
                : Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.lightGreyTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'no_results_found'.tr
                : 'no_products_found'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'try_different_keywords'.tr
                : 'check_back_later'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              color: AppColors.lightGreyTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


