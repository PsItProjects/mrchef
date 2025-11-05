import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/models/merchant_product_model.dart';

/// Modal for adding/editing option groups
class AddOptionGroupModal extends StatefulWidget {
  final ProductOptionGroupInput? existingGroup;
  final int? groupIndex;

  const AddOptionGroupModal({
    super.key,
    this.existingGroup,
    this.groupIndex,
  });

  @override
  State<AddOptionGroupModal> createState() => _AddOptionGroupModalState();
}

class _AddOptionGroupModalState extends State<AddOptionGroupModal> {
  late TextEditingController nameEnController;
  late TextEditingController nameArController;
  late String selectedType;
  late bool isRequired;
  late int minSelections;
  late int maxSelections;
  late List<ProductOptionInput> options;

  final List<String> optionTypes = ['size', 'addon', 'ingredient', 'customization'];

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing data or defaults
    if (widget.existingGroup != null) {
      nameEnController = TextEditingController(text: widget.existingGroup!.nameEn);
      nameArController = TextEditingController(text: widget.existingGroup!.nameAr);
      selectedType = widget.existingGroup!.type;
      isRequired = widget.existingGroup!.isRequired;
      minSelections = widget.existingGroup!.minSelections ?? 0;
      maxSelections = widget.existingGroup!.maxSelections ?? 1;
      options = List.from(widget.existingGroup!.options);
    } else {
      nameEnController = TextEditingController();
      nameArController = TextEditingController();
      selectedType = 'addon';
      isRequired = false;
      minSelections = 0;
      maxSelections = 1;
      options = [];
    }
  }

  @override
  void dispose() {
    nameEnController.dispose();
    nameArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildTypeSelection(),
                  const SizedBox(height: 24),
                  _buildRequirements(),
                  const SizedBox(height: 24),
                  _buildOptionsSection(),
                ],
              ),
            ),
          ),
          
          // Footer Actions
          _buildFooter(),
        ],
      ),
    );
  }

  /// Build header with title and close button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_circle_outline,
            color: AppColors.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.existingGroup != null 
                  ? 'edit_option_group'.tr 
                  : 'add_option_group'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMediumColor),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  /// Build basic information section
  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'group_name'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        
        // English Name
        _buildTextField(
          controller: nameEnController,
          label: 'name_en'.tr,
          hint: 'enter_group_name_en'.tr,
          required: true,
        ),
        const SizedBox(height: 12),
        
        // Arabic Name
        _buildTextField(
          controller: nameArController,
          label: 'name_ar'.tr,
          hint: 'enter_group_name_ar'.tr,
        ),
      ],
    );
  }

  /// Build type selection section
  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'group_type'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: optionTypes.map((type) {
            final isSelected = selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primaryColor 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.primaryColor 
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      size: 18,
                      color: isSelected 
                          ? AppColors.secondaryColor 
                          : AppColors.textMediumColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'option_type_$type'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? AppColors.secondaryColor 
                            : AppColors.textDarkColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build requirements section
  Widget _buildRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Is Required Switch
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'is_required'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkColor,
                  ),
                ),
              ),
              Switch(
                value: isRequired,
                onChanged: (value) {
                  setState(() {
                    isRequired = value;
                    // When required is enabled, set min to 1 if it's 0
                    if (isRequired && minSelections == 0) {
                      minSelections = 1;
                    }
                    // When required is disabled, set min to 0
                    if (!isRequired && minSelections > 0) {
                      minSelections = 0;
                    }
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
          
          if (isRequired) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Min Selections
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'min_selections'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMediumColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildNumberField(
                        value: minSelections,
                        onChanged: (value) => setState(() => minSelections = value),
                        minValue: isRequired ? 1 : 0, // Min is 1 when required, 0 otherwise
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'max_selections'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMediumColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildNumberField(
                        value: maxSelections,
                        onChanged: (value) => setState(() => maxSelections = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build options section
  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'options'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkColor,
              ),
            ),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, size: 18),
              label: Text('add_option'.tr),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (options.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 48,
                    color: AppColors.textMediumColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'no_options_added'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMediumColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...options.asMap().entries.map((entry) {
            return _buildOptionCard(entry.key);
          }).toList(),
      ],
    );
  }

  /// Build single option card
  Widget _buildOptionCard(int index) {
    final option = options[index];
    final nameController = TextEditingController(text: option.nameEn);
    final nameArController = TextEditingController(text: option.nameAr);
    final priceController = TextEditingController(
      text: option.priceModifier != null ? option.priceModifier.toString() : '0',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${'option'.tr} ${index + 1}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _removeOption(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Option Name (English)
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'option_name_en'.tr,
              hintText: 'enter_option_name_en'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
            ),
            onChanged: (value) {
              options[index] = ProductOptionInput(
                nameEn: value,
                nameAr: options[index].nameAr,
                priceModifier: options[index].priceModifier,
                isAvailable: options[index].isAvailable,
                sortOrder: options[index].sortOrder,
              );
            },
          ),
          const SizedBox(height: 8),

          // Option Name (Arabic)
          TextField(
            controller: nameArController,
            decoration: InputDecoration(
              labelText: 'option_name_ar'.tr,
              hintText: 'enter_option_name_ar'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
            ),
            onChanged: (value) {
              options[index] = ProductOptionInput(
                nameEn: options[index].nameEn,
                nameAr: value,
                priceModifier: options[index].priceModifier,
                isAvailable: options[index].isAvailable,
                sortOrder: options[index].sortOrder,
              );
            },
          ),
          const SizedBox(height: 8),

          // Price Modifier
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 18,
                color: AppColors.textMediumColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'price_modifier'.tr,
                    hintText: '0.00',
                    helperText: 'price_modifier_hint'.tr,
                    helperMaxLines: 2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    final price = double.tryParse(value);
                    options[index] = ProductOptionInput(
                      nameEn: options[index].nameEn,
                      nameAr: options[index].nameAr,
                      priceModifier: price,
                      isAvailable: options[index].isAvailable,
                      sortOrder: options[index].sortOrder,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build footer with action buttons
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'cancel'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saveOptionGroup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'save'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkColor,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  /// Build number field
  Widget _buildNumberField({
    required int value,
    required ValueChanged<int> onChanged,
    int minValue = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: value > minValue ? () => onChanged(value - 1) : null,
            padding: EdgeInsets.zero,
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => onChanged(value + 1),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// Get icon for option type
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'size':
        return Icons.straighten;
      case 'addon':
        return Icons.add_circle_outline;
      case 'ingredient':
        return Icons.restaurant;
      case 'customization':
        return Icons.tune;
      default:
        return Icons.category;
    }
  }

  /// Add new option
  void _addOption() {
    setState(() {
      options.add(ProductOptionInput(
        nameEn: '',
        nameAr: '',
        priceModifier: 0.0,
        isAvailable: true,
        sortOrder: options.length,
      ));
    });
  }

  /// Remove option
  void _removeOption(int index) {
    setState(() {
      options.removeAt(index);
    });
  }

  /// Save option group
  void _saveOptionGroup() {
    // Validate
    if (nameEnController.text.trim().isEmpty) {
      Get.snackbar(
        'error'.tr,
        'group_name_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (options.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'at_least_one_option_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if all options have names
    for (var i = 0; i < options.length; i++) {
      if (options[i].nameEn.trim().isEmpty) {
        Get.snackbar(
          'error'.tr,
          '${'option'.tr} ${i + 1}: ${'option_name_required'.tr}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Validate min/max selections
    if (isRequired) {
      if (minSelections < 1) {
        Get.snackbar(
          'error'.tr,
          'min_selections_required_error'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (maxSelections > 0 && maxSelections < minSelections) {
        Get.snackbar(
          'error'.tr,
          'max_selections_min_error'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (maxSelections > options.length) {
        Get.snackbar(
          'error'.tr,
          'max_selections_exceed_error'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Create option group
    final optionGroup = ProductOptionGroupInput(
      nameEn: nameEnController.text.trim(),
      nameAr: nameArController.text.trim().isEmpty
          ? nameEnController.text.trim()
          : nameArController.text.trim(),
      type: selectedType,
      isRequired: isRequired,
      minSelections: isRequired ? minSelections : null,
      maxSelections: isRequired ? maxSelections : null,
      sortOrder: widget.groupIndex ?? 0,
      options: options,
    );

    // Return result
    Get.back(result: optionGroup);
  }
}
