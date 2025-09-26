import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryFilterWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final List<String> selectedCategories;
  final Function(List<String>)? onCategoriesChanged;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategories,
    this.onCategoriesChanged,
  });

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  String? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select categories to filter your search',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        ...widget.categories.map((category) => _buildCategoryItem(category)),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final categoryName = category['name'] as String;
    final subcategories =
        (category['subcategories'] as List?)?.cast<String>() ?? [];
    final isSelected = widget.selectedCategories.contains(categoryName);
    final isExpanded = _expandedCategory == categoryName;

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
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _toggleCategory(categoryName);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: category['icon'] as String,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      categoryName,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (subcategories.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedCategory = isExpanded ? null : categoryName;
                        });
                      },
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: CustomIconWidget(
                          iconName: 'keyboard_arrow_down',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && subcategories.isNotEmpty)
            Container(
              padding: EdgeInsets.only(left: 8.w, right: 3.w, bottom: 1.h),
              child: Column(
                children: subcategories
                    .map((subcategory) =>
                        _buildSubcategoryItem(subcategory, categoryName))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryItem(String subcategory, String parentCategory) {
    final fullCategoryPath = '$parentCategory > $subcategory';
    final isSelected = widget.selectedCategories.contains(fullCategoryPath);

    return GestureDetector(
      onTap: () {
        _toggleCategory(fullCategoryPath);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 0.5.h),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.secondary
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'subdirectory_arrow_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                subcategory,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCategory(String category) {
    final updatedCategories = List<String>.from(widget.selectedCategories);

    if (updatedCategories.contains(category)) {
      updatedCategories.remove(category);
    } else {
      updatedCategories.add(category);
    }

    if (widget.onCategoriesChanged != null) {
      widget.onCategoriesChanged!(updatedCategories);
    }
  }
}
