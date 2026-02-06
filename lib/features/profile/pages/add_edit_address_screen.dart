import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/profile/controllers/add_edit_address_controller.dart';
import 'package:mrsheaf/features/profile/models/address_model.dart';
import 'package:mrsheaf/features/profile/widgets/add_edit_address_header.dart';
import 'package:mrsheaf/features/profile/widgets/add_edit_address_form.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;
  final bool fromCheckout;

  const AddEditAddressScreen({super.key, this.address, this.fromCheckout = false});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize controller once in initState
    Get.put(AddEditAddressController(
      existingAddress: widget.address,
      fromCheckout: widget.fromCheckout,
    ));
  }

  @override
  void dispose() {
    // Clean up controller when screen is disposed
    Get.delete<AddEditAddressController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return GetBuilder<AddEditAddressController>(
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              const AddEditAddressHeader(),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // Form
                      const AddEditAddressForm(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              
              // Save button
              Container(
                width: 380,
                // height: 50,
                margin: const EdgeInsets.all(24),
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF592E2C)),
                          ),
                        )
                      : Text(
                          'save'.tr,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF592E2C),
                            letterSpacing: -0.005,
                          ),
                        ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
