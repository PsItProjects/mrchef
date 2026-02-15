import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mrsheaf/core/services/toast_service.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_coupon_controller.dart';
import 'package:mrsheaf/features/merchant/models/merchant_coupon_model.dart';
import 'package:mrsheaf/features/merchant/services/merchant_coupon_service.dart';

class MerchantCouponFormScreen extends StatefulWidget {
  final int? couponId;

  const MerchantCouponFormScreen({super.key, this.couponId});

  @override
  State<MerchantCouponFormScreen> createState() => _MerchantCouponFormScreenState();
}

class _MerchantCouponFormScreenState extends State<MerchantCouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final MerchantCouponController _controller;

  // Form controllers
  final _codeController = TextEditingController();
  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _valueController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxUsesTotalController = TextEditingController();
  final _maxUsesPerCustomerController = TextEditingController();

  // Form state
  String _type = 'percentage';
  String _appliesTo = 'all';
  bool _isActive = true;
  DateTime? _startsAt;
  DateTime? _expiresAt;
  final RxSet<int> _selectedProductIds = <int>{}.obs;

  bool _isEditing = false;
  MerchantCouponModel? _existingCoupon;
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MerchantCouponController>();
    _controller.loadProducts();

    if (widget.couponId != null) {
      _isEditing = true;
      _loadCouponDetail();
    }
  }

  Future<void> _loadCouponDetail() async {
    setState(() => _isLoadingDetail = true);
    try {
      final service = Get.find<MerchantCouponService>();
      final coupon = await service.getCoupon(widget.couponId!);
      if (coupon != null) {
        _existingCoupon = coupon;
        _codeController.text = coupon.code;
        _titleArController.text = coupon.title['ar'] ?? '';
        _titleEnController.text = coupon.title['en'] ?? '';
        _descArController.text = coupon.description?['ar'] ?? '';
        _descEnController.text = coupon.description?['en'] ?? '';
        _valueController.text = coupon.value.toStringAsFixed(coupon.value == coupon.value.roundToDouble() ? 0 : 2);
        if (coupon.maxDiscountAmount != null) {
          _maxDiscountController.text = coupon.maxDiscountAmount!.toStringAsFixed(2);
        }
        if (coupon.minOrderAmount != null) {
          _minOrderController.text = coupon.minOrderAmount!.toStringAsFixed(2);
        }
        if (coupon.maxUsesTotal != null) {
          _maxUsesTotalController.text = coupon.maxUsesTotal.toString();
        }
        if (coupon.maxUsesPerCustomer != null) {
          _maxUsesPerCustomerController.text = coupon.maxUsesPerCustomer.toString();
        }
        _type = coupon.type;
        _appliesTo = coupon.appliesTo;
        _isActive = coupon.isActive;
        _startsAt = coupon.startsAt;
        _expiresAt = coupon.expiresAt;

        if (coupon.products != null) {
          _selectedProductIds.addAll(coupon.products!.map((p) => p.id));
        }
      }
    } catch (e) {
      // Error loading detail
    } finally {
      setState(() => _isLoadingDetail = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleArController.dispose();
    _titleEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _valueController.dispose();
    _maxDiscountController.dispose();
    _minOrderController.dispose();
    _maxUsesTotalController.dispose();
    _maxUsesPerCustomerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'edit_coupon'.tr : 'create_coupon'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textDarkColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDarkColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoadingDetail
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === COUPON CODE ===
                    _buildSectionCard(
                      title: 'coupon_code'.tr,
                      icon: Icons.confirmation_number_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _codeController,
                                label: 'coupon_code'.tr,
                                hint: 'enter_coupon_code'.tr,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [_UpperCaseTextFormatter()],
                                onTap: () {
                                  // Select all text when tapping the code field
                                  if (_codeController.text.isNotEmpty) {
                                    _codeController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: _codeController.text.length,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildAutoGenerateButton(),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === TITLE & DESCRIPTION ===
                    _buildSectionCard(
                      title: 'coupon_details'.tr,
                      icon: Icons.description_outlined,
                      children: [
                        _buildTextField(
                          controller: _titleArController,
                          label: 'title_ar'.tr,
                          hint: 'enter_coupon_title_ar'.tr,
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _titleEnController,
                          label: 'title_en'.tr,
                          hint: 'enter_coupon_title_en'.tr,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _descArController,
                          label: 'description_ar'.tr,
                          hint: 'enter_description_ar'.tr,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _descEnController,
                          label: 'description_en'.tr,
                          hint: 'enter_description_en'.tr,
                          maxLines: 2,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === DISCOUNT TYPE & VALUE ===
                    _buildSectionCard(
                      title: 'discount_settings'.tr,
                      icon: Icons.local_offer_outlined,
                      children: [
                        Text(
                          'discount_type'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTypeOption(
                                'percentage',
                                'percentage'.tr,
                                Icons.percent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTypeOption(
                                'fixed',
                                'fixed_amount'.tr,
                                Icons.attach_money,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _valueController,
                          label: _type == 'percentage'
                              ? 'discount_percentage'.tr
                              : 'discount_amount'.tr,
                          hint: _type == 'percentage' ? '10' : '5.00',
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          suffix: _type == 'percentage' ? '%' : 'SAR',
                        ),
                        if (_type == 'percentage') ...[
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _maxDiscountController,
                            label: 'max_discount_amount'.tr,
                            hint: 'optional'.tr,
                            keyboardType: TextInputType.number,
                            suffix: 'SAR',
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _minOrderController,
                          label: 'min_order_amount'.tr,
                          hint: 'optional'.tr,
                          keyboardType: TextInputType.number,
                          suffix: 'SAR',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === PRODUCT SCOPE ===
                    _buildSectionCard(
                      title: 'applies_to'.tr,
                      icon: Icons.inventory_2_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildScopeOption(
                                'all',
                                'all_products'.tr,
                                Icons.select_all,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildScopeOption(
                                'specific',
                                'specific_products'.tr,
                                Icons.checklist,
                              ),
                            ),
                          ],
                        ),
                        if (_appliesTo == 'specific') ...[
                          const SizedBox(height: 16),
                          _buildProductPicker(),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === USAGE LIMITS ===
                    _buildSectionCard(
                      title: 'usage_limits'.tr,
                      icon: Icons.data_usage_outlined,
                      children: [
                        _buildTextField(
                          controller: _maxUsesTotalController,
                          label: 'max_uses_total'.tr,
                          hint: 'unlimited'.tr,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _maxUsesPerCustomerController,
                          label: 'max_uses_per_customer'.tr,
                          hint: 'unlimited'.tr,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === DATE RANGE ===
                    _buildSectionCard(
                      title: 'validity_period'.tr,
                      icon: Icons.date_range_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildDatePicker('start_date'.tr, _startsAt, (d) => setState(() => _startsAt = d))),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDatePicker('end_date'.tr, _expiresAt, (d) => setState(() => _expiresAt = d))),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === ACTIVE TOGGLE ===
                    _buildSectionCard(
                      title: 'status'.tr,
                      icon: Icons.toggle_on_outlined,
                      children: [
                        SwitchListTile(
                          title: Text(
                            'coupon_active'.tr,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textDarkColor,
                            ),
                          ),
                          subtitle: Text(
                            _isActive
                                ? 'coupon_active_description'.tr
                                : 'coupon_inactive_description'.tr,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              color: AppColors.textMediumColor,
                            ),
                          ),
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeColor: AppColors.successColor,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // === SUBMIT BUTTON ===
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _controller.isSubmitting.value ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryColor,
                              disabledBackgroundColor: AppColors.secondaryColor.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _controller.isSubmitting.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isEditing ? 'update_coupon'.tr : 'create_coupon'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        )),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ===========================
  // FORM WIDGETS
  // ===========================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.secondaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? suffix,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onTap: onTap,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontSize: 14,
        color: AppColors.textDarkColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        labelStyle: const TextStyle(
          fontFamily: 'Lato',
          fontSize: 13,
          color: AppColors.textMediumColor,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 13,
          color: AppColors.textMediumColor.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppColors.surfaceColor,
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'field_required'.tr;
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildAutoGenerateButton() {
    return InkWell(
      onTap: () {
        final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        final random = Random();
        final code = 'MR${String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))))}';
        _codeController.text = code;
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_fix_high, size: 18, color: AppColors.textDarkColor),
            const SizedBox(width: 4),
            Text(
              'auto'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryColor : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.secondaryColor : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.textMediumColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textMediumColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeOption(String value, String label, IconData icon) {
    final isSelected = _appliesTo == value;
    return GestureDetector(
      onTap: () => setState(() {
        _appliesTo = value;
        if (value == 'all') _selectedProductIds.clear();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryColor : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.secondaryColor : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.textMediumColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textMediumColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPicker() {
    return Obx(() {
      if (_controller.isLoadingProducts.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
        );
      }

      if (_controller.availableProducts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'no_products_available'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 13,
              color: AppColors.textMediumColor,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    '${'selected'.tr}: ${_selectedProductIds.length}',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textMediumColor,
                    ),
                  )),
              TextButton(
                onPressed: () {
                  if (_selectedProductIds.length == _controller.availableProducts.length) {
                    _selectedProductIds.clear();
                  } else {
                    _selectedProductIds.addAll(
                      _controller.availableProducts.map((p) => p.id),
                    );
                  }
                },
                child: Obx(() => Text(
                      _selectedProductIds.length == _controller.availableProducts.length
                          ? 'deselect_all'.tr
                          : 'select_all'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.secondaryColor,
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _controller.availableProducts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = _controller.availableProducts[index];
                return Obx(() {
                  final isSelected = _selectedProductIds.contains(product.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) {
                      if (isSelected) {
                        _selectedProductIds.remove(product.id);
                      } else {
                        _selectedProductIds.add(product.id);
                      }
                    },
                    activeColor: AppColors.secondaryColor,
                    dense: true,
                    title: Text(
                      product.localizedName,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        color: AppColors.textDarkColor,
                      ),
                    ),
                    subtitle: Text(
                      '${product.price.toStringAsFixed(2)} SAR',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: AppColors.textMediumColor,
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDatePicker(String label, DateTime? currentValue, Function(DateTime?) onChanged) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: currentValue ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.secondaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textDarkColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.textMediumColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 11,
                      color: AppColors.textMediumColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentValue != null
                        ? DateFormat('dd/MM/yyyy').format(currentValue)
                        : 'not_set'.tr,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      color: currentValue != null
                          ? AppColors.textDarkColor
                          : AppColors.textMediumColor,
                    ),
                  ),
                ],
              ),
            ),
            if (currentValue != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close, size: 16, color: AppColors.textMediumColor),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // SUBMIT
  // ===========================
  bool _isSubmittingLocal = false;

  Future<void> _submit() async {
    // Prevent double submission
    if (_isSubmittingLocal || _controller.isSubmitting.value) return;
    _isSubmittingLocal = true;

    if (!_formKey.currentState!.validate()) {
      _isSubmittingLocal = false;
      return;
    }

    if (_titleArController.text.trim().isEmpty) {
      _isSubmittingLocal = false;
      Get.snackbar(
        'error'.tr,
        'field_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    if (_valueController.text.trim().isEmpty) {
      _isSubmittingLocal = false;
      Get.snackbar(
        'error'.tr,
        'field_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    if (_appliesTo == 'specific' && _selectedProductIds.isEmpty) {
      _isSubmittingLocal = false;
      Get.snackbar(
        'error'.tr,
        'select_at_least_one_product'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    final data = <String, dynamic>{
      'title': {
        'ar': _titleArController.text.trim(),
        'en': _titleEnController.text.trim().isNotEmpty ? _titleEnController.text.trim() : null,
      },
      'type': _type,
      'value': double.tryParse(_valueController.text.trim()) ?? 0,
      'applies_to': _appliesTo,
      'is_active': _isActive,
    };

    if (_codeController.text.trim().isNotEmpty) {
      data['code'] = _codeController.text.trim().toUpperCase();
    }

    if (_descArController.text.trim().isNotEmpty || _descEnController.text.trim().isNotEmpty) {
      data['description'] = {
        'ar': _descArController.text.trim().isNotEmpty ? _descArController.text.trim() : null,
        'en': _descEnController.text.trim().isNotEmpty ? _descEnController.text.trim() : null,
      };
    }

    if (_maxDiscountController.text.trim().isNotEmpty) {
      data['max_discount_amount'] = double.tryParse(_maxDiscountController.text.trim());
    }
    if (_minOrderController.text.trim().isNotEmpty) {
      data['min_order_amount'] = double.tryParse(_minOrderController.text.trim());
    }
    if (_maxUsesTotalController.text.trim().isNotEmpty) {
      data['max_uses_total'] = int.tryParse(_maxUsesTotalController.text.trim());
    }
    if (_maxUsesPerCustomerController.text.trim().isNotEmpty) {
      data['max_uses_per_customer'] = int.tryParse(_maxUsesPerCustomerController.text.trim());
    }

    if (_startsAt != null) {
      data['starts_at'] = _startsAt!.toIso8601String();
    }
    if (_expiresAt != null) {
      data['expires_at'] = _expiresAt!.toIso8601String();
    }

    if (_appliesTo == 'specific') {
      data['product_ids'] = _selectedProductIds.toList();
    }

    try {
      bool success;
      if (_isEditing) {
        if (kDebugMode) print('📝 Updating coupon ${widget.couponId}...');
        success = await _controller.updateCoupon(widget.couponId!, data);
      } else {
        if (kDebugMode) print('📝 Creating coupon...');
        success = await _controller.createCoupon(data);
      }

      if (kDebugMode) print('📝 Submit result: success=$success, mounted=$mounted');
      _isSubmittingLocal = false;

      if (success) {
        if (kDebugMode) print('📝 Showing toast and navigating back...');
        ToastService.showSuccess(
          _isEditing ? 'coupon_updated_successfully'.tr : 'coupon_created_successfully'.tr,
        );
        // Use Navigator.pop instead of Get.back for reliable navigation
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (kDebugMode) print('📝 Submit returned false - no navigation');
      }
    } catch (e) {
      _isSubmittingLocal = false;
      if (kDebugMode) print('❌ _submit error: $e');
      if (kDebugMode) print('❌ _submit stackTrace: ${StackTrace.current}');
      ToastService.showError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}

/// Forces text to uppercase as the user types
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
