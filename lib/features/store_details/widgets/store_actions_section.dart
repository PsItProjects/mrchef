import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class StoreActionsSection extends GetView<StoreDetailsController> {
  const StoreActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 97), // Centered with proper spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Message button
          Expanded(
            child: Container(
                     
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFACD02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFACD02),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.sendMessage(),
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Text(
                      'message'.tr,
                      style: const TextStyle(
                        fontFamily: 'Givonic',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF592E2C),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // More button (three dots)
          GestureDetector(
            onTap: () => controller.showStoreInfoBottomSheet(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFACD02),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  child: Stack(
                    children: [
                      // Three dots
                      Positioned(
                        left: 16.02,
                        top: 9.17,
                        child: Container(
                          width: 0,
                          height: 0.02,
                          decoration: BoxDecoration(
                            color: const Color(0xFF592E2C),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 15.16,
                        top: 15.25,
                        child: Container(
                          width: 1.73,
                          height: 1.73,
                          decoration: BoxDecoration(
                            color: const Color(0xFF592E2C),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 15.16,
                        top: 22.18,
                        child: Container(
                          width: 1.73,
                          height: 1.73,
                          decoration: BoxDecoration(
                            color: const Color(0xFF592E2C),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
