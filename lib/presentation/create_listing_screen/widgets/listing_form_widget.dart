import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class ListingFormWidget extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final String selectedCondition;
  final String selectedLocation;
  final Function(String) onCategoryChanged;
  final Function(String) onConditionChanged;
  final Function(String) onLocationChanged;

  const ListingFormWidget({
    super.key,
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.categories,
    required this.selectedCategory,
    required this.selectedCondition,
    required this.selectedLocation,
    required this.onCategoryChanged,
    required this.onConditionChanged,
    required this.onLocationChanged,
  });

  @override
  State<ListingFormWidget> createState() => _ListingFormWidgetState();
}

class _ListingFormWidgetState extends State<ListingFormWidget> {
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Fair', 'Poor'];
  final List<String> _locations = [
    'Lagos, Nigeria',
    'Abuja, Nigeria',
    'Kano, Nigeria',
    'Ibadan, Nigeria',
    'Port Harcourt, Nigeria',
    'Benin City, Nigeria',
  ];

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Category',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.categories.length,
                  itemBuilder: (context, index) {
                    final category = widget.categories[index];
                    final isSelected =
                        widget.selectedCategory == category['name'];

                    return ListTile(
                      leading: CustomIconWidget(
                        iconName: category['icon'] as String,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      title: Text(
                        category['name'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        widget.onCategoryChanged(category['name'] as String);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Location',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    final isSelected = widget.selectedLocation == location;

                    return ListTile(
                      leading: CustomIconWidget(
                        iconName: 'location_on',
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      title: Text(
                        location,
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        widget.onLocationChanged(location);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Listing Details',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 24),

          // Title field
          Text(
            'Title *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: widget.titleController,
            decoration: InputDecoration(
              hintText: 'What are you selling?',
              counterText: '${widget.titleController.text.length}/80',
            ),
            maxLength: 80,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 24),

          // Category field
          Text(
            'Category *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _showCategoryPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: Row(
                children: [
                  if (widget.selectedCategory.isNotEmpty) ...[
                    CustomIconWidget(
                      iconName: widget.categories.firstWhere((cat) =>
                              cat['name'] == widget.selectedCategory)['icon']
                          as String,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.selectedCategory.isEmpty
                          ? 'Select a category'
                          : widget.selectedCategory,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: widget.selectedCategory.isEmpty
                            ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Condition chips
          Text(
            'Condition *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _conditions.map((condition) {
              final isSelected = widget.selectedCondition == condition;
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    widget.onConditionChanged(condition);
                  }
                },
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24),

          // Price field
          Text(
            'Price *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: widget.priceController,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '₦ ',
              prefixStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 24),

          // Description field
          Text(
            'Description',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: widget.descriptionController,
            decoration: InputDecoration(
              hintText: 'Describe your item in detail...',
              counterText: '${widget.descriptionController.text.length}/500',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 24),

          // Location field
          Text(
            'Location *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _showLocationPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.selectedLocation,
                      style: AppTheme.lightTheme.textTheme.bodyLarge,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Form tips
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'tips_and_updates',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Listing Tips',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildTip('Use a clear, descriptive title'),
                _buildTip('Be honest about the condition'),
                _buildTip('Research similar items for pricing'),
                _buildTip('Include all relevant details'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
