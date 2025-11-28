import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class StoreDetailsHeader extends GetView<StoreDetailsController> {
  const StoreDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 333, // Height from Figma design
      child: Stack(
        children: [
          // Background image
          Obx(() => Container(
            height: 289,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              image: controller.storeImage.value.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(controller.storeImage.value),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                      onError: (exception, stackTrace) {
                        // Fallback to default image
                      },
                    )
                  : DecorationImage(
                      image: AssetImage("assets/images/banner_bg.png"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                    ),
            ),
          )),
          
          // Status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time
                  Text(
                    '9:30',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: const Color(0xFF592E2C),
                    ),
                  ),
                  
                  // Right icons (WiFi, Signal, Battery)
                  Container(
                    width: 46,
                    height: 17,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // WiFi icon
                        Container(width: 17, height: 17),
                        // Signal icon  
                        Container(width: 17, height: 17),
                        // Battery icon
                        Container(width: 8, height: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Header navigation
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/arrow_left.svg',
                          width: 24,
                          height: 24,
                          color: const Color(0xFF592E2C),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF592E2C),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Store name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() => Text(
                      controller.storeName.value,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    )),
                  ),
                  
                  // Heart button
                  Obx(() => GestureDetector(
                    onTap: controller.toggleFavorite,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          controller.isFavorite.value
                              ? 'assets/icons/heart_icon.svg'
                              : 'assets/icons/heart_outline.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            controller.isFavorite.value
                                ? AppColors.errorColor
                                : const Color(0xFF592E2C),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          // Store profile image
          Positioned(
            bottom: 0,
            left: 24,
            child: Obx(() => Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFACD02),
                  width: 4,
                ),
              ),
              child: Container(
                width: 150,
                height: 150,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: controller.storeProfileImage.value.isNotEmpty
                      ? Image.network(
                          controller.storeProfileImage.value,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.restaurant,
                                color: AppColors.primaryColor,
                                size: 60,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: AppColors.primaryColor,
                            size: 60,
                          ),
                        ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
