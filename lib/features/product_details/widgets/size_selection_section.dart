import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class SizeSelectionSection extends GetView<ProductDetailsController> {
  const SizeSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (kDebugMode) {
        print('🔍 SIZE SELECTION WIDGET: Building...');
        print('🔍 RAW SIZES COUNT: ${controller.product.value?.rawSizes.length ?? 0}');
        print('🔍 RAW SIZES DATA: ${controller.product.value?.rawSizes}');
      }

      if (controller.product.value?.rawSizes.isEmpty ?? true) {
        if (kDebugMode) {
          print('🔍 SIZE SELECTION WIDGET: No sizes available, hiding widget');
        }
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Text(
              'size_selection'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF000000),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Size options
            Row(
              children: [
                // Size circles (left side)
                Column(
                  children: controller.product.value!.rawSizes.map((sizeObj) {
                    final sizeName = _getSizeName(sizeObj);
                    final isSelected = controller.selectedSize.value == sizeName;
                    final sizeData = _getSizeData(sizeObj);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => controller.selectSize(sizeName),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : const Color(0xFFE5E5E5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              sizeData['letter'],
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isSelected
                                    ? const Color(0xFF592E2C)
                                    : const Color(0xFF999999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(width: 16),
                
                // Size details (right side)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: controller.product.value!.sizes.map((sizeObj) {
                      final sizeName = _getSizeName(sizeObj);
                      final isSelected = controller.selectedSize.value == sizeName;
                      final sizeData = _getSizeData(sizeObj);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sizeData['name'],
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : const Color(0xFF262626),
                                  ),
                                ),
                                if (sizeData['description'].isNotEmpty)
                                  Text(
                                    sizeData['description'],
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: isSelected
                                          ? AppColors.primaryColor.withOpacity(0.7)
                                          : const Color(0xFF666666),
                                    ),
                                  ),
                              ],
                            ),
                            if (sizeData['priceModifier'] != 0)
                              Text(
                                sizeData['priceModifier'] > 0
                                    ? '+${sizeData['priceModifier'].toStringAsFixed(1)} ${'sar'.tr}'
                                    : '${sizeData['priceModifier'].toStringAsFixed(1)} ${'sar'.tr}',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.successColor,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Extract size name from size object or string
  String _getSizeName(dynamic sizeObj) {
    if (sizeObj is Map) {
      var nameField = sizeObj['name'];
      if (nameField is Map) {
        // Handle translatable name: {en: "Regular", ar: "عادي", current: "عادي"}
        return nameField['current'] ?? nameField['ar'] ?? nameField['en'] ?? '';
      }
      return nameField?.toString() ?? '';
    }
    return sizeObj.toString();
  }

  /// Get size data for display
  Map<String, dynamic> _getSizeData(dynamic sizeObj) {
    String sizeName;
    double priceModifier = 0.0;

    if (sizeObj is Map) {
      var nameField = sizeObj['name'];
      if (nameField is Map) {
        // Handle translatable name: {en: "Regular", ar: "عادي", current: "عادي"}
        sizeName = nameField['current'] ?? nameField['ar'] ?? nameField['en'] ?? '';
      } else {
        sizeName = nameField?.toString() ?? '';
      }
      priceModifier = (sizeObj['price_modifier'] ?? 0).toDouble();
    } else {
      sizeName = sizeObj.toString();
    }

    // Debug: Print the actual size name and its characters
    if (kDebugMode) {
      print('🔍 SIZE DEBUG: "$sizeName"');
      print('🔍 SIZE LENGTH: ${sizeName.length}');
      if (sizeName.isNotEmpty) {
        print('🔍 FIRST CHAR: "${sizeName[0]}" (code: ${sizeName.codeUnitAt(0)})');
        print('🔍 ALL CHARS: ${sizeName.split('').map((c) => '"$c" (${c.codeUnitAt(0)})').join(', ')}');
      }
    }

    // Generate display data based on size name
    switch (sizeName.toLowerCase()) {
      case 'صغير':
      case 'small':
      case 's':
        return {
          'letter': 'S',
          'name': sizeName,
          'description': 'perfect_for_one'.tr,
          'priceModifier': priceModifier,
        };
      case 'متوسط':
      case 'وسط':
      case 'medium':
      case 'm':
        return {
          'letter': 'M',
          'name': sizeName,
          'description': 'good_for_sharing'.tr,
          'priceModifier': priceModifier,
        };
      case 'كبير':
      case 'large':
      case 'l':
        return {
          'letter': 'L',
          'name': sizeName,
          'description': 'family_size'.tr,
          'priceModifier': priceModifier,
        };
      case 'عائلي':
      case 'extra_large':
      case 'xl':
        return {
          'letter': 'XL',
          'name': sizeName,
          'description': 'party_size'.tr,
          'priceModifier': priceModifier,
        };
      case '3 قطع':
      case '3 pieces':
        return {
          'letter': '3',
          'name': sizeName,
          'description': 'three_pieces'.tr,
          'priceModifier': priceModifier,
        };
      case '5 قطع':
      case '5 pieces':
        return {
          'letter': '5',
          'name': sizeName,
          'description': 'five_pieces'.tr,
          'priceModifier': priceModifier,
        };
      case '4 قطع':
      case '4 pieces':
        return {
          'letter': '4',
          'name': sizeName,
          'description': 'four_pieces'.tr,
          'priceModifier': priceModifier,
        };
      case '6 قطع':
      case '6 pieces':
        return {
          'letter': '6',
          'name': sizeName,
          'description': 'six_pieces'.tr,
          'priceModifier': priceModifier,
        };
      case '8 قطع':
      case '8 pieces':
        return {
          'letter': '8',
          'name': sizeName,
          'description': 'eight_pieces'.tr,
          'priceModifier': priceModifier,
        };
      case 'عادي':
      case 'regular':
        return {
          'letter': 'R',
          'name': sizeName,
          'description': 'regular_size'.tr,
          'priceModifier': priceModifier,
        };
      case '200 جرام':
      case '200g':
        return {
          'letter': '200',
          'name': sizeName,
          'description': 'grams_200'.tr,
          'priceModifier': priceModifier,
        };
      case '300 جرام':
      case '300g':
        return {
          'letter': '300',
          'name': sizeName,
          'description': 'grams_300'.tr,
          'priceModifier': priceModifier,
        };
      default:
        // Handle common Arabic size names that might not be in the switch
        String letter = '?';
        String description = '';

        if (sizeName.isNotEmpty) {
          // Clean the size name
          String cleanName = sizeName.trim();

          // Handle specific Arabic sizes
          if (cleanName.contains('عادي') || cleanName.toLowerCase().contains('regular')) {
            letter = 'R';
            description = 'regular_size'.tr;
          } else if (cleanName.contains('كبير') || cleanName.toLowerCase().contains('large')) {
            letter = 'L';
            description = 'large_size'.tr;
          } else if (cleanName.contains('صغير') || cleanName.toLowerCase().contains('small')) {
            letter = 'S';
            description = 'small_size'.tr;
          } else if (cleanName.contains('وسط') || cleanName.toLowerCase().contains('medium')) {
            letter = 'M';
            description = 'medium_size'.tr;
          } else {
            // Try to extract number first
            RegExp numberRegex = RegExp(r'\d+');
            Match? numberMatch = numberRegex.firstMatch(cleanName);
            if (numberMatch != null) {
              letter = numberMatch.group(0)!;
            } else {
              // Fall back to first character (but clean it first)
              String firstChar = cleanName.substring(0, 1);
              // Check if it's a valid character (not a special character)
              if (firstChar.codeUnitAt(0) >= 32 && firstChar.codeUnitAt(0) <= 126) {
                letter = firstChar.toUpperCase();
              } else if (firstChar.codeUnitAt(0) >= 1536 && firstChar.codeUnitAt(0) <= 1791) {
                // Arabic character range
                letter = firstChar;
              } else {
                letter = '?';
              }
            }
          }
        }

        return {
          'letter': letter,
          'name': sizeName,
          'description': description,
          'priceModifier': priceModifier,
        };
    }
  }
}
