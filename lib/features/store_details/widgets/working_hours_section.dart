import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/store_details/controllers/store_details_controller.dart';

class WorkingHoursSection extends GetView<StoreDetailsController> {
  const WorkingHoursSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF262626)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'working_hours'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF262626),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Show loading indicator while fetching data
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        // Show empty state if no working hours
        if (controller.workingHours.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 64,
                  color: AppColors.textMediumColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'no_working_hours_available'.tr,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: AppColors.textMediumColor,
                  ),
                ),
              ],
            ),
          );
        }

        // Show working hours list
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: controller.workingHours.map((daySchedule) {
              return _buildDaySchedule(daySchedule);
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildDaySchedule(Map<String, dynamic> daySchedule) {
    final bool isOff = daySchedule['isOff'] ?? true;
    final String dayName = daySchedule['day']?.toString().toLowerCase() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Day name
          Expanded(
            flex: 2,
            child: Text(
              dayName.tr,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF262626),
              ),
            ),
          ),

          // Time slots or OFF indicator
          Expanded(
            flex: 3,
            child: isOff
                ? _buildOffIndicator()
                : (daySchedule['is24h'] == true
                    ? _build24hIndicator()
                    : _buildTimeSlots(daySchedule)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(Map<String, dynamic> daySchedule) {
    final String startTime = daySchedule['startTime']?.toString() ?? '--:--';
    final String endTime = daySchedule['endTime']?.toString() ?? '--:--';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Start time
        Text(
          startTime,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '-',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(width: 8),
        // End time
        Text(
          endTime,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOffIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'closed'.tr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _build24hIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.all_inclusive,
            size: 16,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            '24_hours'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
