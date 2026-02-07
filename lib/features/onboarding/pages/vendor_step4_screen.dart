import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/onboarding/controllers/vendor_step4_controller.dart';
import 'package:mrsheaf/features/onboarding/widgets/vendor_stepper.dart';

class VendorStep4Screen extends GetView<VendorStep4Controller> {
  const VendorStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('vendor_step_4'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              const VendorStepper(currentStep: 3),
              const SizedBox(height: 30),

              Text(
                'location_information'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF262626),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'location_information_desc'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 24),

              // Pick Location Button
              ElevatedButton.icon(
                onPressed: controller.pickLocation,
                icon: const Icon(Icons.location_on, size: 20),
                label: Text('pick_location_from_map'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: const Color(0xFF592E2C),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Latitude
              TextFormField(
                controller: controller.latitudeController,
                validator: controller.validateLatitude,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'latitude'.tr,
                  prefixIcon: const Icon(Icons.my_location),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Longitude
              TextFormField(
                controller: controller.longitudeController,
                validator: controller.validateLongitude,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'longitude'.tr,
                  prefixIcon: const Icon(Icons.my_location),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Address EN
              TextFormField(
                controller: controller.addressEnController,
                validator: (v) => controller.validateRequired(v, 'address_en'.tr),
                decoration: InputDecoration(
                  labelText: 'address_en'.tr,
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Address AR
              TextFormField(
                controller: controller.addressArController,
                validator: (v) => controller.validateRequired(v, 'address_ar'.tr),
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'address_ar'.tr,
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: controller.cityController,
                validator: (v) => controller.validateRequired(v, 'city'.tr),
                decoration: InputDecoration(
                  labelText: 'city'.tr,
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Area
              TextFormField(
                controller: controller.areaController,
                validator: (v) => controller.validateRequired(v, 'area'.tr),
                decoration: InputDecoration(
                  labelText: 'area'.tr,
                  prefixIcon: const Icon(Icons.map_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Building (optional)
              TextFormField(
                controller: controller.buildingController,
                decoration: InputDecoration(
                  labelText: 'building'.tr + ' (' + 'optional'.tr + ')',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Floor (optional)
              TextFormField(
                controller: controller.floorController,
                decoration: InputDecoration(
                  labelText: 'floor'.tr + ' (' + 'optional'.tr + ')',
                  prefixIcon: const Icon(Icons.layers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes (optional)
              TextFormField(
                controller: controller.notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'location_notes'.tr + ' (' + 'optional'.tr + ')',
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor:
                          AppColors.primaryColor.withOpacity(0.5),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF592E2C)),
                            ),
                          )
                        : Text(
                            'complete_onboarding'.tr,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: Color(0xFF592E2C),
                            ),
                          ),
                  )),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
