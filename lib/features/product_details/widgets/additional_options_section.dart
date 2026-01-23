import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/product_details/controllers/product_details_controller.dart';

class AdditionalOptionsSection extends GetView<ProductDetailsController> {
  const AdditionalOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.additionalOptions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            
            const SizedBox(height: 8),
            
            // Options list
            Column(
              children: _buildOptionGroups(),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildOptionGroups() {
    if (controller.additionalOptions.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'no_additional_options'.tr,
            style: AppTheme.bodyStyle.copyWith(
              color: AppColors.textLightColor,
            ),
          ),
        ),
      ];
    }

    // Group options by groupName
    Map<String, List<dynamic>> groupedOptions = {};
    for (var option in controller.additionalOptions) {
      String groupKey = option.groupName ?? 'other';
      if (!groupedOptions.containsKey(groupKey)) {
        groupedOptions[groupKey] = [];
      }
      groupedOptions[groupKey]!.add(option);
    }

    List<Widget> widgets = [];

    // Build each group
    groupedOptions.forEach((groupName, options) {
      if (options.isNotEmpty) {
        bool isRequired = options.first.isRequired;

        widgets.add(_buildOptionsGroup(
          title: groupName,
          options: options,
          isRequired: isRequired,
        ));

        widgets.add(const SizedBox(height: 16));
      }
    });

    // Remove last spacing
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }

    return widgets;
  }

  Widget _buildOptionsGroup({
    required String title,
    required List options,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Row(
          children: [
            Text(
              title,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textDarkColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isRequired ? AppColors.errorColor : AppColors.successColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRequired ? 'required'.tr : 'optional'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Options grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map<Widget>((option) {
            return _buildOptionCard(option, isRequired);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionCard(dynamic option, bool isRequired) {
    final affectsPrice = option.price != null && option.price != 0;
    
    return GestureDetector(
      onTap: () => controller.toggleAdditionalOption(option.id),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: option.isSelected 
              ? AppColors.primaryColor 
              : const Color(0xFFDADADA),
          borderRadius: BorderRadius.circular(30),
          border: isRequired && !option.isSelected
              ? Border.all(color: AppColors.errorColor, width: 1.5)
              : null,
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
            // Option icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: option.isSelected 
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getOptionIcon(option.icon),
                size: 12,
                color: option.isSelected 
                    ? const Color(0xFF592E2C)
                    : Colors.grey[600],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Option details
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Option name
                Text(
                  option.name,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: option.isSelected 
                        ? const Color(0xFF592E2C) 
                        : const Color(0xFF727272),
                  ),
                ),
                
                // Price and indicators
                Row(
                  children: [
                    // Price
                    if (affectsPrice)
                      Text(
                        option.price! > 0 
                            ? '+${option.price!.toStringAsFixed(1)} ${'sar'.tr}'
                            : '${option.price!.toStringAsFixed(1)} ${'sar'.tr}',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: option.isSelected
                              ? const Color(0xFF592E2C)
                              : AppColors.successColor,
                        ),
                      )
                    else
                      Text(
                        'free'.tr,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: option.isSelected
                              ? const Color(0xFF592E2C)
                              : Colors.grey[600],
                        ),
                      ),
                    
                    // Required indicator
                    if (isRequired) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.star,
                        size: 8,
                        color: option.isSelected 
                            ? const Color(0xFF592E2C)
                            : AppColors.errorColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getOptionIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'meat':
        return Icons.restaurant;
      case 'cheese':
        return Icons.cake;
      case 'vegetable':
        return Icons.eco;
      case 'sauce':
        return Icons.water_drop;
      case 'bread':
        return Icons.bakery_dining;
      case 'spice':
        return Icons.grain;
      default:
        return Icons.add_circle_outline;
    }
  }

  Widget _buildSectionHeader() {
    final hasRequiredOptions = controller.additionalOptions
        .any((option) => option.isRequired == true);
    
    final hasSelectedOptions = controller.additionalOptions
        .any((option) => option.isSelected);

    return Row(
      children: [
        Text(
          'additional_options'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF000000),
          ),
        ),
        if (hasRequiredOptions) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.errorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'required'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (hasSelectedOptions)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.successColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${controller.additionalOptions.where((o) => o.isSelected).length} ${'selected'.tr}',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
