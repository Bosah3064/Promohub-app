import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SavedSearchCard extends StatefulWidget {
  final Map<String, dynamic> search;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onNotificationToggle;

  const SavedSearchCard({
    super.key,
    required this.search,
    required this.onEdit,
    required this.onDelete,
    required this.onNotificationToggle,
  });

  @override
  State<SavedSearchCard> createState() => _SavedSearchCardState();
}

class _SavedSearchCardState extends State<SavedSearchCard> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled =
        widget.search['notificationsEnabled'] as bool? ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final int resultCount = widget.search['resultCount'] as int? ?? 0;
    final bool hasNewResults = widget.search['hasNewResults'] as bool? ?? false;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and notification badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.search['title'] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasNewResults)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'New',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),

            // Search criteria
            _buildSearchCriteria(),
            SizedBox(height: 2.h),

            // Result count and last updated
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  '$resultCount results',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Updated ${widget.search['lastUpdated']}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Actions row
            Row(
              children: [
                // Notification toggle
                Row(
                  children: [
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        widget.onNotificationToggle(value);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Notifications',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Edit button
                TextButton.icon(
                  onPressed: widget.onEdit,
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 4.w,
                  ),
                  label: Text(
                    'Edit',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 2.w),

                // Delete button
                IconButton(
                  onPressed: widget.onDelete,
                  icon: CustomIconWidget(
                    iconName: 'delete_outline',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 5.w,
                  ),
                  padding: EdgeInsets.all(2.w),
                  constraints: BoxConstraints(
                    minWidth: 8.w,
                    minHeight: 8.w,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCriteria() {
    final List<String> criteria = [];

    if (widget.search['category'] != null &&
        (widget.search['category'] as String).isNotEmpty) {
      criteria.add('Category: ${widget.search['category']}');
    }

    if (widget.search['location'] != null &&
        (widget.search['location'] as String).isNotEmpty) {
      criteria.add('Location: ${widget.search['location']}');
    }

    if (widget.search['priceRange'] != null &&
        (widget.search['priceRange'] as String).isNotEmpty) {
      criteria.add('Price: ${widget.search['priceRange']}');
    }

    if (widget.search['keywords'] != null &&
        (widget.search['keywords'] as String).isNotEmpty) {
      criteria.add('Keywords: ${widget.search['keywords']}');
    }

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: criteria.map((criterion) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            criterion,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
