import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/onboarding/widgets/vendor_stepper.dart';

class VendorStep1Screen extends StatefulWidget {
  const VendorStep1Screen({super.key});

  @override
  State<VendorStep1Screen> createState() => _VendorStep1ScreenState();
}

class _VendorStep1ScreenState extends State<VendorStep1Screen> {
  int selectedPlan = 0; // 0: Annual, 1: Half year, 2: Monthly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              // Back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: Color(0xFF262626),
                      ),
                    ),
                  ),

                  // Language selector (top right)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFD2D2D2), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language,
                            size: 18, color: Color(0xFF262626)),
                        SizedBox(width: 4),
                        Text(
                          'English',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF262626),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 10, color: Color(0xFF262626)),
                      ],
                    ),
                  ),
                ],
              ),

              // Gray circle (background decoration)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD2D2D2),
                ),
              ),

              // Main content
              Column(
                children: [
                  // Progress indicator
                  VendorStepper(currentStep: 0),
                  SizedBox(height: 24),

                  // Subscription content
                  _buildSubscriptionContent(),
                  SizedBox(height: 50),

                  // Continue button
                  _buildContinueButton(),
                  SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account ? ',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFF262626),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.LOGIN),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFFFACD02),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildSubscriptionContent() {
    return Container(
      // width: 381,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title and benefits
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Start Using MR SHeaf with Premium Benefits',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF262626),
                    letterSpacing: 0.015,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                // Benefits list
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBenefitItem(
                        'Save unlimited notes to a single project'),
                    SizedBox(height: 8),
                    _buildBenefitItem('Create unlimited projects and teams'),
                    SizedBox(height: 8),
                    _buildBenefitItem('Daily backups to keep your data safe'),
                  ],
                ),
                SizedBox(height: 16),

                // Subscription plans
                Row(
                  children: [
                    Expanded(
                        child: _buildPlanCard(
                            0, 'Annual', '\$79.99', 'per year', true)),
                    SizedBox(width: 8),
                    Expanded(
                        child: _buildPlanCard(1, 'Half a year', '\$35.99',
                            'per six months', false)),
                    SizedBox(width: 8),
                    Expanded(
                        child: _buildPlanCard(
                            2, 'Monthly', '\$7.99', 'per month', false)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check, color: Color(0xFF999999), size: 12),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
      int index, String title, String price, String period, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
          border: isSelected
              ? Border.all(color: Color(0xFFFACD02), width: 4)
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF262626),
              ),
            ),
            SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: Color(0xFFFACD02),
                letterSpacing: -0.01,
                height: 1.5,
              ),
            ),
            Text(
              period,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xFF4B4B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      // width: 380,
      // height: 50,
      child: ElevatedButton(
        onPressed: () => Get.toNamed(AppRoutes.VENDOR_STEP2),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFACD02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF592E2C),
            letterSpacing: -0.005,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
