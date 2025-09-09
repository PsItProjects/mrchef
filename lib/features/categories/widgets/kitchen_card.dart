import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/widgets/app_card.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';

class KitchenCard extends StatelessWidget {
  final KitchenModel kitchen;

  const KitchenCard({
    super.key,
    required this.kitchen,
  });

  @override
  Widget build(BuildContext context) {
    return KitchenGradientCard(
      onTap: () {
        // Navigate to store details page
        Get.toNamed('/store-details', arguments: {
          'restaurantId': kitchen.id,
          'restaurant': kitchen,
        });
      },
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Kitchen image background
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 17,
                      offset: const Offset(0, -5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 11,
                      offset: const Offset(0, -4),
                      spreadRadius: 0,
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: kitchen.logo != null
                        ? Image.network(
                            '${ApiConstants.baseUrl}/storage/${kitchen.logo}',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  color: AppColors.primaryColor,
                                  size: 30,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: AppColors.primaryColor,
                              size: 30,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Kitchen name
              Text(
                kitchen.displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 4),

              // Rating and reviews
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    kitchen.ratingText,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${kitchen.reviewCount})',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
