import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';
import 'package:mrsheaf/features/favorites/models/favorite_product_model.dart';

class FavoriteProductWidget extends StatelessWidget {
  final FavoriteProductModel product;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const FavoriteProductWidget({
    super.key,
    required this.product,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE3E3E3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                // Background
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFC4C4C4),
                  ),
                ),
                
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 100,
                      color: const Color(0xFFC4C4C4),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: const Color(0xFFC4C4C4),
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Product details
          Expanded(
            child: Container(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF262626),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        CurrencyHelper.formatPrice(product.price),
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF5E5E5E),
                        ),
                      ),
                    ],
                  ),
                  
                  // Availability status
                  Text(
                    product.availabilityText,
                    style: AppTheme.statusTextStyle.copyWith(
                      color: product.isAvailable
                          ? AppColors.successColor
                          : AppColors.errorColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Remove button (heart icon for favorites)
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.favorite,
                size: 20,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
