import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class SizeSelectionSection extends GetView<ProductDetailsController> {
  const SizeSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.product.value?.rawSizes.isEmpty ?? true) {
        return const SizedBox.shrink();
      }

      // Read reactive values at top of Obx so they are tracked for rebuild
      final currentSelectedSize = controller.selectedSize.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'size_selection'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'required'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: AppColors.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Horizontal scrollable size chips
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.product.value!.rawSizes.length,
                itemBuilder: (context, index) {
                  final sizeObj = controller.product.value!.rawSizes[index];
                  final sizeName = _getSizeName(sizeObj);
                  final sizeData = _getSizeData(sizeObj);
                  final isSelected = currentSelectedSize == sizeName;

                  return GestureDetector(
                    onTap: () => controller.selectSize(sizeName),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: EdgeInsetsDirectional.only(
                        end: index < controller.product.value!.rawSizes.length - 1 ? 10 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : const Color(0xFFE8E8E8),
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sizeData['name'] ?? sizeName,
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isSelected
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF4A4A5A),
                            ),
                          ),
                          if (sizeData['priceModifier'] != null && sizeData['priceModifier'] != 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              sizeData['priceModifier'] > 0
                                  ? '+${sizeData['priceModifier'].toStringAsFixed(1)} ${'sar'.tr}'
                                  : '${sizeData['priceModifier'].toStringAsFixed(1)} ${'sar'.tr}',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: isSelected
                                    ? const Color(0xFF1A1A2E).withOpacity(0.7)
                                    : AppColors.successColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getSizeName(dynamic sizeObj) {
    if (sizeObj is Map) {
      var nameField = sizeObj['name'];
      if (nameField is Map) {
        return nameField['current'] ?? nameField['ar'] ?? nameField['en'] ?? '';
      }
      return nameField?.toString() ?? '';
    }
    return sizeObj.toString();
  }

  Map<String, dynamic> _getSizeData(dynamic sizeObj) {
    String sizeName;
    double priceModifier = 0.0;

    if (sizeObj is Map) {
      var nameField = sizeObj['name'];
      if (nameField is Map) {
        sizeName = nameField['current'] ?? nameField['ar'] ?? nameField['en'] ?? '';
      } else {
        sizeName = nameField?.toString() ?? '';
      }
      priceModifier = (sizeObj['price_modifier'] ?? 0).toDouble();
    } else {
      sizeName = sizeObj.toString();
    }

    return {
      'name': sizeName,
      'priceModifier': priceModifier,
    };
  }
}
