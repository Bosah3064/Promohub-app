import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheetWidget extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortSelected;

  const SortBottomSheetWidget({
    super.key,
    required this.selectedSort,
    required this.onSortSelected,
  });

  final List<Map<String, dynamic>> _sortOptions = const [
    {
      "label": "Relevance",
      "icon": "star",
      "description": "Best match for your search"
    },
    {
      "label": "Price: Low to High",
      "icon": "trending_up",
      "description": "Cheapest first"
    },
    {
      "label": "Price: High to Low",
      "icon": "trending_down",
      "description": "Most expensive first"
    },
    {
      "label": "Newest First",
      "icon": "schedule",
      "description": "Recently posted items"
    },
    {
      "label": "Distance",
      "icon": "near_me",
      "description": "Closest to your location"
    },
    {
      "label": "Most Popular",
      "icon": "favorite",
      "description": "Most viewed and liked"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.sp),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.sp),
            width: 40.sp,
            height: 4.sp,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.sp),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort Results',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          // Sort Options
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20.sp),
              itemCount: _sortOptions.length,
              separatorBuilder: (context, index) => Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final option = _sortOptions[index];
                final isSelected = selectedSort == option['label'];

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.sp),
                  leading: Container(
                    padding: EdgeInsets.all(8.sp),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primaryContainer
                          : AppTheme
                              .lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: CustomIconWidget(
                      iconName: option['icon'] as String,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    option['label'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    option['description'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24.sp,
                        )
                      : null,
                  onTap: () {
                    onSortSelected(option['label'] as String);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          // Bottom Padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20.sp),
        ],
      ),
    );
  }
}
