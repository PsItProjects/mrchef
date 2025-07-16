import 'package:flutter/material.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class KitchenCard extends StatelessWidget {
  final Map<String, dynamic> kitchen;

  const KitchenCard({
    super.key,
    required this.kitchen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      height: 223,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D5F8B).withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image placeholder
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFA44502), // Brown gradient from Figma
                      Color(0xFF8F3A02),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 60,
                    color: Colors.white54,
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
                    child: Image.asset(
                      'assets/images/kitchen_food.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
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
    );
  }
}
