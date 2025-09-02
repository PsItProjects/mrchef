import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class StoreInfoSection extends GetView<StoreDetailsController> {
  const StoreInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Store name and location
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => Text(
                controller.storeName.value,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  letterSpacing: -0.24,
                  color: Color(0xFF262626),
                ),
              )),
              
              const SizedBox(height: 4),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/location.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF5E5E5E),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                    controller.storeLocation.value,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF5E5E5E),
                    ),
                  )),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Store description
          Obx(() => Text(
            controller.storeDescription.value,
            style: const TextStyle(
              fontFamily: 'Givonic',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.35,
              color: Color(0xFF282828),
            ),
          )),
        ],
      ),
    );
  }
}
