import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/widgets/app_card.dart';
import 'package:mrsheaf/features/categories/models/category_model.dart';

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
        Get.snackbar(
          'Kitchen Selected',
          '${kitchen.name} - ${kitchen.rating}★ (${kitchen.reviewCount} reviews)',
          snackPosition: SnackPosition.BOTTOM,
        );
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
                    child: Image.asset(
                      kitchen.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Kitchen name
              Text(
                kitchen.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
