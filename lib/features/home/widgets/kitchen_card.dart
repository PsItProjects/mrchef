import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/translation_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/widgets/app_card.dart';

import '../../../core/routes/app_routes.dart';

class KitchenCard extends StatelessWidget {
  final Map<String, dynamic> kitchen;

  const KitchenCard({
    super.key,
    required this.kitchen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        // Navigate to store details with restaurant data
        final restaurantId = kitchen['id']?.toString();
        if (kDebugMode) {
          print('🏪 KITCHEN CARD: Navigating to restaurant ID: $restaurantId');
          print('🏪 KITCHEN CARD: Restaurant data: $kitchen');
        }

        Get.toNamed(AppRoutes.STORE_DETAILS, arguments: {
          'restaurantId': restaurantId ?? '1',
          'restaurantData': kitchen,
        });
      },
      child: KitchenGradientCard(
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            // Background image placeholder
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 60,
                      color: AppColors.textLightColor,
                    ),
                  ),
                ),
              ),
            ),

            // Kitchen icon background
             Center(
                child: Container(
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
                      child: _buildKitchenImage(),
                    ),
                  ),
                ),

            ),

            // Kitchen name
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                kitchen['name'] ?? 'Master chef',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKitchenImage() {
    final imageUrl = kitchen['image'] ?? '';

    // If it's a network URL, use Image.network
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/kitchen_food.png',
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // Use local asset
      return Image.asset(
        imageUrl.isNotEmpty ? imageUrl : 'assets/images/kitchen_food.png',
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }
  }
}
