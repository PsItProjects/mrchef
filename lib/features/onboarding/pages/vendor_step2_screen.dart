import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
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
                const SizedBox(height: 30),
                const VendorStepper(currentStep: 2),
                const SizedBox(height: 20),
                _buildRequiredDocumentsWarning(),
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

  Widget _buildRequiredDocumentsWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        border: Border.all(color: const Color(0xFFFFE69C), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF9800),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationHelper.tr('required_documents_warning'),
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TranslationHelper.tr('required_documents_message'),
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF856404),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInformationForm(VendorStep2Controller controller) {
    return SizedBox(
      width: 380,
      child: Column(
        children: [
          _buildInputField(
            TranslationHelper.tr('store_name_english'),
            TranslationHelper.tr('enter_store_name'),
            controller.storeNameEn,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            TranslationHelper.tr('store_name_arabic'),
            TranslationHelper.tr('enter_store_name'),
            controller.storeNameAr,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            TranslationHelper.tr('commercial_registration_number'),
            TranslationHelper.tr('enter_commercial_registration'),
            controller.commercialRegistrationNumber,
          ),
          const SizedBox(height: 20),
          _buildFileUploadField(
            controller,
            'work_permit',
            TranslationHelper.tr('work_permit'),
            TranslationHelper.tr('work_permit_description'),
          ),
          const SizedBox(height: 20),
          _buildFileUploadField(
            controller,
            'id_or_passport',
            TranslationHelper.tr('id_or_passport'),
            TranslationHelper.tr('id_or_passport_description'),
          ),
          const SizedBox(height: 20),
          _buildFileUploadField(
            controller,
            'health_certificate',
            TranslationHelper.tr('health_certificate'),
            TranslationHelper.tr('health_certificate_description'),
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
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE3E3E3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            onChanged: (text) => value.value = text,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFFB7B7B7),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadField(
    VendorStep2Controller controller,
    String fileType,
    String label,
    String placeholder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Obx(() {
          final isSelected = controller.isFileSelected(fileType);
          final isLoading = controller.isFileLoading(fileType);
          final fileName = controller.getFileName(fileType);

          return GestureDetector(
            onTap: isLoading ? null : () => controller.pickFile(fileType),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE3E3E3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                  ? const Color(0xFFF1F8E9)
                  : Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isSelected ? Icons.check_circle : Icons.attach_file,
                          color: isSelected
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF999999),
                          size: 24,
                        ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected) ...[
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF4CAF50),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            controller.getFileTypeText(fileType),
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ] else ...[
                          Text(
                            placeholder,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFFB7B7B7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    GestureDetector(
                      onTap: () => controller.removeFile(fileType),
                      child: Container(
                        width: 40,
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF999999),
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
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
          backgroundColor: controller.isLoading.value
            ? const Color(0xFFD2D2D2)
            : AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: controller.isLoading.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Submit Business Information',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.secondaryColor,
                letterSpacing: -0.005,
                height: 1.45,
              ),
            ),
      ),
    ));
  }
}
