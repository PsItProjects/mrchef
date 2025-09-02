import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';
import 'package:mrsheaf/features/store_details/widgets/working_hours_section.dart';
import 'package:mrsheaf/features/store_details/widgets/locations_section.dart';
import 'package:mrsheaf/features/store_details/widgets/contact_info_section.dart';

class StoreInfoBottomSheet extends GetView<StoreDetailsController> {
  const StoreInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.hideStoreInfoBottomSheet(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping on the sheet
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFE3E3E3),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'store_information'.tr,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: 1.5,
                          color: Color(0xFF262626),
                        ),
                      ),
                    ),
                    
                    // Content sections
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            
                            // Notifications toggle section
                            _buildNotificationSection(),
                            
                            _buildDivider(),
                            
                            // Working Hours section
                            _buildMenuSection(
                              title: 'working_hours'.tr,
                              onTap: () => _showWorkingHours(context),
                            ),

                            _buildDivider(),

                            // Location section
                            _buildMenuSection(
                              title: 'location'.tr,
                              onTap: () => _showLocations(context),
                            ),

                            _buildDivider(),

                            // Contact Information section
                            _buildMenuSection(
                              title: 'contact_information'.tr,
                              onTap: () => _showContactInfo(context),
                            ),

                            _buildDivider(),

                            // Block Store section
                            _buildMenuSection(
                              title: 'block_store'.tr,
                              titleColor: const Color(0xFFEB5757),
                              onTap: () => _blockStore(),
                            ),
                            
                            _buildDivider(),
                            
                            const SizedBox(height: 100), // Bottom padding
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      width: 428,
      child: Column(
        children: [
          Container(
            width: 428,
            height: 1,
            color: const Color(0xFFE3E3E3),
          ),
          
          Container(
            width: 380,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'turn_on_store_notifications'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
                
                GestureDetector(
                  onTap: () => controller.toggleNotifications(),
                  child: Obx(() => Container(
                    width: 24,
                    height: 24,
                    child: controller.notificationsEnabled.value
                        ? SvgPicture.asset('assets/icons/toggle_on.svg')
                        : SvgPicture.asset('assets/icons/toggle_off.svg'),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required VoidCallback onTap,
    Color titleColor = const Color(0xFF262626),
  }) {
    return Container(
      width: 428,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 380,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: titleColor,
                    ),
                  ),
                  
                  if (titleColor != const Color(0xFFEB5757))
                    SvgPicture.asset(
                      'assets/icons/arrow_right.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF262626),
                        BlendMode.srcIn,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 428,
      height: 1,
      color: const Color(0xFFE3E3E3),
    );
  }

  void _showWorkingHours(BuildContext context) {
    Get.to(() => const WorkingHoursSection());
  }

  void _showLocations(BuildContext context) {
    Get.to(() => const LocationsSection());
  }

  void _showContactInfo(BuildContext context) {
    Get.to(() => const ContactInfoSection());
  }

  void _blockStore() {
    // TODO: Implement block store functionality
    Get.snackbar(
      'Block Store',
      'This feature will be implemented soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
