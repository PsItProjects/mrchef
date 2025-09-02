import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/edit_profile_controller.dart';

class EditProfileForm extends GetView<EditProfileController> {
  const EditProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // English Name field
          _buildInputField(
            label: 'full_name'.tr,
            controller: controller.fullNameController,
            validator: controller.validateFullName,
          ),

          const SizedBox(height: 24),

          // Arabic Name field
          _buildInputField(
            label: 'full_name_arabic'.tr,
            controller: controller.arabicNameController,
            validator: controller.validateArabicName,
          ),

          const SizedBox(height: 24),

          // Email field
          _buildInputField(
            label: 'email'.tr,
            controller: controller.emailController,
            validator: controller.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 24),
          
          // Phone Number field
          _buildPhoneField(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Input field
        Container(
          width: 380,
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF262626),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF262626),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF262626),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF262626),
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Phone Number',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Phone input with country code
        Row(
          children: [
            // Country code field
            Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF262626),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  // Saudi flag placeholder
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF006C35),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                    controller.countryCode.value,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF1C1C1C),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Phone number field
            Expanded(
              child: Container(
                height: 50,
                child: TextFormField(
                  controller: controller.phoneController,
                  validator: controller.validatePhone,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF262626),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF262626),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF262626),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF262626),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
