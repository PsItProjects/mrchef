import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_products_controller.dart';

class ProductDetailsScreen extends GetView<MerchantProductsController> {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get product ID from route parameters
    final productId = int.parse(Get.parameters['id'] ?? '0');

    // Load product details
    controller.loadProduct(productId);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        final product = controller.selectedProduct.value;
        if (product == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textMediumColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'product_not_found'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textMediumColor,
                  ),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // App Bar with Image
            _buildSliverAppBar(product),

            // Content
            SliverList(
              delegate: SliverChildListDelegate([
                _buildBasicInfo(product),
                const SizedBox(height: 16),
                _buildPricingInfo(product),
                const SizedBox(height: 16),
                _buildDetailsInfo(product),
                const SizedBox(height: 16),
                _buildDietaryInfo(product),
                const SizedBox(height: 16),
                _buildOptionGroups(product),
                const SizedBox(height: 16),
                _buildStatistics(product),
                const SizedBox(height: 100), // Space for FAB
              ]),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/merchant/products/edit/$productId');
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: Text(
          'edit_product'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(product) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showProductOptions(product),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          product.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Product Image
            if (product.primaryImage != null && product.primaryImage!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: product.primaryImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
                ),
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Availability Badge
            Positioned(
              top: 60,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: product.isAvailable
                      ? AppColors.successColor
                      : AppColors.errorColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.isAvailable ? 'available'.tr : 'unavailable'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Featured Badge
            if (product.isFeatured)
              Positioned(
                top: 60,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'featured'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'basic_information'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('product_name_en'.tr, product.nameEn),
          const Divider(height: 24),
          _buildInfoRow('product_name_ar'.tr, product.nameAr),
          if (product.descriptionEn != null && product.descriptionEn!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildInfoRow('description_en'.tr, product.descriptionEn!),
          ],
          if (product.descriptionAr != null && product.descriptionAr!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildInfoRow('description_ar'.tr, product.descriptionAr!),
          ],
          if (product.categoryName != null) ...[
            const Divider(height: 24),
            _buildInfoRow('category'.tr, product.categoryName!),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingInfo(product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'pricing'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceCard(
                  'base_price'.tr,
                  '\$${product.basePrice.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  AppColors.primaryColor,
                ),
              ),
              if (product.discountPercentage != null && product.discountPercentage! > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriceCard(
                    'discount'.tr,
                    '${product.discountPercentage!.toStringAsFixed(0)}%',
                    Icons.local_offer,
                    AppColors.errorColor,
                  ),
                ),
              ],
            ],
          ),
          if (product.discountedPrice != null && product.discountedPrice! > 0) ...[
            const SizedBox(height: 12),
            _buildPriceCard(
              'final_price'.tr,
              '\$${product.discountedPrice!.toStringAsFixed(2)}',
              Icons.price_check,
              AppColors.successColor,
            ),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(
            'preparation_time'.tr,
            '${product.preparationTime} ${'minutes'.tr}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsInfo(product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'additional_details'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (product.calories != null && product.calories! > 0)
            _buildInfoRow('calories'.tr, '${product.calories} ${'kcal'.tr}'),
          if (product.ingredients != null && product.ingredients!.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'ingredients'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.ingredients!.map<Widget>((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDietaryInfo(product) {
    final dietaryItems = <Map<String, dynamic>>[];

    if (product.isVegetarian) {
      dietaryItems.add({
        'label': 'vegetarian'.tr,
        'icon': Icons.eco,
        'color': Colors.green,
      });
    }
    if (product.isVegan) {
      dietaryItems.add({
        'label': 'vegan'.tr,
        'icon': Icons.spa,
        'color': Colors.lightGreen,
      });
    }
    if (product.isGlutenFree) {
      dietaryItems.add({
        'label': 'gluten_free'.tr,
        'icon': Icons.grain,
        'color': Colors.orange,
      });
    }
    if (product.isSpicy) {
      dietaryItems.add({
        'label': 'spicy'.tr,
        'icon': Icons.local_fire_department,
        'color': Colors.red,
      });
    }

    if (dietaryItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'dietary_information'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: dietaryItems.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (item['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: item['color'] as Color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionGroups(product) {
    if (product.optionGroups.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'option_groups'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...product.optionGroups.map((group) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDarkColor,
                          ),
                        ),
                      ),
                      if (group.isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'required'.tr,
                            style: TextStyle(
                              color: AppColors.errorColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${group.minSelections} - ${group.maxSelections} ${'selections'.tr}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMediumColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...group.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textDarkColor,
                              ),
                            ),
                          ),
                          if (option.additionalPrice > 0)
                            Text(
                              '+\$${option.additionalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatistics(product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'statistics'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'total_orders'.tr,
                  product.totalOrders.toString(),
                  Icons.shopping_cart,
                  AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'rating'.tr,
                  product.averageRating.toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'reviews'.tr,
                  product.reviewsCount.toString(),
                  Icons.rate_review,
                  AppColors.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMediumColor,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDarkColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMediumColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMediumColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showProductOptions(product) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
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
              leading: Icon(
                product.isAvailable ? Icons.visibility_off : Icons.visibility,
                color: AppColors.primaryColor,
              ),
              title: Text(
                product.isAvailable ? 'mark_unavailable'.tr : 'mark_available'.tr,
              ),
              onTap: () {
                Get.back();
                controller.toggleAvailability(product.id, !product.isAvailable);
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

  void _confirmDelete(product) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_product'.tr),
        content: Text('delete_product_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(product.id);
              Get.back(); // Go back to products list
            },
            child: Text(
              'delete'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}


