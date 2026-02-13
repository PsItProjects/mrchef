import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

import '../../../core/routes/app_routes.dart';

/// Professional restaurant card inspired by Talabat, HungerStation & UberEats.
/// Displays cover image, logo, name, categories, rating and delivery info.
class KitchenCard extends StatelessWidget {
  final Map<String, dynamic> kitchen;

  const KitchenCard({
    super.key,
    required this.kitchen,
  });

  // ─── Quick data accessors ───
  String get _name => (kitchen['name'] ?? 'restaurant'.tr).toString();
  String get _logoUrl => (kitchen['logo'] ?? kitchen['image'] ?? '').toString();
  String get _coverUrl => (kitchen['cover_image'] ?? '').toString();
  bool get _isFeatured => kitchen['is_featured'] == true || kitchen['is_featured'] == 1;
  bool get _isActive => kitchen['is_active'] != false && kitchen['is_active'] != 0;
  double get _rating => double.tryParse('${kitchen['average_rating'] ?? 0}') ?? 0;
  int get _reviewsCount => int.tryParse('${kitchen['reviews_count'] ?? 0}') ?? 0;
  bool get _hasRating => _rating > 0;
  String get _deliveryFeeType => (kitchen['delivery_fee_type'] ?? 'negotiable').toString();
  String get _deliveryFee {
    final fee = kitchen['delivery_fee'];
    if (fee == null || fee == '0' || fee == '0.00' || fee == 0) return '';
    return fee.toString();
  }
  bool get _offersDelivery => kitchen['offers_delivery'] == true || kitchen['offers_delivery'] == 1;

  List<String> get _categoryNames {
    final cats = kitchen['categories'];
    if (cats == null || cats is! List) return [];
    return cats.take(2).map<String>((c) {
      if (c is Map) {
        final name = c['name'];
        if (name is Map) {
          final lang = Get.locale?.languageCode ?? 'ar';
          return (name[lang] ?? name['ar'] ?? name['en'] ?? '').toString();
        }
        return (name ?? '').toString();
      }
      return c.toString();
    }).where((n) => n.isNotEmpty).toList();
  }

  int get _productsCount {
    final prods = kitchen['products'];
    if (prods is List) return prods.length;
    final count = kitchen['products_count'];
    return int.tryParse('${count ?? 0}') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final restaurantId = kitchen['id']?.toString();
        if (kDebugMode) {
          print('🏪 KITCHEN CARD: Navigating to restaurant ID: $restaurantId');
        }
        Get.toNamed(AppRoutes.STORE_DETAILS, arguments: {
          'restaurantId': restaurantId ?? '1',
          'restaurantData': kitchen,
        });
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ────── COVER IMAGE AREA ──────
            _CoverSection(
              coverUrl: _coverUrl,
              logoUrl: _logoUrl,
              isFeatured: _isFeatured,
              isActive: _isActive,
              hasRating: _hasRating,
              rating: _rating,
            ),

            // ────── INFO AREA ──────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name
                    Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Category chips
                    if (_categoryNames.isNotEmpty)
                      Text(
                        _categoryNames.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.3,
                        ),
                      ),

                    const Spacer(),

                    // Bottom row: rating + delivery info
                    _BottomInfoRow(
                      hasRating: _hasRating,
                      rating: _rating,
                      reviewsCount: _reviewsCount,
                      offersDelivery: _offersDelivery,
                      deliveryFee: _deliveryFee,
                      deliveryFeeType: _deliveryFeeType,
                      productsCount: _productsCount,
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
}

// ══════════════════════════════════════════════════════════════
//  COVER SECTION — image + gradient + logo overlay + badges
// ══════════════════════════════════════════════════════════════
class _CoverSection extends StatelessWidget {
  final String coverUrl;
  final String logoUrl;
  final bool isFeatured;
  final bool isActive;
  final bool hasRating;
  final double rating;

  const _CoverSection({
    required this.coverUrl,
    required this.logoUrl,
    required this.isFeatured,
    required this.isActive,
    required this.hasRating,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: coverUrl.isNotEmpty && coverUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildPlaceholderCover(),
                      errorWidget: (_, __, ___) => _buildPlaceholderCover(),
                    )
                  : _buildPlaceholderCover(),
            ),
          ),

          // Gradient overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),

          // Featured badge (top-left)
          if (isFeatured)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFF1A1A2E)),
                    const SizedBox(width: 3),
                    Text(
                      'featured'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Open/Closed badge (top-right)
          if (!isActive)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'closed'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Rating badge (top-right, if active and has rating)
          if (isActive && hasRating)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Logo overlay (bottom-left, overlapping the info area)
          Positioned(
            bottom: -18,
            left: 12,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildLogoImage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoImage() {
    if (logoUrl.isNotEmpty && logoUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildLogoPlaceholder(),
        errorWidget: (_, __, ___) => _buildLogoPlaceholder(),
      );
    }
    return _buildLogoPlaceholder();
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.15),
      child: const Icon(
        Icons.restaurant_rounded,
        color: AppColors.primaryColor,
        size: 20,
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryColor.withValues(alpha: 0.75),
            AppColors.secondaryColor.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 36,
          color: AppColors.primaryColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTTOM INFO ROW — rating dot delivery dot items
// ══════════════════════════════════════════════════════════════
class _BottomInfoRow extends StatelessWidget {
  final bool hasRating;
  final double rating;
  final int reviewsCount;
  final bool offersDelivery;
  final String deliveryFee;
  final String deliveryFeeType;
  final int productsCount;

  const _BottomInfoRow({
    required this.hasRating,
    required this.rating,
    required this.reviewsCount,
    required this.offersDelivery,
    required this.deliveryFee,
    required this.deliveryFeeType,
    required this.productsCount,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    // Rating + reviews
    if (hasRating) {
      chips.add(_infoChip(
        Icons.star_rounded,
        '${rating.toStringAsFixed(1)} (${reviewsCount})',
        const Color(0xFFFFB800),
      ));
    }

    // Delivery - based on delivery_fee_type
    if (offersDelivery) {
      String label;
      switch (deliveryFeeType) {
        case 'free':
          label = 'free_delivery'.tr;
          break;
        case 'fixed':
          label = deliveryFee.isEmpty
              ? 'free_delivery'.tr
              : '${'delivery'.tr} $deliveryFee';
          break;
        case 'negotiable':
        default:
          label = 'delivery_negotiable'.tr;
          break;
      }
      chips.add(_infoChip(
        Icons.delivery_dining_rounded,
        label,
        Colors.green.shade500,
      ));
    }

    // Products count
    if (productsCount > 0 && chips.length < 2) {
      chips.add(_infoChip(
        Icons.restaurant_menu_rounded,
        '$productsCount ${'items'.tr}',
        AppColors.secondaryColor,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Row(
      children: chips.length == 1
          ? chips
          : [
              Flexible(child: chips[0]),
              Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              Flexible(child: chips[1]),
            ],
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              fontSize: 10.5,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
