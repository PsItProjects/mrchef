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
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionHeader(),
            ),
            const SizedBox(height: 14),
            // Options groups
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: _buildOptionGroups()),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader() {
    final hasRequiredOptions =
        controller.additionalOptions.any((o) => o.isRequired == true);
    final selectedCount =
        controller.additionalOptions.where((o) => o.isSelected).length;

    return Row(
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
          'additional_options'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        if (hasRequiredOptions) ...[
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
        const Spacer(),
        if (selectedCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$selectedCount ${'selected'.tr}',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.successColor,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildOptionGroups() {
    Map<String, List<dynamic>> groupedOptions = {};
    for (var option in controller.additionalOptions) {
      String groupKey = option.groupName ?? 'other';
      if (!groupedOptions.containsKey(groupKey)) {
        groupedOptions[groupKey] = [];
      }
      groupedOptions[groupKey]!.add(option);
    }

    List<Widget> widgets = [];
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
    if (widgets.isNotEmpty) widgets.removeLast();
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
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF4A4A5A),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isRequired
                    ? AppColors.errorColor.withOpacity(0.1)
                    : AppColors.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isRequired ? 'required'.tr : 'optional'.tr,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  color: isRequired ? AppColors.errorColor : AppColors.successColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Options list
        ...options.map<Widget>((option) => _buildOptionTile(option)).toList(),
      ],
    );
  }

  Widget _buildOptionTile(dynamic option) {
    final affectsPrice = option.price != null && option.price != 0;
    final isSelected = option.isSelected;

    return GestureDetector(
      onTap: () => controller.toggleAdditionalOption(option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : const Color(0xFFD0D0D0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.15)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getOptionIcon(option.icon),
                size: 18,
                color: isSelected
                    ? const Color(0xFF1A1A2E)
                    : Colors.grey[500],
              ),
            ),

            const SizedBox(width: 12),

            // Name
            Expanded(
              child: Text(
                option.name,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFF4A4A5A),
                ),
              ),
            ),

            // Price
            if (affectsPrice)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.15)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  option.price! > 0
                      ? '+${option.price!.toStringAsFixed(1)} ${'sar'.tr}'
                      : '${option.price!.toStringAsFixed(1)} ${'sar'.tr}',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFF1A1A2E)
                        : AppColors.successColor,
                  ),
                ),
              )
            else
              Text(
                'free'.tr,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getOptionIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'meat':
        return Icons.restaurant_rounded;
      case 'cheese':
        return Icons.egg_rounded;
      case 'vegetable':
        return Icons.eco_rounded;
      case 'sauce':
        return Icons.water_drop_rounded;
      case 'bread':
        return Icons.bakery_dining_rounded;
      case 'spice':
        return Icons.grain_rounded;
      case 'nuts':
        return Icons.forest_rounded;
      case 'oil':
        return Icons.opacity_rounded;
      default:
        return Icons.add_circle_outline_rounded;
    }
  }
}
