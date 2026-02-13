import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';

/// Professional restaurant card for the Categories/Kitchens grid.
/// Unified design language matching the home-screen KitchenCard.
class KitchenCard extends StatelessWidget {
  final KitchenModel kitchen;

  const KitchenCard({
    super.key,
    required this.kitchen,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasRating = kitchen.averageRating > 0;

    return GestureDetector(
      onTap: () {
        Get.toNamed('/store-details', arguments: {
          'restaurantId': kitchen.id,
          'restaurant': kitchen,
        });
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ────── COVER IMAGE AREA ──────
            Expanded(
              flex: 5,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover / Logo Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: kitchen.logoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: kitchen.logoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _buildDefaultCover(),
                              errorWidget: (_, __, ___) => _buildDefaultCover(),
                            )
                          : _buildDefaultCover(),
                    ),
                  ),

                  // Gradient Overlay
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
                  if (kitchen.isFeatured)
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
                            const Icon(Icons.star_rounded, size: 11, color: Color(0xFF1A1A2E)),
                            const SizedBox(width: 2),
                            Text(
                              'featured'.tr,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Rating or New Badge (top right)
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
                      child: hasRating
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB800),
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  kitchen.ratingText,
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.fiber_new_rounded,
                                    color: AppColors.primaryColor,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'new'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // ────── INFO SECTION ──────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Name
                    Text(
                      kitchen.displayName,
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

                    // Category / specialty text
                    if (kitchen.specialties.isNotEmpty)
                      Text(
                        kitchen.specialties.take(2).join(' • '),
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

                    // Bottom row: delivery + items count
                    Row(
                      children: [
                        if (kitchen.offersDelivery) ...[
                          Icon(Icons.delivery_dining_rounded, size: 12, color: Colors.green.shade500),
                          const SizedBox(width: 3),
                          Text(
                            kitchen.deliveryFeeType == 'free'
                                ? 'free_delivery'.tr
                                : kitchen.deliveryFeeType == 'fixed'
                                    ? (kitchen.deliveryFee == 0
                                        ? 'free_delivery'.tr
                                        : '${'delivery'.tr} ${kitchen.deliveryFeeText}')
                                    : 'delivery_negotiable'.tr,
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        if (kitchen.offersDelivery && kitchen.totalProducts > 0)
                          Container(
                            width: 3,
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (kitchen.totalProducts > 0) ...[
                          Icon(Icons.restaurant_menu_rounded, size: 12, color: AppColors.secondaryColor),
                          const SizedBox(width: 3),
                          Text(
                            '${kitchen.totalProducts} ${'items'.tr}',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildDefaultCover() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
