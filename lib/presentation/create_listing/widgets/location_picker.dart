import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class LocationPicker extends StatefulWidget {
  final String? selectedLocation;
  final Function(String) onLocationChanged;

  const LocationPicker({
    super.key,
    this.selectedLocation,
    required this.onLocationChanged,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  List<Map<String, dynamic>> countries = [];
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  bool _useCurrentLocation = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountriesFromJson();
  }

  Future<void> _loadCountriesFromJson() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/data/countries+states+cities.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      setState(() {
        countries = jsonData.map<Map<String, dynamic>>((country) {
          return {
            'name': country['name'],
            'states':
                (country['states'] as List).map<Map<String, dynamic>>((state) {
              return {
                'name': state['name'],
                'cities': (state['cities'] as List)
                    .map<String>((city) => city['name'].toString())
                    .toList(),
              };
            }).toList(),
          };
        }).toList();

        _isLoading = false;
        _parseSelectedLocation();
      });
    } catch (e) {
      print('Error loading location data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseSelectedLocation() {
    if (widget.selectedLocation != null &&
        widget.selectedLocation!.isNotEmpty) {
      final parts = widget.selectedLocation!.split(', ');
      if (parts.length >= 3) {
        _selectedCity = parts[0];
        _selectedState = parts[1];
        _selectedCountry = parts[2];
      }
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      width: 10.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Select Location',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                    SizedBox(height: 2.h),
                    _buildCurrentLocationTile(),
                    SizedBox(height: 3.h),
                    Divider(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                    SizedBox(height: 2.h),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: countries.length,
                        separatorBuilder: (context, index) => Divider(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                        ),
                        itemBuilder: (context, index) {
                          final country = countries[index];
                          final isSelected =
                              _selectedCountry == country['name'];

                          return ExpansionTile(
                            leading: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.lightTheme.primaryColor
                                        .withValues(alpha: 0.1)
                                    : AppTheme.lightTheme.colorScheme.surface
                                        .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomIconWidget(
                                iconName: 'location_on',
                                color: isSelected
                                    ? AppTheme.lightTheme.primaryColor
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              country['name'],
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: isSelected
                                    ? AppTheme.lightTheme.primaryColor
                                    : AppTheme.lightTheme.textTheme.titleMedium
                                        ?.color,
                              ),
                            ),
                            children: (country['states'] as List)
                                .map<Widget>((state) {
                              return ExpansionTile(
                                title: Text(
                                  state['name'],
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyLarge,
                                ),
                                children: (state['cities'] as List)
                                    .map<Widget>((city) {
                                  final isSelectedCity = _selectedCity == city;
                                  return ListTile(
                                    title: Text(
                                      city,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: isSelectedCity
                                            ? AppTheme.lightTheme.primaryColor
                                            : AppTheme.lightTheme.textTheme
                                                .bodyMedium?.color,
                                      ),
                                    ),
                                    trailing: isSelectedCity
                                        ? CustomIconWidget(
                                            iconName: 'check',
                                            color: AppTheme
                                                .lightTheme.primaryColor,
                                            size: 20,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedCountry = country['name'];
                                        _selectedState = state['name'];
                                        _selectedCity = city;
                                        _useCurrentLocation = false;
                                      });
                                      final location =
                                          '$city, ${state['name']}, ${country['name']}';
                                      widget.onLocationChanged(location);
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationTile() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'my_location',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use Current Location',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
                Text(
                  'Automatically detect your location',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _useCurrentLocation,
            onChanged: (value) {
              setState(() {
                _useCurrentLocation = value;
                if (value) {
                  widget.onLocationChanged('Current Location');
                  Navigator.pop(context);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showLocationPicker,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  widget.selectedLocation != null &&
                          widget.selectedLocation!.isNotEmpty
                      ? Text(
                          widget.selectedLocation!,
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          'Select location',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
