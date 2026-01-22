import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/onboarding/controllers/vendor_step1_controller.dart';
import 'package:mrsheaf/features/onboarding/widgets/vendor_stepper.dart';
import 'package:mrsheaf/core/services/language_service.dart';

class VendorStep1Screen extends StatelessWidget {
  const VendorStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final controller = Get.put(VendorStep1Controller());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                
                // Language selector
                _buildLanguageSelector(),
                
                const SizedBox(height: 20),

                // App logo
                _buildLogo(),
                
                const SizedBox(height: 20),

                // Progress stepper
                const VendorStepper(currentStep: 0),
                
                const SizedBox(height: 30),

                // Title
                Text(
                  'vendor_step1_title'.tr,
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
                  'vendor_step1_subtitle'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),

                // Plans list
                _buildPlansSection(controller),
                
                const SizedBox(height: 30),

                // Continue button
                _buildContinueButton(controller),
                
                const SizedBox(height: 20),

                // Login link
                _buildLoginLink(),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final languageService = Get.find<LanguageService>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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

  Widget _buildPlansSection(VendorStep1Controller controller) {
    return Obx(() {
      if (controller.isLoadingPlans.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: Color(0xFFFACD02)),
          ),
        );
      }

      if (controller.subscriptionPlans.isEmpty) {
        return Center(
          child: Text(
            'no_subscription_plans'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        );
      }

      return Column(
        children: controller.subscriptionPlans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          final isSelected = controller.selectedPlanIndex.value == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPlanCard(controller, index, plan, isSelected),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPlanCard(VendorStep1Controller controller, int index, SubscriptionPlan plan, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectPlan(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFBE6) : const Color(0xFFF8F8F8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFACD02) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFACD02) : const Color(0xFFD0D0D0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFACD02),
                        ),
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name, // Keep in English
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF262626),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.isFree ? 'free'.tr : plan.price,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: plan.isFree ? const Color(0xFF27AE60) : const Color(0xFFFACD02),
                    ),
                  ),
                  if (!plan.isFree) ...[
                    const SizedBox(height: 2),
                    Text(
                      '/ ${plan.period}'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Features count
            if (plan.benefits.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${plan.benefits.length} ${'features'.tr}',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF27AE60),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(VendorStep1Controller controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : () => controller.submitSubscriptionPlan(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFACD02),
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: controller.isSubmitting.value
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_have_account'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.LOGIN),
          child: Text(
            'login'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFFFACD02),
            ),
          ),
        ),
      ],
    );
  }
}
