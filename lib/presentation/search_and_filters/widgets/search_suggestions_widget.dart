import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchSuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final Function(String)? onSuggestionTap;

  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length > 5 ? 5 : suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppTheme.lightTheme.dividerColor,
        ),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            leading: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            title: Text(
              suggestion,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'north_west',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            onTap: () {
              if (onSuggestionTap != null) {
                onSuggestionTap!(suggestion);
              }
            },
          );
        },
      ),
    );
  }
}
