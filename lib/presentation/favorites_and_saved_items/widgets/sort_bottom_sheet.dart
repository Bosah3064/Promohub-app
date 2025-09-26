import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheet extends StatefulWidget {
  final String currentSortOption;
  final Function(String) onSortChanged;

  const SortBottomSheet({
    super.key,
    required this.currentSortOption,
    required this.onSortChanged,
  });

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late String _selectedOption;

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'value': 'recently_saved',
      'title': 'Recently Saved',
      'subtitle': 'Most recently added items first',
      'icon': 'access_time',
    },
    {
      'value': 'price_low_high',
      'title': 'Price: Low to High',
      'subtitle': 'Cheapest items first',
      'icon': 'trending_up',
    },
    {
      'value': 'price_high_low',
      'title': 'Price: High to Low',
      'subtitle': 'Most expensive items first',
      'icon': 'trending_down',
    },
    {
      'value': 'distance',
      'title': 'Distance',
      'subtitle': 'Nearest items first',
      'icon': 'location_on',
    },
    {
      'value': 'date_posted',
      'title': 'Date Posted',
      'subtitle': 'Newest listings first',
      'icon': 'calendar_today',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Text(
                  'Sort by',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.onSortChanged(_selectedOption);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Apply',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sort options
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sortOptions.length,
            itemBuilder: (context, index) {
              final option = _sortOptions[index];
              final isSelected = _selectedOption == option['value'];

              return ListTile(
                leading: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: option['icon'] as String,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                ),
                title: Text(
                  option['title'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  option['subtitle'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                trailing: isSelected
                    ? CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedOption = option['value'] as String;
                  });
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              );
            },
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
