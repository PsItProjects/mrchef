import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/features/favorites/models/favorite_store_model.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class FavoriteStoreWidget extends StatelessWidget {
  final FavoriteStoreModel store;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const FavoriteStoreWidget({
    super.key,
    required this.store,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Background image with heart overlay
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 140,
                    child: store.backgroundImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: store.backgroundImage,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(Icons.restaurant_rounded,
                                    color: Colors.grey.shade300, size: 32),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(Icons.restaurant_rounded,
                                    color: Colors.grey.shade300, size: 32),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: Icon(Icons.restaurant_rounded,
                                  color: Colors.grey.shade300, size: 32),
                            ),
                          ),
                  ),
                  // Heart button
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Store info row
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Store logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: store.image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: store.image,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade100,
                                child: Icon(Icons.store_rounded,
                                    color: Colors.grey.shade300, size: 18),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade100,
                                child: Icon(Icons.store_rounded,
                                    color: Colors.grey.shade300, size: 18),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.store_rounded,
                                  color: Colors.grey.shade300, size: 18),
                            ),
                    ),

                    const SizedBox(width: 10),

                    // Name + rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textDarkColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 15, color: AppColors.primaryColor),
                              const SizedBox(width: 3),
                              Text(
                                store.rating.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (store.deliveryFee != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Icon(Icons.delivery_dining_rounded,
                                    size: 15, color: Colors.grey.shade500),
                                const SizedBox(width: 3),
                                Text(
                                  '${store.deliveryFee?.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
