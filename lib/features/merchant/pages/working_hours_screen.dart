import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/services/merchant_settings_service.dart';

class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  final _settingsService = MerchantSettingsService.instance;
  
  // Working hours data
  Map<String, WorkingDay> workingHours = {
    'saturday': WorkingDay(isOpen: true, openTime: '09:00', closeTime: '22:00'),
    'sunday': WorkingDay(isOpen: true, openTime: '09:00', closeTime: '22:00'),
    'monday': WorkingDay(isOpen: true, openTime: '09:00', closeTime: '22:00'),
    'tuesday': WorkingDay(isOpen: true, openTime: '09:00', closeTime: '22:00'),
    'wednesday': WorkingDay(isOpen: true, openTime: '09:00', closeTime: '22:00'),
    'thursday': WorkingDay(isOpen: true, openTime: '09:00', closeTime: '22:00'),
    'friday': WorkingDay(isOpen: false, openTime: '09:00', closeTime: '22:00'),
  };
  
  final Map<String, String> dayNames = {
    'saturday': 'السبت',
    'sunday': 'الأحد',
    'monday': 'الاثنين',
    'tuesday': 'الثلاثاء',
    'wednesday': 'الأربعاء',
    'thursday': 'الخميس',
    'friday': 'الجمعة',
  };
  
  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }
  
  void _loadWorkingHours() {
    final restaurant = _settingsService.restaurantInfo.value;
    if (restaurant.businessHours != null) {
      setState(() {
        workingHours = Map.from(restaurant.businessHours!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom Header (like user screens)
          Container(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Title
                Text(
                  'working_hours'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                // Save button
                GestureDetector(
                  onTap: _saveWorkingHours,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'save'.tr,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
        if (_settingsService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildWorkingDaysList(),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'set_working_hours'.tr,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'configure_restaurant_hours'.tr,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkingDaysList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: workingHours.entries.map((entry) {
          final day = entry.key;
          final workingDay = entry.value;
          final isLast = day == workingHours.keys.last;
          
          return _buildWorkingDayItem(day, workingDay, isLast);
        }).toList(),
      ),
    );
  }
  
  Widget _buildWorkingDayItem(String day, WorkingDay workingDay, bool isLast) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  dayNames[day] ?? day,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: workingDay.isOpen
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildTimeButton(
                              time: workingDay.openTime,
                              label: 'open'.tr,
                              onTap: () => _selectTime(day, true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '-',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimeButton(
                              time: workingDay.closeTime,
                              label: 'close'.tr,
                              onTap: () => _selectTime(day, false),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'closed'.tr,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
              Switch(
                value: workingDay.isOpen,
                onChanged: (value) {
                  setState(() {
                    workingHours[day] = WorkingDay(
                      isOpen: value,
                      openTime: workingDay.openTime,
                      closeTime: workingDay.closeTime,
                    );
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeButton({
    required String time,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          time,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_actions'.tr,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF262626),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                title: 'open_all_days'.tr,
                icon: Icons.check_circle_outline,
                color: AppColors.successColor,
                onTap: _openAllDays,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                title: 'close_all_days'.tr,
                icon: Icons.cancel_outlined,
                color: AppColors.errorColor,
                onTap: _closeAllDays,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildQuickActionButton(
            title: 'set_standard_hours'.tr,
            icon: Icons.access_time,
            color: AppColors.primaryColor,
            onTap: _setStandardHours,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectTime(String day, bool isOpenTime) async {
    final currentTime = isOpenTime 
        ? workingHours[day]!.openTime 
        : workingHours[day]!.closeTime;
    
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selectedTime != null) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      
      setState(() {
        if (isOpenTime) {
          workingHours[day] = WorkingDay(
            isOpen: workingHours[day]!.isOpen,
            openTime: timeString,
            closeTime: workingHours[day]!.closeTime,
          );
        } else {
          workingHours[day] = WorkingDay(
            isOpen: workingHours[day]!.isOpen,
            openTime: workingHours[day]!.openTime,
            closeTime: timeString,
          );
        }
      });
    }
  }
  
  void _openAllDays() {
    setState(() {
      workingHours.forEach((day, workingDay) {
        workingHours[day] = WorkingDay(
          isOpen: true,
          openTime: workingDay.openTime,
          closeTime: workingDay.closeTime,
        );
      });
    });
  }
  
  void _closeAllDays() {
    setState(() {
      workingHours.forEach((day, workingDay) {
        workingHours[day] = WorkingDay(
          isOpen: false,
          openTime: workingDay.openTime,
          closeTime: workingDay.closeTime,
        );
      });
    });
  }
  
  void _setStandardHours() {
    setState(() {
      workingHours.forEach((day, workingDay) {
        workingHours[day] = WorkingDay(
          isOpen: day != 'friday', // Close on Friday by default
          openTime: '09:00',
          closeTime: '22:00',
        );
      });
    });
  }
  
  Future<void> _saveWorkingHours() async {
    final success = await _settingsService.updateWorkingHours(workingHours);
    
    if (success) {
      Get.back();
    }
  }
}
