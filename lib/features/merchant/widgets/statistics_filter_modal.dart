import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_statistics_controller.dart';
import '../../../core/services/toast_service.dart';

class StatisticsFilterModal extends StatefulWidget {
  final MerchantStatisticsController controller;

  const StatisticsFilterModal({Key? key, required this.controller})
      : super(key: key);

  @override
  State<StatisticsFilterModal> createState() => _StatisticsFilterModalState();
}

class _StatisticsFilterModalState extends State<StatisticsFilterModal> {
  late StatisticsFilterType _selectedFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.controller.selectedFilter.value;
    _startDate = widget.controller.customStartDate.value;
    _endDate = widget.controller.customEndDate.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(height: 1),
          _buildFilterOptions(),
          if (_selectedFilter == StatisticsFilterType.custom)
            _buildDatePickers(),
          const SizedBox(height: 16),
          _buildButtons(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: StatisticsFilterType.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          return _buildFilterOption(
            filter: filter,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedFilter = filter),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterOption({
    required StatisticsFilterType filter,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withAlpha(26)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getFilterIcon(filter),
              color: isSelected ? AppColors.primaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              widget.controller.getFilterName(filter),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  IconData _getFilterIcon(StatisticsFilterType filter) {
    switch (filter) {
      case StatisticsFilterType.daily:
        return Icons.today;
      case StatisticsFilterType.weekly:
        return Icons.view_week;
      case StatisticsFilterType.monthly:
        return Icons.calendar_month;
      case StatisticsFilterType.yearly:
        return Icons.calendar_today;
      case StatisticsFilterType.custom:
        return Icons.date_range;
      case StatisticsFilterType.all:
        return Icons.all_inclusive;
    }
  }

  Widget _buildDatePickers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Spacer(),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'select'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: date != null ? Colors.grey[800] : AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
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
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _startDate!.isAfter(picked)) {
            _startDate = picked;
          }
        }
      });
    }
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                widget.controller.resetFilter();
                Get.back();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('reset'.tr),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('apply'.tr),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    if (_selectedFilter == StatisticsFilterType.custom) {
      if (_startDate == null || _endDate == null) {
        ToastService.showError('select_date_range'.tr);
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
