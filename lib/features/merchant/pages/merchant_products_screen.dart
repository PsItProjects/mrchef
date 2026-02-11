import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_products_controller.dart';
import 'package:mrsheaf/features/merchant/models/merchant_product_model.dart';
import '../../../core/services/toast_service.dart';

class MerchantProductsScreen extends GetView<MerchantProductsController> {
  const MerchantProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: Column(
        children: [
          _buildHeader(topPad),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }
              if (controller.filteredProducts.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: controller.refreshProducts,
                color: AppColors.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: controller.filteredProducts.length,
                  itemBuilder: (_, i) =>
                      _buildProductCard(controller.filteredProducts[i]),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HEADER (Stats + Search + Filters — all in one container)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(double topPad) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: topPad + 8),
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _circleBtn(Icons.arrow_forward_rounded, () {
                  if (Get.key?.currentState?.canPop() ?? false) {
                    Get.back();
                  } else {
                    Get.offAllNamed('/merchant-home');
                  }
                }),
                const Spacer(),
                Text(
                  'my_products'.tr,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDarkColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                _circleBtn(Icons.search_rounded, () => _showSearchSheet()),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Stat pills ──
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _statPill(
                      controller.totalProducts.value.toString(),
                      'total_products'.tr,
                      AppColors.primaryColor,
                      Icons.inventory_2_rounded,
                    ),
                    const SizedBox(width: 10),
                    _statPill(
                      controller.availableProducts.value.toString(),
                      'available'.tr,
                      const Color(0xFF34C759),
                      Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 10),
                    _statPill(
                      controller.unavailableProducts.value.toString(),
                      'unavailable'.tr,
                      const Color(0xFFFF3B30),
                      Icons.cancel_rounded,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 14),

          // ── Filter chips ──
          Obx(() => SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _filterPill('all', 'all_products'.tr),
                    _filterPill('available', 'available_products'.tr),
                    _filterPill('unavailable', 'unavailable_products'.tr),
                    _filterPill('featured', 'featured_products'.tr),
                  ],
                ),
              )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFF4F5F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 22, color: AppColors.textDarkColor),
        ),
      ),
    );
  }

  Widget _statPill(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.08), color.withOpacity(0.04)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterPill(String type, String label) {
    final active = controller.filterType.value == type;
    return GestureDetector(
      onTap: () => controller.setFilterType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.secondaryColor : const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.secondaryColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            if (active) ...[
              const Icon(Icons.check_rounded, size: 14, color: AppColors.primaryColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PRODUCT CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildProductCard(MerchantProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () =>
              Get.toNamed('/merchant/products/details/${product.id}'),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // ── Image with badges ──
                _buildProductImage(product),
                const SizedBox(width: 14),

                // ── Info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + availability
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDarkColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _availabilityDot(product.isAvailable),
                        ],
                      ),
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey[400],
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Price row
                      Row(
                        children: [
                          // Price
                          if (product.hasDiscount) ...[
                            Text(
                              CurrencyHelper.formatPrice(
                                  product.effectivePrice),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF34C759),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              CurrencyHelper.formatPrice(
                                  product.basePrice),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey[400],
                              ),
                            ),
                          ] else
                            Text(
                              CurrencyHelper.formatPrice(
                                  product.basePrice),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDarkColor,
                              ),
                            ),
                          const Spacer(),
                          // Prep time
                          if (product.preparationTime != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined,
                                      size: 13,
                                      color: Colors.grey[400]),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${product.preparationTime} min',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Bottom row — switch + actions
                      Row(
                        children: [
                          // Toggle
                          SizedBox(
                            height: 28,
                            child: FittedBox(
                              child: Switch(
                                value: product.isAvailable,
                                onChanged: (v) => controller
                                    .toggleAvailability(product.id, v),
                                activeColor: const Color(0xFF34C759),
                                activeTrackColor:
                                    const Color(0xFF34C759).withOpacity(0.3),
                              ),
                            ),
                          ),
                          Text(
                            product.isAvailable
                                ? 'available'.tr
                                : 'unavailable'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: product.isAvailable
                                  ? const Color(0xFF34C759)
                                  : Colors.grey[400],
                            ),
                          ),
                          const Spacer(),
                          // Edit
                          _tinyAction(Icons.edit_outlined, () {
                            Get.toNamed(
                                '/merchant/products/edit/${product.id}');
                          }),
                          const SizedBox(width: 6),
                          // Delete
                          _tinyAction(Icons.delete_outline_rounded, () {
                            _confirmDelete(product);
                          }, color: Colors.red[300]!),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(MerchantProductModel product) {
    return SizedBox(
      width: 95,
      height: 95,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: product.primaryImage != null &&
                    product.primaryImage!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.primaryImage!,
                    width: 95,
                    height: 95,
                    fit: BoxFit.cover,
                    httpHeaders: const {
                      'Connection': 'keep-alive',
                      'Accept': 'image/*',
                    },
                    fadeInDuration: const Duration(milliseconds: 250),
                    maxHeightDiskCache: 400,
                    maxWidthDiskCache: 400,
                    memCacheHeight: 400,
                    memCacheWidth: 400,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFFF0F1F6),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          // Featured badge
          if (product.isFeatured)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.star_rounded,
                    color: AppColors.textDarkColor, size: 13),
              ),
            ),
          // Discount badge
          if (product.hasDiscount)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
                  ),
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  '-${product.discountPercentage?.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          // Unavailable overlay
          if (!product.isAvailable)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 95,
                height: 95,
                color: Colors.white.withOpacity(0.55),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 95,
      height: 95,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.fastfood_rounded, size: 36, color: Colors.grey[300]),
    );
  }

  Widget _availabilityDot(bool available) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: available ? const Color(0xFF34C759) : Colors.grey[350],
        boxShadow: available
            ? [
                BoxShadow(
                  color: const Color(0xFF34C759).withOpacity(0.4),
                  blurRadius: 6,
                ),
              ]
            : [],
      ),
    );
  }

  Widget _tinyAction(IconData icon, VoidCallback onTap,
      {Color color = const Color(0xFF9E9E9E)}) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined,
                size: 56, color: AppColors.secondaryColor.withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          Text(
            'no_products_found'.tr,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'add_your_first_product'.tr,
            style: TextStyle(fontSize: 13.5, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  FAB
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed('/merchant/products/add');
          if (result == true) controller.refreshProducts();
        },
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded,
            color: AppColors.textDarkColor, size: 22),
        label: Text(
          'add_product'.tr,
          style: const TextStyle(
            color: AppColors.textDarkColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SEARCH BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════

  void _showSearchSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            TextField(
              autofocus: true,
              onChanged: (v) => controller.setSearchQuery(v),
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textDarkColor),
              decoration: InputDecoration(
                hintText: 'search_products'.tr,
                hintStyle: TextStyle(color: Colors.grey[350]),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.secondaryColor.withOpacity(0.4)),
                filled: true,
                fillColor: const Color(0xFFF7F8FC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('done'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  DELETE CONFIRM
  // ═══════════════════════════════════════════════════════════════

  void _confirmDelete(MerchantProductModel product) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('delete_product'.tr),
        content: Text('confirm_delete_product'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,
                style: const TextStyle(color: AppColors.textDarkColor)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteProduct(product.id);
              if (success) {
                ToastService.showSuccess('product_deleted_successfully'.tr);
              }
            },
            child: Text('delete'.tr,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
