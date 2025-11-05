import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/controllers/add_product_controller.dart';

class AddProductScreen extends GetView<AddProductController> {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'add_product'.tr,
          style: TextStyle(color: AppColors.textDarkColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDarkColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: controller.createProduct,
                  child: Text(
                    'save'.tr,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )),
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagesSection(),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildPricingSection(),
                  const SizedBox(height: 24),
                  _buildCategorySection(),
                  const SizedBox(height: 24),
                  _buildDetailsSection(),
                  const SizedBox(height: 24),
                  _buildFlagsSection(),
                  const SizedBox(height: 24),
                  _buildOptionGroupsSection(),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            )),
    );
  }

  /// Images Section
  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.image_outlined,
                color: AppColors.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'product_images'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
              const Spacer(),
              // Info Icon for Image Requirements
              GestureDetector(
                onTap: _showImageRequirements,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'product_images_hint'.tr,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMediumColor,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add Image Button
                    if (controller.selectedImages.length < 10)
                      _buildAddImageButton(),
                    // Selected Images
                    ...controller.selectedImages.asMap().entries.map((entry) {
                      return _buildImageItem(entry.value, entry.key);
                    }),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Show Image Requirements Dialog
  void _showImageRequirements() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'image_requirements'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'image_requirements_details'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textDarkColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'got_it'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: controller.pickImages,
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 40,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              'add_image'.tr,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(File image, int index) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Primary Badge (for first image)
          if (index == 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'primary'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Set as Primary Button (for non-primary images)
          if (index != 0)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => controller.setAsPrimaryImage(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'set_primary'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Remove Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Basic Info Section
  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      icon: Icons.info_outline,
      title: 'basic_information'.tr,
      child: Column(
        children: [
          _buildTextField(
            textController: controller.nameEnController,
            label: 'product_name_en'.tr,
            hint: 'enter_product_name_en'.tr,
            required: true,
            errorKey: 'name_en',
            fieldKey: controller.nameEnKey,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            textController: controller.nameArController,
            label: 'product_name_ar'.tr,
            hint: 'enter_product_name_ar'.tr,
            errorKey: 'name_ar',
            fieldKey: controller.nameArKey,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            textController: controller.descriptionEnController,
            label: 'description_en'.tr,
            hint: 'enter_description_en'.tr,
            maxLines: 4,
            errorKey: 'description_en',
            fieldKey: controller.descriptionEnKey,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            textController: controller.descriptionArController,
            label: 'description_ar'.tr,
            hint: 'enter_description_ar'.tr,
            maxLines: 4,
            errorKey: 'description_ar',
            fieldKey: controller.descriptionArKey,
          ),
        ],
      ),
    );
  }

  /// Pricing Section
  Widget _buildPricingSection() {
    return _buildSectionCard(
      icon: Icons.attach_money,
      title: 'pricing'.tr,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  textController: controller.basePriceController,
                  label: 'base_price'.tr,
                  hint: '0.00',
                  required: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  prefixIcon: Icon(Icons.monetization_on_outlined, color: AppColors.primaryColor),
                  errorKey: 'price',
                  fieldKey: controller.priceKey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  textController: controller.discountPercentageController,
                  label: 'discount_percentage'.tr,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  prefixIcon: Icon(Icons.percent, color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            textController: controller.preparationTimeController,
            label: 'preparation_time'.tr,
            hint: 'preparation_time_hint'.tr,
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            prefixIcon: Icon(Icons.timer_outlined, color: AppColors.primaryColor),
            errorKey: 'preparation_time',
            fieldKey: controller.preparationTimeKey,
          ),
        ],
      ),
    );
  }

  /// Category Section
  Widget _buildCategorySection() {
    return _buildSectionCard(
      icon: Icons.category_outlined,
      title: 'category'.tr,
      child: Obx(() => DropdownButtonFormField<int>(
            value: controller.selectedCategoryId.value,
            decoration: InputDecoration(
              hintText: 'select_category'.tr,
              prefixIcon: Icon(Icons.restaurant_menu, color: AppColors.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: controller.categories.map((category) {
              return DropdownMenuItem<int>(
                value: category.id,
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textDarkColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedCategoryId.value = value;
            },
          )),
    );
  }

  /// Details Section
  Widget _buildDetailsSection() {
    return _buildSectionCard(
      icon: Icons.description_outlined,
      title: 'additional_details'.tr,
      child: Column(
        children: [
          _buildTextField(
            textController: controller.caloriesController,
            label: 'calories'.tr,
            hint: 'enter_calories'.tr,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icon(Icons.local_fire_department, color: AppColors.primaryColor),
            errorKey: 'calories',
            fieldKey: controller.caloriesKey,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            textController: controller.ingredientsController,
            label: 'ingredients'.tr,
            hint: 'ingredients_hint'.tr,
            maxLines: 3,
            prefixIcon: Icon(Icons.list_alt, color: AppColors.primaryColor),
            errorKey: 'ingredients_en',
            fieldKey: controller.ingredientsKey,
          ),
        ],
      ),
    );
  }

  /// Flags Section
  Widget _buildFlagsSection() {
    return _buildSectionCard(
      icon: Icons.toggle_on_outlined,
      title: 'product_properties'.tr,
      child: Column(
        children: [
          Obx(() => _buildSwitchTile(
                title: 'is_available'.tr,
                subtitle: 'is_available_hint'.tr,
                value: controller.isAvailable.value,
                onChanged: (value) => controller.isAvailable.value = value,
                icon: Icons.check_circle_outline,
              )),
          Obx(() => _buildSwitchTile(
                title: 'is_featured'.tr,
                subtitle: 'is_featured_hint'.tr,
                value: controller.isFeatured.value,
                onChanged: (value) => controller.isFeatured.value = value,
                icon: Icons.star_outline,
              )),
          Obx(() => _buildSwitchTile(
                title: 'is_vegetarian'.tr,
                value: controller.isVegetarian.value,
                onChanged: (value) => controller.isVegetarian.value = value,
                icon: Icons.eco_outlined,
              )),
          Obx(() => _buildSwitchTile(
                title: 'is_vegan'.tr,
                value: controller.isVegan.value,
                onChanged: (value) => controller.isVegan.value = value,
                icon: Icons.spa_outlined,
              )),
          Obx(() => _buildSwitchTile(
                title: 'is_gluten_free'.tr,
                value: controller.isGlutenFree.value,
                onChanged: (value) => controller.isGlutenFree.value = value,
                icon: Icons.grain_outlined,
              )),
          Obx(() => _buildSwitchTile(
                title: 'is_spicy'.tr,
                value: controller.isSpicy.value,
                onChanged: (value) => controller.isSpicy.value = value,
                icon: Icons.local_fire_department_outlined,
              )),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? AppColors.primaryColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primaryColor.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: icon != null
            ? Icon(
                icon,
                color: value ? AppColors.primaryColor : Colors.grey[400],
                size: 24,
              )
            : null,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: value ? AppColors.textDarkColor : AppColors.textMediumColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMediumColor,
                ),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
      ),
    );
  }

  /// Build Section Card (Reusable)
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Option Groups Section
  Widget _buildOptionGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'option_groups'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkColor,
              ),
            ),
            TextButton.icon(
              onPressed: controller.addOptionGroup,
              icon: Icon(Icons.add, color: AppColors.primaryColor),
              label: Text(
                'add_option_group'.tr,
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => controller.optionGroups.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 64,
                        color: AppColors.textMediumColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_option_groups'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textMediumColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: controller.optionGroups.asMap().entries.map((entry) {
                  return _buildOptionGroupCard(entry.key);
                }).toList(),
              )),
      ],
    );
  }

  Widget _buildOptionGroupCard(int groupIndex) {
    final group = controller.optionGroups[groupIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      _getGroupTypeIcon(group.type),
                      color: AppColors.secondaryColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.nameEn.isEmpty ? '${'option_group'.tr} ${groupIndex + 1}' : group.nameEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkColor,
                        ),
                      ),
                      if (group.nameAr.isNotEmpty)
                        Text(
                          group.nameAr,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMediumColor,
                          ),
                        ),
                    ],
                  ),
                ),
                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primaryColor, size: 20),
                  onPressed: () => controller.editOptionGroup(groupIndex),
                  tooltip: 'edit'.tr,
                ),
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => controller.removeOptionGroup(groupIndex),
                  tooltip: 'delete'.tr,
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type and Required badges
                Row(
                  children: [
                    _buildBadge(
                      'option_type_${group.type}'.tr,
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    if (group.isRequired)
                      _buildBadge(
                        'required'.tr,
                        Colors.red.withOpacity(0.1),
                        Colors.red,
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Options count
                Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 16,
                      color: AppColors.textMediumColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${group.options.length} ${'options'.tr}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMediumColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (group.options.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Options list (show first 3)
                  ...group.options.take(3).map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option.nameEn,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textDarkColor,
                              ),
                            ),
                          ),
                          if (option.priceModifier != null && option.priceModifier != 0)
                            Text(
                              '${option.priceModifier! > 0 ? '+' : ''}${option.priceModifier!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: option.priceModifier! > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),

                  if (group.options.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${group.options.length - 3} ${'more'.tr}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMediumColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get icon for group type
  IconData _getGroupTypeIcon(String type) {
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

  /// Build badge widget
  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Text Field Builder with validation error support
  Widget _buildTextField({
    required TextEditingController textController,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    String? errorKey, // Key to lookup error in controller.validationErrors
    GlobalKey? fieldKey, // Key for scrolling to this field
  }) {
    // Use GetBuilder instead of Obx for better compatibility with RxMap
    return GetBuilder<AddProductController>(
      id: errorKey, // Use errorKey as unique ID for targeted updates
      builder: (ctrl) {
        // Get error message from controller if errorKey is provided
        final errorText = errorKey != null ? ctrl.validationErrors[errorKey] : null;
        final hasError = errorText != null && errorText.isNotEmpty;

      return Container(
        key: fieldKey,
        margin: const EdgeInsets.only(bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    text: label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasError ? AppColors.errorColor : AppColors.textDarkColor,
                    ),
                    children: [
                      if (required)
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: AppColors.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            TextFormField(
              controller: textController,
              maxLines: maxLines,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: (value) {
                // Clear error when user starts typing
                if (errorKey != null && hasError) {
                  controller.clearFieldError(errorKey);
                }
              },
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textDarkColor,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.hintTextColor,
                  fontSize: 14,
                ),
                prefixIcon: prefixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.errorColor : Colors.grey[300]!,
                    width: hasError ? 2 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.errorColor : Colors.grey[300]!,
                    width: hasError ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.errorColor : AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.errorColor, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.errorColor, width: 2),
                ),
                filled: true,
                fillColor: hasError ? AppColors.errorColor.withOpacity(0.05) : Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),

            // Error Message Display
            if (hasError) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.errorColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorText,
                      style: TextStyle(
                        color: AppColors.errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

