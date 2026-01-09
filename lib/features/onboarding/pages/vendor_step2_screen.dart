import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/features/onboarding/widgets/vendor_stepper.dart';
import '../controllers/vendor_step2_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/translation_helper.dart';

class VendorStep2Screen extends StatelessWidget {
  const VendorStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(VendorStep2Controller());

    // Get current language for RTL support
    final isArabic = TranslationHelper.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                // App logo circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD2D2D2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/mr_sheaf_logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const VendorStepper(currentStep: 2),
                const SizedBox(height: 20),
                _buildStoreInformationForm(controller),
                const SizedBox(height: 40),
                _buildSignupButton(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Color(0xFF262626),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD2D2D2), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.language,
                size: 16,
                color: Color(0xFF262626),
              ),
              SizedBox(width: 4),
              Text(
                'EN',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF262626),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInformationForm(VendorStep2Controller controller) {
    return SizedBox(
      width: 380,
      child: Column(
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
        ],
      ),
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
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD2D2D2), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                fontSize: 12,
                color: Color(0xFFB7B7B7),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton(VendorStep2Controller controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
          ? null
          : () => controller.submitBusinessInfo(),
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isLoading.value
            ? const Color(0xFFD2D2D2)
            : AppColors.primaryColor,
          foregroundColor: AppColors.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Center(
          child: controller.isLoading.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'submit_business_info'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.005,
                ),
              ),
        ),
      ),
    ));
  }
}
