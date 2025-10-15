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
  bool _isLoading = false;

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

  // Day names with translations
  Map<String, String> get dayNames => {
    'saturday': 'saturday'.tr,
    'sunday': 'sunday'.tr,
    'monday': 'monday'.tr,
    'tuesday': 'tuesday'.tr,
    'wednesday': 'wednesday'.tr,
    'thursday': 'thursday'.tr,
    'friday': 'friday'.tr,
  };
  
  @override
  void initState() {
    super.initState();
    // Load working hours after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkingHours();
    });
  }

  void _loadWorkingHours() {
    print('🕐 === LOADING WORKING HOURS IN SCREEN ===');

    final restaurant = _settingsService.restaurantInfo.value;
    print('   restaurantInfo is null: ${restaurant == null}');

    if (restaurant != null) {
      print('   restaurantInfo.businessHours is null: ${restaurant.businessHours == null}');
      if (restaurant.businessHours != null) {
        print('   restaurantInfo.businessHours has ${restaurant.businessHours!.length} days');
        restaurant.businessHours!.forEach((day, hours) {
          print('   - $day: ${hours.isOpen ? "OPEN ${hours.openTime}-${hours.closeTime}" : "CLOSED"}');
        });
      }
    }

    if (restaurant != null && restaurant.businessHours != null && restaurant.businessHours!.isNotEmpty) {
      print('✅ Found business hours data, loading into screen state...');
      setState(() {
        workingHours = Map.from(restaurant.businessHours!);
      });
      print('✅ Loaded ${workingHours.length} days into screen state');
    } else {
      print('⚠️ No business hours data from service, initializing all days as closed');
      // If no business hours data from API, initialize with all days closed
      setState(() {
        workingHours = {
          'saturday': WorkingDay(isOpen: false, openTime: '09:00', closeTime: '22:00'),
          'sunday': WorkingDay(isOpen: false, openTime: '09:00', closeTime: '22:00'),
          'monday': WorkingDay(isOpen: false, openTime: '09:00', closeTime: '22:00'),
          'tuesday': WorkingDay(isOpen: false, openTime: '09:00', closeTime: '22:00'),
          'wednesday': WorkingDay(isOpen: false, openTime: '09:00', closeTime: '22:00'),
          'thursday': WorkingDay(isOpen: false, openTime: '09:00', closeTime: '22:00'),
          'friday': WorkingDay(isOpen: false, openTime: '09:00', closeTime: '22:00'),
        };
      });
    }
    print('🕐 === END LOADING WORKING HOURS ===');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDarkColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'working_hours'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkColor,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveWorkingHours,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDarkColor),
                    ),
                  )
                : Text(
                    'save'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDarkColor,
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (_settingsService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildWorkingDaysList(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
              Icons.access_time,
              color: AppColors.textDarkColor,
              size: 28,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'configure_restaurant_hours'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: AppColors.greyColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Day name
          Expanded(
            flex: 2,
            child: Text(
              dayNames[day] ?? day,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDarkColor,
              ),
            ),
          ),

          // Time or Closed
          Expanded(
            flex: 3,
            child: workingDay.isOpen
                ? Row(
                    children: [
                      Expanded(
                        child: _buildTimeButton(
                          time: workingDay.openTime,
                          onTap: () => _selectTime(day, true),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildTimeButton(
                          time: workingDay.closeTime,
                          onTap: () => _selectTime(day, false),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'closed'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
          ),

          // Switch
          const SizedBox(width: 8),
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
            activeTrackColor: AppColors.primaryColor.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeButton({
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          _formatTimeTo12Hour(time), // Convert to 12-hour format for display
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkColor,
          ),
        ),
      ),
    );
  }

  /// Convert 24-hour time (HH:mm) to 12-hour format with AM/PM
  String _formatTimeTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      int hour = int.parse(parts[0]);
      final minute = parts[1];

      // Determine AM/PM
      final period = hour >= 12 ? 'PM' : 'AM';

      // Convert hour to 12-hour format
      if (hour == 0) {
        hour = 12; // Midnight
      } else if (hour > 12) {
        hour = hour - 12;
      }

      return '$hour:$minute $period';
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }

  /// Convert 12-hour time with AM/PM to 24-hour format (HH:mm)
  String _formatTimeTo24Hour(int hour, int minute, DayPeriod period) {
    int hour24 = hour;

    if (period == DayPeriod.am) {
      if (hour == 12) {
        hour24 = 0; // Midnight
      }
    } else { // PM
      if (hour != 12) {
        hour24 = hour + 12;
      }
    }

    return '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_actions'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkColor,
            ),
          ),
          const SizedBox(height: 12),
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
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
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
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false, // Force 12-hour format
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primaryColor,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (selectedTime != null) {
      // Convert selected time to 24-hour format for storage
      final timeString = _formatTimeTo24Hour(
        selectedTime.hourOfPeriod == 0 ? 12 : selectedTime.hourOfPeriod,
        selectedTime.minute,
        selectedTime.period,
      );

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
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _settingsService.updateWorkingHours(workingHours);

      if (success) {
        // Show success message
        Get.snackbar(
          'success'.tr,
          'working_hours_updated_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Wait a bit before closing to show the message
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
