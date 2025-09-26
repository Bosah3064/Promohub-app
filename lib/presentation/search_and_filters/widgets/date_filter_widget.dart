import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DateFilterWidget extends StatefulWidget {
  final String? selectedDateRange;
  final Function(String?)? onDateRangeChanged;

  const DateFilterWidget({
    super.key,
    this.selectedDateRange,
    this.onDateRangeChanged,
  });

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  final List<Map<String, dynamic>> _dateRanges = [
    {
      'name': 'Today',
      'description': 'Posted today',
      'icon': 'today',
    },
    {
      'name': 'This Week',
      'description': 'Posted in the last 7 days',
      'icon': 'date_range',
    },
    {
      'name': 'This Month',
      'description': 'Posted in the last 30 days',
      'icon': 'calendar_month',
    },
    {
      'name': 'Last 3 Months',
      'description': 'Posted in the last 90 days',
      'icon': 'calendar_view_month',
    },
    {
      'name': 'Last 6 Months',
      'description': 'Posted in the last 180 days',
      'icon': 'event',
    },
    {
      'name': 'Custom Range',
      'description': 'Choose specific dates',
      'icon': 'edit_calendar',
    },
  ];

  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When was the item posted?',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        ..._dateRanges.map((dateRange) => _buildDateRangeItem(dateRange)),
        if (widget.selectedDateRange == 'Custom Range' &&
            _customDateRange != null)
          _buildCustomDateRangeDisplay(),
      ],
    );
  }

  Widget _buildDateRangeItem(Map<String, dynamic> dateRange) {
    final rangeName = dateRange['name'] as String;
    final description = dateRange['description'] as String;
    final icon = dateRange['icon'] as String;
    final isSelected = widget.selectedDateRange == rangeName;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: RadioListTile<String>(
        value: rangeName,
        groupValue: widget.selectedDateRange,
        onChanged: (String? value) {
          if (value == 'Custom Range') {
            _showCustomDatePicker();
          } else {
            if (widget.onDateRangeChanged != null) {
              widget.onDateRangeChanged!(value);
            }
          }
        },
        title: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rangeName,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
        activeColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  Widget _buildCustomDateRangeDisplay() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.secondary,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'date_range',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Date Range',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_formatDate(_customDateRange!.start)} - ${_formatDate(_customDateRange!.end)}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showCustomDatePicker,
            child: CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
      });
      if (widget.onDateRangeChanged != null) {
        widget.onDateRangeChanged!('Custom Range');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
