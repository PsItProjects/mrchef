import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_products_controller.dart';
import 'package:mrsheaf/features/merchant/models/merchant_product_model.dart';
import '../../../core/services/toast_service.dart';

/// Screen for managing merchant products
class MerchantProductsScreen extends GetView<MerchantProductsController> {
  const MerchantProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDarkColor),
          onPressed: () {
            // If can't go back (no history), go to merchant settings
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offAllNamed('/merchant-home');
            }
          },
        ),
        title: Text(
          'my_products'.tr,
          style: const TextStyle(
            color: AppColors.textDarkColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDarkColor),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textDarkColor),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatisticsCards(),

          // Filter Chips
          _buildFilterChips(),

          // Products List
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
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshProducts,
                color: AppColors.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = controller.filteredProducts[index];
                    return _buildProductCard(product);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to add product screen and wait for result
          final result = await Get.toNamed('/merchant/products/add');

          // If product was added successfully, refresh the list
          if (result == true) {
            controller.refreshProducts();
          }
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: AppColors.secondaryColor),
        label: Text(
          'add_product'.tr,
          style: const TextStyle(
            color: AppColors.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build statistics cards
  Widget _buildStatisticsCards() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'total_products'.tr,
                  controller.totalProducts.value.toString(),
                  Icons.inventory_2,
                  AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'available'.tr,
                  controller.availableProducts.value.toString(),
                  Icons.check_circle,
                  AppColors.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'unavailable'.tr,
                  controller.unavailableProducts.value.toString(),
                  Icons.cancel,
                  AppColors.errorColor,
                ),
              ),
            ],
          ),
        ));
  }

  /// Build single stat card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('all', 'all_products'.tr),
              const SizedBox(width: 8),
              _buildFilterChip('available', 'available_products'.tr),
              const SizedBox(width: 8),
              _buildFilterChip('unavailable', 'unavailable_products'.tr),
              const SizedBox(width: 8),
              _buildFilterChip('featured', 'featured_products'.tr),
            ],
          ),
        ));
  }

  /// Build single filter chip
  Widget _buildFilterChip(String type, String label) {
    final isSelected = controller.filterType.value == type;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.setFilterType(type);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondaryColor : AppColors.textDarkColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: AppColors.secondaryColor,
    );
  }

  /// Build product card
  Widget _buildProductCard(MerchantProductModel product) {
    if (kDebugMode) {
      print('🖼️ Building card for product ${product.id}: ${product.name}');
      print('   primaryImage: ${product.primaryImage}');
      print('   images count: ${product.images.length}');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: product.isAvailable
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to product details screen
            Get.toNamed('/merchant/products/details/${product.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Product Image with Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: product.primaryImage != null && product.primaryImage!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.primaryImage!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              httpHeaders: const {
                                'Connection': 'keep-alive',
                                'Accept': 'image/*',
                              },
                              fadeInDuration: const Duration(milliseconds: 300),
                              fadeOutDuration: const Duration(milliseconds: 100),
                              maxHeightDiskCache: 400,
                              maxWidthDiskCache: 400,
                              memCacheHeight: 400,
                              memCacheWidth: 400,
                              placeholder: (context, url) => Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                if (kDebugMode) {
                                  print('❌ Error loading image for product ${product.id}:');
                                  print('   URL: $url');
                                  print('   Error: $error');
                                }
                                return _buildPlaceholderImage();
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),
                    // Featured Badge
                    if (product.isFeatured)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    // Discount Badge
                    if (product.hasDiscount)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${product.discountPercentage}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDarkColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Availability Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? AppColors.successColor.withOpacity(0.1)
                                  : AppColors.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.isAvailable ? 'available'.tr : 'unavailable'.tr,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: product.isAvailable
                                    ? AppColors.successColor
                                    : AppColors.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (product.description != null)
                        Text(
                          product.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMediumColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            CurrencyHelper.formatPrice(product.effectivePrice),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 8),
                            Text(
                              CurrencyHelper.formatPrice(product.basePrice),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMediumColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Preparation Time
                          if (product.preparationTime != null) ...[
                            const Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: AppColors.textMediumColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.preparationTime} min',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMediumColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Availability Switch
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: product.isAvailable,
                        onChanged: (value) {
                          controller.toggleAvailability(product.id, value);
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                    ),

                    // More Options
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.textMediumColor),
                      onPressed: () => _showProductOptions(product),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build placeholder image
  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(
        Icons.fastfood,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'no_products_found'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'add_your_first_product'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Show search dialog
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('search_products'.tr),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'search_products'.tr,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              controller.setSearchQuery(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.setSearchQuery('');
                Get.back();
              },
              child: Text('cancel'.tr),
            ),
          ],
        );
      },
    );
  }

  /// Show filter dialog
  void _showFilterDialog(BuildContext context) {
    // TODO: Implement category filter dialog
    ToastService.showInfo('feature_under_development'.tr);
  }

  /// Show product options
  void _showProductOptions(MerchantProductModel product) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primaryColor),
              title: Text('edit_product'.tr),
              onTap: () {
                Get.back();
                Get.toNamed('/merchant/products/edit/${product.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('delete_product'.tr, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _confirmDelete(product);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Confirm delete product
  void _confirmDelete(MerchantProductModel product) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_product'.tr),
        content: Text('confirm_delete_product'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteProduct(product.id);
              if (success) {
                ToastService.showSuccess('product_deleted_successfully'.tr);
              }
            },
            child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

