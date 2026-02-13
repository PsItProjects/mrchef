import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/home/controllers/home_controller.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/services/language_service.dart';

/// World-class product card inspired by Talabat, HungerStation & UberEats.
/// Supports horizontal lists (fixed width) and grid layouts (fills parent).
class ProductCard extends GetView<HomeController> {
  final Map<String, dynamic> product;
  final String section;

  const ProductCard({
    super.key,
    required this.product,
    required this.section,
  });

  // Quick getters
  bool get _isHorizontal => section != 'search' && section != 'categories';
  double get _price => double.tryParse('${product['price'] ?? 0}') ?? 0;
  double? get _originalPrice {
    final op = product['originalPrice'];
    if (op == null) return null;
    final v = double.tryParse('$op');
    return (v != null && v > _price) ? v : null;
  }

  bool get _hasDiscount =>
      product['has_discount'] == true || _originalPrice != null;
  double get _discountPct {
    if (_hasDiscount && _originalPrice != null && _originalPrice! > 0) {
      return ((1 - _price / _originalPrice!) * 100);
    }
    return double.tryParse('${product['discount_percentage'] ?? 0}') ?? 0;
  }

  double get _rating => double.tryParse('${product['rating'] ?? 0}') ?? 0;
  int get _reviewCount => int.tryParse('${product['reviewCount'] ?? 0}') ?? 0;
  bool get _hasRating => _rating > 0 && _reviewCount > 0;
  String get _description =>
      LanguageService.instance.getLocalizedText(product['description']).trim();
  String get _foodNationalityName => (product['food_nationality_name'] ?? '').toString().trim();
  String get _governorateName => (product['governorate_name'] ?? '').toString().trim();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToDetails,
      child: Container(
        width: _isHorizontal ? 168 : null,
        margin: _isHorizontal ? const EdgeInsets.only(right: 12) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ────── IMAGE AREA ──────
            Expanded(
              flex: 5,
              child: _ImageArea(
                imageUrl: (product['image'] ?? product['primary_image'] ?? '') as String,
                hasDiscount: _hasDiscount,
                discountPct: _discountPct,
                hasRating: _hasRating,
                rating: _rating,
                reviewCount: _reviewCount,
                isSpicy: product['is_spicy'] == true,
                isVegan: product['is_vegan'] == true,
                isVegetarian: product['is_vegetarian'] == true,
              ),
            ),

            // ────── INFO AREA ──────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Short description snippet
                    Text(
                      _description.isNotEmpty ? _description : 'delicious_meal'.tr,
                      maxLines: (_foodNationalityName.isNotEmpty || _governorateName.isNotEmpty) ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                    ),

                    // Food nationality & governorate tags
                    if (_foodNationalityName.isNotEmpty || _governorateName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (_foodNationalityName.isNotEmpty)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EDFF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.public_rounded, size: 10, color: Colors.purple.shade400),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        _foodNationalityName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9.5,
                                          color: Colors.purple.shade600,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_foodNationalityName.isNotEmpty && _governorateName.isNotEmpty)
                            const SizedBox(width: 4),
                          if (_governorateName.isNotEmpty)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EAF6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_city_rounded, size: 10, color: Colors.indigo.shade400),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        _governorateName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9.5,
                                          color: Colors.indigo.shade600,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const Spacer(),

                    // Price row + Add button
                    _buildPriceRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PRICE ROW (price + cart btn) ────
  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Prices column
        Expanded(
          child: _hasDiscount && _originalPrice != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Discounted (effective) price — large, bold, green
                    Text(
                      CurrencyHelper.formatPrice(_price),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF1B8C3E),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Original price — strikethrough, small
                    Text(
                      CurrencyHelper.formatPrice(_originalPrice!),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.red.shade300,
                        decorationThickness: 2,
                        height: 1,
                      ),
                    ),
                  ],
                )
              : Text(
                  CurrencyHelper.formatPrice(_price),
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                    height: 1.2,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        // Cart button
        _buildCartButton(),
      ],
    );
  }

  // ─── CART BUTTON ────────────────
  Widget _buildCartButton() {
    return Obx(() {
      final isAdding = controller.isAddingToCart.value;
      return GestureDetector(
        onTap: isAdding ? null : () => controller.addToCart(product['id']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isAdding ? AppColors.primaryColor.withOpacity(0.6) : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isAdding
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A2E)),
                )
              : const Icon(Icons.add_rounded, size: 20, color: Color(0xFF1A1A2E)),
        ),
      );
    });
  }

  void _navigateToDetails() {
    final productId = product['id'];
    if (productId == null) {
      ToastService.showError('معرف المنتج غير صحيح');
      return;
    }
    Get.toNamed(AppRoutes.PRODUCT_DETAILS, arguments: {'productId': productId});
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// IMAGE AREA — separated for clarity
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ImageArea extends StatelessWidget {
  final String imageUrl;
  final bool hasDiscount;
  final double discountPct;
  final bool hasRating;
  final double rating;
  final int reviewCount;
  final bool isSpicy;
  final bool isVegan;
  final bool isVegetarian;

  const _ImageArea({
    required this.imageUrl,
    required this.hasDiscount,
    required this.discountPct,
    required this.hasRating,
    required this.rating,
    required this.reviewCount,
    required this.isSpicy,
    required this.isVegan,
    required this.isVegetarian,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Product photo
          _buildPhoto(),

          // Soft gradient at bottom for badge readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.35),
                  ],
                ),
              ),
            ),
          ),

          // Discount badge — top left
          if (hasDiscount && discountPct > 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-${discountPct.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Lato',
                    height: 1,
                  ),
                ),
              ),
            ),

          // Dietary icon — top right
          if (isSpicy || isVegan || isVegetarian)
            Positioned(
              top: 8,
              right: 8,
              child: _buildDietaryDot(),
            ),

          // Rating / New badge — bottom left, over the gradient
          Positioned(
            bottom: 7,
            left: 8,
            child: hasRating ? _buildRatingBadge() : _buildNewBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto() {
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: const Color(0xFFF5F5F5),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Icon(Icons.restaurant_rounded, size: 36, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB800)),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: Color(0xFF1A1A2E),
              height: 1,
            ),
          ),
          if (reviewCount > 0) ...[
            Text(
              ' ($reviewCount)',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 10,
                color: Colors.grey.shade500,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fiber_new_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            'new'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryDot() {
    IconData icon;
    Color color;
    if (isVegan) {
      icon = Icons.spa_rounded;
      color = Colors.teal;
    } else if (isVegetarian) {
      icon = Icons.eco_rounded;
      color = const Color(0xFF43A047);
    } else {
      icon = Icons.local_fire_department_rounded;
      color = const Color(0xFFE53935);
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 5)],
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
