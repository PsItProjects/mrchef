import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/widgets/app_layout.dart';
import 'package:mrsheaf/core/widgets/app_button.dart';
import 'package:mrsheaf/features/profile/controllers/shipping_addresses_controller.dart';

class EmptyAddressesWidget extends GetView<ShippingAddressesController> {
  const EmptyAddressesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.location_on_outlined,
      title: 'No Addresses Added',
      subtitle: 'Add your delivery addresses to make ordering easier and faster',
      action: AppButton(
        text: 'Add Address',
        onPressed: controller.addNewAddress,
        isFullWidth: false,
        width: 200,
      ),
    );
          
          const SizedBox(height: 24),
          
          // Empty addresses text
          Column(
            children: [
              const Text(
                'No Addresses Yet',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF1C1C1C),
                  letterSpacing: -0.005,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                width: 285,
                child: const Text(
                  'Add your shipping addresses to make ordering faster and easier.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF5E5E5E),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Add address button
          Container(
            width: 380,
            // height: 50,
            child: ElevatedButton(
              onPressed: controller.addNewAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add Address',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF592E2C),
                  letterSpacing: -0.005,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Test button to add sample data
          Container(
            width: 380,
            // height: 50,
            child: ElevatedButton(
              onPressed: controller.addSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF592E2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add Sample Addresses (Test)',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: -0.005,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
