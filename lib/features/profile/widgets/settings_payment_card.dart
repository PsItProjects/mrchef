import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/settings_controller.dart';

class SettingsPaymentCard extends GetView<SettingsController> {
  const SettingsPaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE3E3E3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Payment method info
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
                
                SizedBox(height: 4),
                
                Text(
                  'You have 2 cards',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
            
            // Arrow icon
            GestureDetector(
              onTap: controller.navigateToPaymentMethods,
              child: Container(
                width: 24,
                height: 24,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF262626),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
