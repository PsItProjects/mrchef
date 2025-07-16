import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import 'package:mrsheaf/features/onboarding/widgets/vendor_stepper.dart';

class VendorStep2Screen extends StatelessWidget {
  const VendorStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                Positioned(
                  top: 88,
                  left: 164,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD2D2D2),
                    ),
                  ),
                ),

                // Main content
                Positioned(
                  top: 232,
                  left: 67,
                  right: 67,
                  child: Column(
                    children: [
                      // Progress indicator
                      VendorStepper(currentStep: 1),
                      SizedBox(height: 24),

                      // Store information form
                      _buildStoreInformationForm(),
                      SizedBox(height: 50),

                      // Sign up button
                      _buildSignupButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildStoreInformationForm() {
    return Container(
      width: 380,
      child: Column(
        children: [
          _buildInputField('Store Name - English', 'Enter Store name'),
          SizedBox(height: 20),
          _buildInputField('Store Name - Arabic', 'Enter Store name'),
          SizedBox(height: 20),
          _buildInputField('Commercial registration number',
              'Enter your Commercial registration number'),
          SizedBox(height: 20),
          _buildFileUploadField('Work permit',
              'Copy of work permit,\nplease upload file in PDF format'),
          SizedBox(height: 20),
          _buildFileUploadField('ID or passport number',
              'ID or passport number of the store owner,\nplease upload file in PDF format'),
          SizedBox(height: 20),
          _buildFileUploadField('Health certificate',
              'ID or passport number of the store owner,\nplease upload file in PDF format'),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFD2D2D2), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFFB7B7B7),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xFFE3E3E3),
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                child: Icon(
                  Icons.attach_file,
                  color: Color(0xFF999999),
                  size: 24,
                ),
              ),
              Expanded(
                child: Text(
                  placeholder,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFFB7B7B7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return Container(
      child: ElevatedButton(
        onPressed: () => Get.toNamed(AppRoutes.VENDOR_STEP3),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFD2D2D2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          'Sign up',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.005,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
