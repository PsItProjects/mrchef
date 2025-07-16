import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/profile/controllers/add_edit_address_controller.dart';

class AddEditAddressForm extends GetView<AddEditAddressController> {
  const AddEditAddressForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // City field
            _buildInputField(
              label: 'City',
              controller: controller.cityController,
              validator: controller.validateCity,
              placeholder: 'Dawha',
            ),
            
            const SizedBox(height: 16),
            
            // State/Province field
            _buildInputField(
              label: 'State/Province (optional)',
              controller: controller.stateController,
              placeholder: 'Enter your State',
            ),
            
            const SizedBox(height: 16),
            
            // Address Line 1 field
            _buildInputField(
              label: 'Address Line 1',
              controller: controller.addressLine1Controller,
              validator: controller.validateAddressLine1,
              placeholder: 'Enter your address',
            ),
            
            const SizedBox(height: 16),
            
            // Address Line 2 field
            _buildInputField(
              label: 'Address Line 2',
              controller: controller.addressLine2Controller,
              placeholder: 'Apartment, suite, etc. (optional)',
            ),
            
            const SizedBox(height: 16),
            
            // Make Default toggle
            _buildDefaultToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    required String placeholder,
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
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF262626),
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF262626),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE3E3E3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE3E3E3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE3E3E3),
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

  Widget _buildDefaultToggle() {
    return Container(
      width: 380,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Make Default',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),
          
          Obx(() => Switch(
            value: controller.isDefault.value,
            onChanged: controller.toggleDefault,
            activeColor: const Color(0xFFEA0A2B),
            activeTrackColor: const Color(0xFFFCE3EA),
            inactiveThumbColor: const Color(0xFFE3E3E3),
            inactiveTrackColor: const Color(0xFFB7B7B7),
          )),
        ],
      ),
    );
  }
}
