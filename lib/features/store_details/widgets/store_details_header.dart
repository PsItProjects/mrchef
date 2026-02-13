import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class StoreDetailsHeader extends GetView<StoreDetailsController> {
  const StoreDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double coverHeight = topPadding + 230;
    const double profileSize = 88.0;
    const double profileOverlap = profileSize / 2;

    return SizedBox(
      height: coverHeight + profileOverlap,
      child: Stack(
        children: [
          // Cover image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: coverHeight,
            child: Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                image: controller.storeImage.value.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(controller.storeImage.value),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage("assets/images/banner_bg.png"),
                        fit: BoxFit.cover,
                      ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            )),
          ),

          // White curved overlay (connects to content below)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: profileOverlap,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
            ),
          ),

          // Profile image (centered, overlapping cover and white area)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildProfileImage(),
            ),
          ),

          // Floating navigation (back + heart)
          Positioned(
            top: topPadding + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Get.back(),
                ),
                Obx(() => _buildNavButton(
                  icon: controller.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  iconColor: controller.isFavorite.value
                      ? Colors.red
                      : Colors.white,
                  onTap: controller.toggleFavorite,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Obx(() => Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: controller.storeProfileImage.value.isNotEmpty
            ? Image.network(
                controller.storeProfileImage.value,
                width: 81,
                height: 81,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _defaultProfileIcon(),
              )
            : _defaultProfileIcon(),
      ),
    ));
  }

  Widget _defaultProfileIcon() {
    return Container(
      width: 81,
      height: 81,
      color: AppColors.primaryColor.withOpacity(0.1),
      child: const Icon(
        Icons.restaurant,
        color: AppColors.primaryColor,
        size: 36,
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.28),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
