import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/add_edit_address_controller.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';

class AddEditAddressForm extends GetView<AddEditAddressController> {
  const AddEditAddressForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Type Selector
            _buildSectionLabel('address_type'.tr),
            const SizedBox(height: 10),
            _buildTypeSelector(),

            // Custom Label (only for 'other')
            Obx(() {
              if (!controller.showLabelInput) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSectionLabel('address_label'.tr),
                  const SizedBox(height: 8),
                  _buildTextField(
                    textController: controller.labelController,
                    hint: 'enter_address_label'.tr,
                    validator: controller.validateLabel,
                    prefixIcon: Icons.label_outline_rounded,
                  ),
                ],
              );
            }),

            const SizedBox(height: 20),
            _buildDivider(),
            const SizedBox(height: 20),

            // City
            _buildSectionLabel('city'.tr),
            const SizedBox(height: 8),
            _buildTextField(
              textController: controller.cityController,
              hint: 'enter_city'.tr,
              validator: controller.validateCity,
              prefixIcon: Icons.location_city_rounded,
            ),

            const SizedBox(height: 16),

            // State
            _buildSectionLabel('${'state_province'.tr} (${'optional'.tr})'),
            const SizedBox(height: 8),
            _buildTextField(
              textController: controller.stateController,
              hint: 'enter_state'.tr,
              prefixIcon: Icons.map_outlined,
            ),

            const SizedBox(height: 16),

            // Address Line 1
            _buildSectionLabel('address_line_1'.tr),
            const SizedBox(height: 8),
            _buildTextField(
              textController: controller.addressLine1Controller,
              hint: 'enter_address'.tr,
              validator: controller.validateAddressLine1,
              prefixIcon: Icons.home_outlined,
            ),

            const SizedBox(height: 16),

            // Address Line 2
            _buildSectionLabel('${'address_line_2'.tr} (${'optional'.tr})'),
            const SizedBox(height: 8),
            _buildTextField(
              textController: controller.addressLine2Controller,
              hint: 'apartment_suite'.tr,
              prefixIcon: Icons.apartment_rounded,
            ),

            const SizedBox(height: 20),
            _buildDivider(),
            const SizedBox(height: 16),

            // Make Default toggle
            _buildDefaultToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF262626),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required String hint,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: textController,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Color(0xFF262626),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFFB7B7B7),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFFB7B7B7), size: 20)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEB5757)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEB5757), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Obx(() => Row(
          children: [
            _buildTypeChip(
                AddressType.home, 'home_address'.tr, Icons.home_rounded),
            const SizedBox(width: 10),
            _buildTypeChip(
                AddressType.work, 'work_address'.tr, Icons.work_rounded),
            const SizedBox(width: 10),
            _buildTypeChip(AddressType.other, 'other_address'.tr,
                Icons.more_horiz_rounded),
          ],
        ));
  }

  Widget _buildTypeChip(AddressType type, String label, IconData icon) {
    final isSelected = controller.selectedType.value == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeAddressType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor
                  : const Color(0xFFE8E8E8),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF592E2C)
                    : const Color(0xFFB7B7B7),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                  color: isSelected
                      ? const Color(0xFF592E2C)
                      : const Color(0xFF5E5E5E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFF0F0F0),
    );
  }

  Widget _buildDefaultToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outline_rounded,
                  color: Color(0xFFFACD02), size: 20),
              const SizedBox(width: 8),
              Text(
                'make_default'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF262626),
                ),
              ),
            ],
          ),
          Obx(() => Switch(
                value: controller.isDefault.value,
                onChanged: controller.toggleDefault,
                activeColor: AppColors.primaryColor,
                activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
                inactiveThumbColor: const Color(0xFFE3E3E3),
                inactiveTrackColor: const Color(0xFFB7B7B7),
              )),
        ],
      ),
    );
  }
}
