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
      backgroundColor: AppColors.surfaceColor,
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                _buildSliverAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildImagesSection(),
                      const SizedBox(height: 16),
                      _buildBasicInfoSection(),
                      const SizedBox(height: 16),
                      _buildPricingSection(),
                      const SizedBox(height: 16),
                      _buildCategorySection(),
                      const SizedBox(height: 16),
                      _buildDetailsSection(),
                      const SizedBox(height: 16),
                      _buildFlagsSection(),
                      const SizedBox(height: 16),
                      _buildOptionGroupsSection(),
                    ]),
                  ),
                ),
              ],
            )),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── SLIVER APP BAR ────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: AppColors.secondaryColor, size: 18),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'add_product'.tr,
        style: const TextStyle(
          color: AppColors.textDarkColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Lato',
        ),
      ),
      centerTitle: true,
    );
  }

  // ─── BOTTOM BAR ────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.createProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.secondaryColor,
                disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.secondaryColor),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'save'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Lato'),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }

  // ─── IMAGES SECTION ────────────────────────────────────────
  Widget _buildImagesSection() {
    return _SectionCard(
      icon: Icons.camera_alt_rounded,
      title: 'product_images'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'product_images_hint'.tr,
            style: TextStyle(fontSize: 12, color: AppColors.textMediumColor, height: 1.4),
          ),
          const SizedBox(height: 12),
          Obx(() => SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (controller.selectedImages.length < 10) _buildAddImageBtn(),
                    ...controller.selectedImages.asMap().entries.map((e) => _buildImageThumb(e.value, e.key)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAddImageBtn() {
    return GestureDetector(
      onTap: controller.pickImages,
      child: Container(
        width: 110,
        height: 110,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded, size: 32, color: AppColors.primaryColor),
            const SizedBox(height: 6),
            Text('add_image'.tr,
                style: TextStyle(color: AppColors.primaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumb(File image, int index) {
    return Container(
      width: 110,
      height: 110,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Stack(
        children: [
          if (index == 0)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.85)]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('primary'.tr,
                    style: const TextStyle(color: AppColors.secondaryColor, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ),
          if (index != 0)
            Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => controller.setAsPrimaryImage(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.primaryColor, size: 12),
                      const SizedBox(width: 3),
                      Text('set_primary'.tr,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BASIC INFO SECTION ────────────────────────────────────
  Widget _buildBasicInfoSection() {
    return _SectionCard(
      icon: Icons.edit_note_rounded,
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
          const SizedBox(height: 14),
          _buildTextField(
            textController: controller.nameArController,
            label: 'product_name_ar'.tr,
            hint: 'enter_product_name_ar'.tr,
            errorKey: 'name_ar',
            fieldKey: controller.nameArKey,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            textController: controller.descriptionEnController,
            label: 'description_en'.tr,
            hint: 'enter_description_en'.tr,
            maxLines: 3,
            errorKey: 'description_en',
            fieldKey: controller.descriptionEnKey,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            textController: controller.descriptionArController,
            label: 'description_ar'.tr,
            hint: 'enter_description_ar'.tr,
            maxLines: 3,
            errorKey: 'description_ar',
            fieldKey: controller.descriptionArKey,
          ),
        ],
      ),
    );
  }

  // ─── PRICING SECTION ──────────────────────────────────────
  Widget _buildPricingSection() {
    return _SectionCard(
      icon: Icons.monetization_on_rounded,
      title: 'pricing'.tr,
      child: Column(
        children: [
          _buildTextField(
            textController: controller.basePriceController,
            label: 'base_price'.tr,
            hint: '0.00',
            required: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            prefixIcon: Icon(Icons.payments_rounded, color: AppColors.primaryColor, size: 20),
            suffixText: 'SAR',
            errorKey: 'price',
            fieldKey: controller.priceKey,
          ),
          const SizedBox(height: 16),

          // Discount Type Toggle — NO outer Obx (each chip has its own)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildDiscountTypeChip('percentage', 'discount_percentage'.tr, Icons.percent_rounded),
                const SizedBox(width: 4),
                _buildDiscountTypeChip('fixed', 'fixed_price'.tr, Icons.price_check_rounded),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Discount Input
          Obx(() => controller.discountType.value == 'percentage'
              ? _buildTextField(
                  textController: controller.discountPercentageController,
                  label: 'discount_percentage'.tr,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icon(Icons.percent_rounded, color: AppColors.primaryColor, size: 20),
                  suffixText: '%',
                )
              : _buildTextField(
                  textController: controller.discountFixedPriceController,
                  label: 'discount_fixed_price'.tr,
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  prefixIcon: Icon(Icons.sell_rounded, color: AppColors.primaryColor, size: 20),
                  suffixText: 'SAR',
                )),
          const SizedBox(height: 14),

          // Auto-calculated Final Price Preview
          Obx(() {
            final basePrice = double.tryParse(controller.basePriceController.text.trim()) ?? 0;
            final finalPrice = controller.calculatedFinalPrice.value;
            final hasDiscount = finalPrice > 0 && finalPrice < basePrice;

            if (basePrice <= 0) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: hasDiscount
                    ? LinearGradient(colors: [Colors.green.shade50, Colors.green.shade50.withOpacity(0.5)])
                    : LinearGradient(colors: [AppColors.surfaceColor, AppColors.surfaceColor.withOpacity(0.5)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: hasDiscount ? Colors.green.shade200 : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasDiscount ? Colors.green.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      hasDiscount ? Icons.savings_rounded : Icons.receipt_long_rounded,
                      color: hasDiscount ? Colors.green.shade700 : Colors.grey.shade600,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('final_price'.tr,
                            style: TextStyle(fontSize: 12, color: AppColors.textMediumColor, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (hasDiscount)
                              Text(
                                '${basePrice.toStringAsFixed(2)} SAR',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.red.shade300,
                                ),
                              ),
                            if (hasDiscount) const SizedBox(width: 8),
                            Text(
                              '${finalPrice.toStringAsFixed(2)} SAR',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: hasDiscount ? Colors.green.shade700 : AppColors.textDarkColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasDiscount)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${((1 - finalPrice / basePrice) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.red.shade600),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          _buildTextField(
            textController: controller.preparationTimeController,
            label: 'preparation_time'.tr,
            hint: 'preparation_time_hint'.tr,
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icon(Icons.timer_rounded, color: AppColors.primaryColor, size: 20),
            suffixText: 'min',
            errorKey: 'preparation_time',
            fieldKey: controller.preparationTimeKey,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountTypeChip(String type, String label, IconData icon) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.discountType.value == type;
        return GestureDetector(
          onTap: () => controller.discountType.value = type,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.secondaryColor.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: isSelected ? AppColors.primaryColor : AppColors.textMediumColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryColor : AppColors.textMediumColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── CATEGORY SECTION ─────────────────────────────────────
  Widget _buildCategorySection() {
    return _SectionCard(
      icon: Icons.category_rounded,
      title: 'category'.tr,
      child: Obx(() => DropdownButtonFormField<int>(
            value: controller.selectedCategoryId.value,
            decoration: InputDecoration(
              hintText: 'select_category'.tr,
              hintStyle: TextStyle(color: AppColors.hintTextColor, fontSize: 14),
              prefixIcon: Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryColor, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5)),
              filled: true,
              fillColor: AppColors.surfaceColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: controller.categories.map((cat) {
              return DropdownMenuItem<int>(
                value: cat.id,
                child: Text(cat.name, style: const TextStyle(fontSize: 14, color: AppColors.textDarkColor)),
              );
            }).toList(),
            onChanged: (v) => controller.selectedCategoryId.value = v,
          )),
    );
  }

  // ─── DETAILS SECTION ──────────────────────────────────────
  Widget _buildDetailsSection() {
    return _SectionCard(
      icon: Icons.science_rounded,
      title: 'additional_details'.tr,
      child: Column(
        children: [
          _buildTextField(
            textController: controller.caloriesController,
            label: 'calories'.tr,
            hint: 'enter_calories'.tr,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icon(Icons.local_fire_department_rounded, color: AppColors.primaryColor, size: 20),
            suffixText: 'kcal',
            errorKey: 'calories',
            fieldKey: controller.caloriesKey,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            textController: controller.ingredientsController,
            label: 'ingredients'.tr,
            hint: 'ingredients_hint'.tr,
            maxLines: 3,
            prefixIcon: Icon(Icons.list_alt_rounded, color: AppColors.primaryColor, size: 20),
            errorKey: 'ingredients_en',
            fieldKey: controller.ingredientsKey,
          ),
        ],
      ),
    );
  }

  // ─── FLAGS SECTION ────────────────────────────────────────
  Widget _buildFlagsSection() {
    return _SectionCard(
      icon: Icons.tune_rounded,
      title: 'product_properties'.tr,
      child: Column(
        children: [
          Obx(() => _FlagTile(
                icon: Icons.check_circle_outline_rounded,
                title: 'is_available'.tr,
                subtitle: 'is_available_hint'.tr,
                value: controller.isAvailable.value,
                onChanged: (v) => controller.isAvailable.value = v,
                activeColor: Colors.green,
              )),
          Obx(() => _FlagTile(
                icon: Icons.star_outline_rounded,
                title: 'is_featured'.tr,
                subtitle: 'is_featured_hint'.tr,
                value: controller.isFeatured.value,
                onChanged: (v) => controller.isFeatured.value = v,
                activeColor: Colors.amber.shade700,
              )),
          Obx(() => _FlagTile(
                icon: Icons.eco_rounded,
                title: 'is_vegetarian'.tr,
                value: controller.isVegetarian.value,
                onChanged: (v) => controller.isVegetarian.value = v,
                activeColor: Colors.green.shade600,
              )),
          Obx(() => _FlagTile(
                icon: Icons.spa_rounded,
                title: 'is_vegan'.tr,
                value: controller.isVegan.value,
                onChanged: (v) => controller.isVegan.value = v,
                activeColor: Colors.teal,
              )),
          Obx(() => _FlagTile(
                icon: Icons.grain_rounded,
                title: 'is_gluten_free'.tr,
                value: controller.isGlutenFree.value,
                onChanged: (v) => controller.isGlutenFree.value = v,
                activeColor: Colors.brown,
              )),
          Obx(() => _FlagTile(
                icon: Icons.local_fire_department_rounded,
                title: 'is_spicy'.tr,
                value: controller.isSpicy.value,
                onChanged: (v) => controller.isSpicy.value = v,
                activeColor: Colors.red,
              )),
        ],
      ),
    );
  }

  // ─── OPTION GROUPS SECTION ────────────────────────────────
  Widget _buildOptionGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.dashboard_customize_rounded, color: AppColors.secondaryColor, size: 22),
              const SizedBox(width: 8),
              Text('option_groups'.tr,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDarkColor)),
              const Spacer(),
              TextButton.icon(
                onPressed: controller.addOptionGroup,
                icon: Icon(Icons.add_circle_rounded, color: AppColors.primaryColor, size: 20),
                label: Text('add_option_group'.tr,
                    style: TextStyle(color: AppColors.secondaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
                children: controller.optionGroups.asMap().entries.map((e) => _buildOptionGroupCard(e.key)).toList(),
              )),
      ],
    );
  }

  Widget _buildOptionGroupCard(int idx) {
    final group = controller.optionGroups[idx];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(10)),
                  child: Icon(_getGroupTypeIcon(group.type), color: AppColors.secondaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.nameEn.isEmpty ? '${'option_group'.tr} ${idx + 1}' : group.nameEn,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDarkColor),
                      ),
                      if (group.nameAr.isNotEmpty)
                        Text(group.nameAr, style: TextStyle(fontSize: 12, color: AppColors.textMediumColor)),
                    ],
                  ),
                ),
                _miniIconBtn(Icons.edit_rounded, AppColors.secondaryColor, () => controller.editOptionGroup(idx)),
                const SizedBox(width: 4),
                _miniIconBtn(Icons.delete_rounded, Colors.red, () => controller.removeOptionGroup(idx)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    _badge('option_type_${group.type}'.tr, AppColors.secondaryColor.withOpacity(0.08), AppColors.secondaryColor),
                    if (group.isRequired) _badge('required'.tr, Colors.red.withOpacity(0.08), Colors.red),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.list_alt_rounded, size: 15, color: AppColors.textMediumColor),
                    const SizedBox(width: 4),
                    Text('${group.options.length} ${'options'.tr}',
                        style: TextStyle(fontSize: 13, color: AppColors.textMediumColor, fontWeight: FontWeight.w500)),
                  ],
                ),
                if (group.options.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 10),
                  ...group.options.take(3).map((opt) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(width: 5, height: 5, decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(opt.nameEn, style: const TextStyle(fontSize: 13, color: AppColors.textDarkColor))),
                            if (opt.priceModifier != null && opt.priceModifier != 0)
                              Text(
                                '${opt.priceModifier! > 0 ? '+' : ''}${opt.priceModifier!.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                    color: opt.priceModifier! > 0 ? Colors.green : Colors.red),
                              ),
                          ],
                        ),
                      )),
                  if (group.options.length > 3)
                    Text('+${group.options.length - 3} ${'more'.tr}',
                        style: TextStyle(fontSize: 11, color: AppColors.textMediumColor, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SHARED BUILDERS ──────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController textController,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    String? suffixText,
    String? errorKey,
    GlobalKey? fieldKey,
  }) {
    return GetBuilder<AddProductController>(
      id: errorKey,
      builder: (ctrl) {
        final errorText = errorKey != null ? ctrl.validationErrors[errorKey] : null;
        final hasError = errorText != null && errorText.isNotEmpty;

        return Container(
          key: fieldKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: RichText(
                    text: TextSpan(
                      text: label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasError ? AppColors.errorColor : AppColors.textDarkColor,
                        fontFamily: 'Lato',
                      ),
                      children: [
                        if (required)
                          TextSpan(text: ' *', style: TextStyle(color: AppColors.errorColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              TextFormField(
                controller: textController,
                maxLines: maxLines,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                onChanged: (v) {
                  if (errorKey != null && hasError) controller.clearFieldError(errorKey);
                },
                style: const TextStyle(fontSize: 14, color: AppColors.textDarkColor),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: AppColors.hintTextColor, fontSize: 13),
                  prefixIcon: prefixIcon != null ? Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: prefixIcon) : null,
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixText: suffixText,
                  suffixStyle: TextStyle(color: AppColors.textMediumColor, fontSize: 13, fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: hasError ? AppColors.errorColor : Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: hasError ? AppColors.errorColor : Colors.grey.shade200, width: hasError ? 1.5 : 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: hasError ? AppColors.errorColor : AppColors.primaryColor, width: 1.5),
                  ),
                  filled: true,
                  fillColor: hasError ? AppColors.errorColor.withOpacity(0.04) : AppColors.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: AppColors.errorColor, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(errorText, style: TextStyle(color: AppColors.errorColor, fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  IconData _getGroupTypeIcon(String type) {
    switch (type) {
      case 'size': return Icons.straighten_rounded;
      case 'addon': return Icons.add_circle_outline_rounded;
      case 'ingredient': return Icons.restaurant_rounded;
      case 'customization': return Icons.tune_rounded;
      default: return Icons.category_rounded;
    }
  }
}

// ─── REUSABLE SECTION CARD ───────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.icon, required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.secondaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDarkColor)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── REUSABLE FLAG TILE ──────────────────────────────────────
class _FlagTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _FlagTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: value ? activeColor.withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? activeColor.withOpacity(0.25) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: value ? activeColor : Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: value ? AppColors.textDarkColor : AppColors.textMediumColor)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: AppColors.textMediumColor)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor,
            ),
          ),
        ],
      ),
    );
  }
}
