import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_dashboard_controller.dart';

class HomeStatisticsFilterModal extends StatefulWidget {
  final MerchantDashboardController controller;

  const HomeStatisticsFilterModal({Key? key, required this.controller})
      : super(key: key);

  @override
  State<HomeStatisticsFilterModal> createState() =>
      _HomeStatisticsFilterModalState();
}

class _HomeStatisticsFilterModalState extends State<HomeStatisticsFilterModal> {
  late StatisticsFilterType _selectedFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.controller.currentFilter.value;
    _startDate = widget.controller.customStartDate.value;
    _endDate = widget.controller.customEndDate.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.filter_list_rounded, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'filter_by_period'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = StatisticsFilterType.weekly;
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  child: Text('reset'.tr),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter Options
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildFilterOption(StatisticsFilterType.daily, 'daily'.tr,
                      Icons.today_rounded),
                  _buildFilterOption(StatisticsFilterType.weekly, 'weekly'.tr,
                      Icons.view_week_rounded),
                  _buildFilterOption(StatisticsFilterType.monthly, 'monthly'.tr,
                      Icons.calendar_month_rounded),
                  _buildFilterOption(StatisticsFilterType.yearly, 'yearly'.tr,
                      Icons.calendar_today_rounded),
                  _buildFilterOption(StatisticsFilterType.all, 'all_time'.tr,
                      Icons.all_inclusive_rounded),
                  _buildFilterOption(StatisticsFilterType.custom,
                      'custom_range'.tr, Icons.date_range_rounded),
                  if (_selectedFilter == StatisticsFilterType.custom)
                    _buildDatePickers(),
                ],
              ),
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'apply'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
      StatisticsFilterType type, String label, IconData icon) {
    final isSelected = _selectedFilter == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withAlpha(26)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryColor, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryColor : Colors.grey,
                size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryColor : Colors.grey[800],
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildDatePickerRow(
            label: 'start_date'.tr,
            date: _startDate,
            onTap: () => _selectDate(isStart: true),
          ),
          const SizedBox(height: 8),
          _buildDatePickerRow(
            label: 'end_date'.tr,
            date: _endDate,
            onTap: () => _selectDate(isStart: false),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerRow({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const Spacer(),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'select'.tr,
              style: TextStyle(
                color: date != null ? Colors.black : Colors.grey,
                fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now().subtract(const Duration(days: 30)))
        : (_endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == StatisticsFilterType.custom) {
      if (_startDate == null || _endDate == null) {
        Get.snackbar(
          'error'.tr,
          'select_date_range'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    widget.controller.applyFilter(
      _selectedFilter,
      startDate: _startDate,
      endDate: _endDate,
    );
    Get.back();
  }
}

