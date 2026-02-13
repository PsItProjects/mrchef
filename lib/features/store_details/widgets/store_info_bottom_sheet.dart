import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';
import 'package:mrsheaf/features/store_details/widgets/working_hours_section.dart';
import 'package:mrsheaf/features/store_details/widgets/locations_section.dart';

class StoreInfoBottomSheet extends StatefulWidget {
  const StoreInfoBottomSheet({super.key});

  @override
  State<StoreInfoBottomSheet> createState() => _StoreInfoBottomSheetState();
}

class _StoreInfoBottomSheetState extends State<StoreInfoBottomSheet> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreDetailsController>();
    return GestureDetector(
      onTap: () => controller.hideStoreInfoBottomSheet(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.45),
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping on the sheet
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.25,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Text(
                        'store_information'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.textDarkColor,
                        ),
                      ),
                    ),

                    Divider(color: Colors.grey.shade200, height: 1),

                    // Menu items
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            _buildMenuItem(
                              icon: Icons.schedule_outlined,
                              title: 'working_hours'.tr,
                              onTap: () => _showWorkingHours(context),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Divider(
                                  color: Colors.grey.shade100, height: 1),
                            ),

                            _buildMenuItem(
                              icon: Icons.location_on_outlined,
                              title: 'location'.tr,
                              onTap: () => _showLocations(context),
                            ),

                            const SizedBox(height: 40),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textDarkColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkingHours(BuildContext context) {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    Get.to(() => const WorkingHoursSection());

    final controller = Get.find<StoreDetailsController>();
    controller.loadWorkingHours();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    });
  }

  void _showLocations(BuildContext context) {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    Get.to(() => const LocationsSection());

    final controller = Get.find<StoreDetailsController>();
    controller.loadLocation();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    });
  }
}
