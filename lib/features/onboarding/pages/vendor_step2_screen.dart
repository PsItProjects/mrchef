import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrsheaf/features/onboarding/widgets/vendor_stepper.dart';
import 'package:mrsheaf/core/services/language_service.dart';
import '../controllers/vendor_step2_controller.dart';

class VendorStep2Screen extends StatelessWidget {
  const VendorStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(VendorStep2Controller());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                
                // Header with back button and language selector
                _buildHeader(),
                
                const SizedBox(height: 20),

                // App logo
                _buildLogo(),
                
                const SizedBox(height: 20),

                // Progress stepper
                const VendorStepper(currentStep: 2),
                
                const SizedBox(height: 30),

                // Title
                Text(
                  'store_information'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Color(0xFF262626),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'enter_store_details'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),

                // Store information form
                _buildStoreInformationForm(controller),
                
                const SizedBox(height: 40),

                // Submit button
                _buildSignupButton(controller),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final languageService = Get.find<LanguageService>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF262626),
            ),
          ),
        ),
        
        // Language selector
        GestureDetector(
          onTap: () async {
            final currentLang = Get.locale?.languageCode ?? 'ar';
            final newLang = currentLang == 'ar' ? 'en' : 'ar';
            await languageService.setLanguage(newLang);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 18, color: Color(0xFF262626)),
                const SizedBox(width: 6),
                Obx(() => Text(
                  languageService.currentLanguageRx.value == 'ar' ? 'العربية' : 'English',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    color: Color(0xFF262626),
                  ),
                )),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF262626)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF5F5F5),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/mr_sheaf_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.restaurant, size: 50, color: Colors.grey);
          },
        ),
      ),
    );
  }

  Widget _buildStoreInformationForm(VendorStep2Controller controller) {
    return Column(
      children: [
        _buildInputField(
          'store_name_english'.tr,
          'enter_store_name'.tr,
          controller.storeNameEn,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          'store_name_arabic'.tr,
          'enter_store_name'.tr,
          controller.storeNameAr,
        ),
        const SizedBox(height: 30),
        
        // Location Section with Map
        _buildLocationSection(controller),
      ],
    );
  }

  Widget _buildLocationSection(VendorStep2Controller controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFFFACD02), size: 24),
            const SizedBox(width: 8),
            Text(
              'store_location'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF262626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'location_required_for_delivery'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 16),
        
        // Get Location Button
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: controller.isGettingLocation.value
                ? null
                : () => controller.getCurrentLocation(),
            icon: controller.isGettingLocation.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    controller.locationFetched.value
                        ? Icons.check_circle
                        : Icons.my_location,
                    color: controller.locationFetched.value
                        ? Colors.green
                        : const Color(0xFF592E2C),
                  ),
            label: Text(
              controller.locationFetched.value
                  ? 'location_fetched'.tr
                  : 'get_current_location'.tr,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: controller.locationFetched.value
                    ? Colors.green
                    : const Color(0xFF592E2C),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: controller.locationFetched.value
                    ? Colors.green
                    : const Color(0xFFE0E0E0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )),

        const SizedBox(height: 16),

        // Map Container (Always Visible)
        Obx(() => Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                controller.latitude.value,
                controller.longitude.value,
              ),
              zoom: 14,
            ),
            onMapCreated: controller.onMapCreated,
            onTap: controller.onMapTapped,
            markers: controller.markers.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: false, // Disable double-tap zoom
            scrollGesturesEnabled: true, // Allow drag/pan
            rotateGesturesEnabled: false, // Disable rotation
            tiltGesturesEnabled: false, // Disable tilt
            mapToolbarEnabled: false,
          ),
        )),
        const SizedBox(height: 12),
        
        // Instructions section
        Obx(() => !controller.showMarker.value
            ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF666666),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'map_instructions'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
        ),
        
        Obx(() => controller.showMarker.value
            ? const SizedBox(height: 8)
            : const SizedBox.shrink(),
        ),
        
        Obx(() => controller.showMarker.value
            ? Text(
                'drag_marker_to_adjust'.tr,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
                textAlign: TextAlign.center,
              )
            : const SizedBox.shrink(),
        ),
        
        // Show coordinates if fetched
        Obx(() => controller.locationFetched.value
            ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${'latitude'.tr}: ${controller.latitude.value.toStringAsFixed(6)}\n${'longitude'.tr}: ${controller.longitude.value.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink()),

        const SizedBox(height: 24),
        
        // Address Fields Section
        _buildAddressSection(controller),
      ],
    );
  }

  Widget _buildAddressSection(VendorStep2Controller controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            const Icon(Icons.home, color: Color(0xFFFACD02), size: 24),
            const SizedBox(width: 8),
            Text(
              'store_address'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF262626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'address_required_note'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 16),
        
        // Address in English (Required)
        _buildAddressInputField(
          'address_english'.tr,
          'enter_address_english_placeholder'.tr,
          controller.addressEn,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        
        // Address in Arabic (Required)
        _buildAddressInputField(
          'address_arabic'.tr,
          'enter_address_arabic_placeholder'.tr,
          controller.addressAr,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildAddressInputField(
    String label, 
    String placeholder, 
    RxString value, 
    {bool isRequired = false}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF262626),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() => TextFormField(
            initialValue: value.value,
            onChanged: (text) => value.value = text,
            maxLines: 2,
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
                color: Color(0xFF999999),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.location_city, color: Color(0xFF999999)),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String placeholder, RxString value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF262626),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            initialValue: value.value,
            onChanged: (text) => value.value = text,
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
                color: Color(0xFF999999),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton(VendorStep2Controller controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
          ? null
          : () => controller.submitBusinessInfo(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFACD02),
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: controller.isLoading.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF592E2C)),
              ),
            )
          : Text(
              'continue'.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF592E2C),
              ),
            ),
      ),
    ));
  }
}
