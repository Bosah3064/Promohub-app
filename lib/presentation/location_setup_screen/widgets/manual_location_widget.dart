import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ManualLocationWidget extends StatelessWidget {
  final List<Map<String, dynamic>> countries;
  final List<String> regions;
  final List<String> cities;
  final String? selectedCountry;
  final String? selectedRegion;
  final String? selectedCity;
  final Function(String?) onCountryChanged;
  final Function(String?) onRegionChanged;
  final Function(String?) onCityChanged;

  const ManualLocationWidget({
    super.key,
    required this.countries,
    required this.regions,
    required this.cities,
    this.selectedCountry,
    this.selectedRegion,
    this.selectedCity,
    required this.onCountryChanged,
    required this.onRegionChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'edit_location',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Manual Location Selection',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Country dropdown
          _buildDropdownField(
            label: 'Country',
            value: selectedCountry,
            items:
                countries.map((country) => country["name"] as String).toList(),
            onChanged: onCountryChanged,
            hint: 'Select your country',
            icon: 'public',
          ),

          SizedBox(height: 2.h),

          // Region dropdown
          _buildDropdownField(
            label: 'Region/State',
            value: selectedRegion,
            items: regions,
            onChanged: selectedCountry != null ? onRegionChanged : null,
            hint: selectedCountry != null
                ? 'Select your region'
                : 'Select country first',
            icon: 'map',
            enabled: selectedCountry != null,
          ),

          SizedBox(height: 2.h),

          // City dropdown with search
          _buildCitySearchField(),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
    required String hint,
    required String icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.lightTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Row(
                children: [
                  CustomIconWidget(
                    iconName: icon,
                    color: enabled
                        ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        : AppTheme.lightTheme.colorScheme.outline,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    hint,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: enabled
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              items: enabled
                  ? items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList()
                  : null,
              onChanged: enabled ? onChanged : null,
              icon: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: enabled
                    ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    : AppTheme.lightTheme.colorScheme.outline,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCitySearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: selectedRegion != null
                ? AppTheme.lightTheme.scaffoldBackgroundColor
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCity,
            decoration: InputDecoration(
              hintText: selectedRegion != null
                  ? 'Select your city'
                  : 'Select region first',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'location_city',
                  color: selectedRegion != null
                      ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      : AppTheme.lightTheme.colorScheme.outline,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            ),
            items: selectedRegion != null
                ? cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(
                        city,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    );
                  }).toList()
                : null,
            onChanged: selectedRegion != null ? onCityChanged : null,
            icon: CustomIconWidget(
              iconName: 'keyboard_arrow_down',
              color: selectedRegion != null
                  ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  : AppTheme.lightTheme.colorScheme.outline,
              size: 20,
            ),
          ),
        ),
        if (selectedCity != null) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Location set to $selectedCity, $selectedRegion',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
