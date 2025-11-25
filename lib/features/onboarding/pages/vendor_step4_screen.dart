import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/onboarding/widgets/vendor_stepper.dart';

class VendorStep4Screen extends StatelessWidget {
  const VendorStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('vendor_step_4'.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress indicator
            VendorStepper(currentStep: 3),
            SizedBox(height: 40),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vendor Onboarding Complete!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF262626),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your vendor account has been successfully created.\nYou will be notified once your account is approved.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    Container(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFACD02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Go to Login',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF592E2C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
