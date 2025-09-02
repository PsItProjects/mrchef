import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class AdditionalOptionsSection extends GetView<ProductDetailsController> {
  const AdditionalOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Additional options'.tr,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Options list
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.additionalOptions.map((option) {
              return GestureDetector(
                onTap: () => controller.toggleAdditionalOption(option.id),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: option.isSelected 
                        ? AppColors.primaryColor 
                        : const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon placeholder (salad icon)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECECEC),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 0.5),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 4),
                      
                      // Option text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.name,
                            style: TextStyle(
                              fontFamily: option.isSelected ? 'Tajawal' : 'Lato',
                              fontWeight: option.isSelected 
                                  ? FontWeight.w700 
                                  : FontWeight.w600,
                              fontSize: 12,
                              color: option.isSelected 
                                  ? const Color(0xFF592E2C) 
                                  : const Color(0xFF727272),
                              letterSpacing: option.isSelected ? -0.04 : 0,
                            ),
                          ),
                          if (option.price != null)
                            Text(
                              '${option.price!.toStringAsFixed(1)} ر.س',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: option.isSelected
                                    ? const Color(0xFF592E2C)
                                    : const Color(0xFF727272),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(width: 4),
                      
                      // Salad icon placeholder
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}
