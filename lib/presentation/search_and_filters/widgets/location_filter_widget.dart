import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationFilterWidget extends StatefulWidget {
  final String? selectedLocation;
  final double selectedRadius;
  final Function(String?)? onLocationChanged;
  final Function(double)? onRadiusChanged;

  const LocationFilterWidget({
    super.key,
    this.selectedLocation,
    required this.selectedRadius,
    this.onLocationChanged,
    this.onRadiusChanged,
  });

  @override
  State<LocationFilterWidget> createState() => _LocationFilterWidgetState();
}

class _LocationFilterWidgetState extends State<LocationFilterWidget> {
  late TextEditingController _locationController;
  late double _currentRadius;

  final List<Map<String, dynamic>> _popularLocations = [
    {'name': 'Lagos, Nigeria', 'icon': 'location_city'},
    {'name': 'Nairobi, Kenya', 'icon': 'location_city'},
    {'name': 'Accra, Ghana', 'icon': 'location_city'},
    {'name': 'Cape Town, South Africa', 'icon': 'location_city'},
    {'name': 'Abuja, Nigeria', 'icon': 'location_city'},
    {'name': 'Kampala, Uganda', 'icon': 'location_city'},
  ];

  @override
  void initState() {
    super.initState();
    _locationController =
        TextEditingController(text: widget.selectedLocation ?? '');
    _currentRadius = widget.selectedRadius;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose location and search radius',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Enter location',
            hintText: 'City, State, Country',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'my_location',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _openMapPicker,
                  child: Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: CustomIconWidget(
                      iconName: 'map',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          onChanged: (value) {
            if (widget.onLocationChanged != null) {
              widget.onLocationChanged!(value.isEmpty ? null : value);
            }
          },
        ),
        SizedBox(height: 2.h),
        Text(
          'Popular Locations',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _popularLocations
              .map((location) => _buildLocationChip(location))
              .toList(),
        ),
        SizedBox(height: 3.h),
        Text(
          'Search Radius: ${_currentRadius.round()} km',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
            inactiveTrackColor: AppTheme.lightTheme.colorScheme.outline,
            thumbColor: AppTheme.lightTheme.colorScheme.primary,
            overlayColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: _currentRadius,
            min: 1.0,
            max: 100.0,
            divisions: 99,
            label: '${_currentRadius.round()} km',
            onChanged: (double value) {
              setState(() {
                _currentRadius = value;
              });
            },
            onChangeEnd: (double value) {
              if (widget.onRadiusChanged != null) {
                widget.onRadiusChanged!(value);
              }
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1 km',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '100 km',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationChip(Map<String, dynamic> location) {
    final locationName = location['name'] as String;
    final isSelected = _locationController.text == locationName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _locationController.text = locationName;
        });
        if (widget.onLocationChanged != null) {
          widget.onLocationChanged!(locationName);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: location['icon'] as String,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              locationName,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getCurrentLocation() {
    // Simulate getting current location
    setState(() {
      _locationController.text = 'Current Location';
    });
    if (widget.onLocationChanged != null) {
      widget.onLocationChanged!('Current Location');
    }
  }

  void _openMapPicker() {
    // Simulate opening map picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Map Picker'),
        content: Text('Map picker would open here to select location on map.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
