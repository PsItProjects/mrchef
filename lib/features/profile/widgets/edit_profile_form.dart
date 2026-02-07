import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/edit_profile_controller.dart';

class EditProfileForm extends GetView<EditProfileController> {
  const EditProfileForm({super.key});

  // ─── Theme constants ───
  static const _borderColor = Color(0xFFE8E8E8);
  static const _focusBorderColor = Color(0xFFFACD02);
  static const _labelColor = Color(0xFF8C8C8C);
  static const _textColor = Color(0xFF2D2D2D);
  static const _fieldRadius = 14.0;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // English Name
          _buildInputField(
            label: 'full_name'.tr,
            controller: controller.fullNameController,
            validator: controller.validateFullName,
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 20),

          // Arabic Name
          _buildInputField(
            label: 'full_name_arabic'.tr,
            controller: controller.arabicNameController,
            validator: controller.validateArabicName,
            icon: Icons.person_outline_rounded,
            textDirection: TextDirection.rtl,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 20),

          // Email
          _buildInputField(
            label: 'email'.tr,
            controller: controller.emailController,
            validator: controller.validateEmail,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 20),

          // Phone
          _buildPhoneField(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textDirection: textDirection,
      textInputAction: textInputAction,
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: _textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: _labelColor,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.primaryColor.withOpacity(0.85),
        ),
        prefixIcon: Icon(icon, color: _labelColor, size: 20),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: _focusBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country code chip
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(_fieldRadius),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flag emoji
              const Text('🇸🇦', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Obx(() => Text(
                    controller.countryCode.value,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: _textColor,
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Phone input
        Expanded(
          child: TextFormField(
            controller: controller.phoneController,
            validator: controller.validatePhone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: _textColor,
            ),
            decoration: InputDecoration(
              labelText: 'phone'.tr,
              labelStyle: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: _labelColor,
              ),
              floatingLabelStyle: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.primaryColor.withOpacity(0.85),
              ),
              prefixIcon:
                  const Icon(Icons.phone_outlined, color: _labelColor, size: 20),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
                borderSide: const BorderSide(color: _borderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
                borderSide: const BorderSide(color: _borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
                borderSide:
                    const BorderSide(color: _focusBorderColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
