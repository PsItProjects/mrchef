import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class WorkingHoursSection extends GetView<StoreDetailsController> {
  const WorkingHoursSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:30',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: 0.14,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  Container(width: 46, height: 17), // Placeholder for status icons
                ],
              ),
            ),
            
            // Header
            Container(
              width: 380,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      'assets/icons/arrow_left.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF262626),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  
                  Text(
                    'working_hours'.tr,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF262626),
                    ),
                  ),
                  
                  SvgPicture.asset(
                    'assets/icons/more.svg',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
            
            // Working hours list
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() => Column(
                  children: controller.workingHours.map((daySchedule) {
                    return _buildDaySchedule(daySchedule);
                  }).toList(),
                )),
              ),
            ),
            
            // Bottom navigation
            Container(
              height: 28,
              child: Container(
                width: 72,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 178),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(Map<String, dynamic> daySchedule) {
    return Container(
      width: 380,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Day name
          Text(
            daySchedule['day'].toString().toLowerCase().tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),
          
          // Time slots or OFF indicator
          daySchedule['isOff']
              ? _buildOffIndicator()
              : _buildTimeSlots(daySchedule),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(Map<String, dynamic> daySchedule) {
    return Row(
      children: [
        // Start time
        _buildTimeSlot('Start time', daySchedule['startTime']),
        const SizedBox(width: 8),
        // End time
        _buildTimeSlot('End time', daySchedule['endTime']),
      ],
    );
  }

  Widget _buildTimeSlot(String label, String time) {
    return Container(
      width: 136,
      height: 56,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE3E3E3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label == 'Start time' ? 'start_time'.tr : 'end_time'.tr,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF4B4B4B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffIndicator() {
    return Container(
      width: 280,
      height: 56,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE3E3E3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'off'.tr,
          style: const TextStyle(
            fontFamily: 'Givonic',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF4B4B4B),
          ),
        ),
      ),
    );
  }
}
