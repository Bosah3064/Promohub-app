import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/current_location_card_widget.dart';
import './widgets/distance_preference_widget.dart';
import './widgets/location_actions_widget.dart';
import './widgets/location_header_widget.dart';
import './widgets/manual_location_widget.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  bool _isUsingCurrentLocation = false;
  bool _isLocationPermissionGranted = false;
  bool _showManualSelection = false;
  bool _isLoadingLocation = false;
  double _selectedDistance = 10.0;
  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedCity;

  List<Map<String, dynamic>> _allCountries = [];
  bool _isLocationDataLoading = true;

  // Mock location data
  final Map<String, dynamic> _currentLocationData = {
    "latitude": 6.5244,
    "longitude": 3.3792,
    "city": "Lagos",
    "region": "Lagos State",
    "country": "Nigeria",
    "landmark": "Victoria Island"
  };

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/countries+states+cities.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _allCountries = List<Map<String, dynamic>>.from(jsonData);
      _isLocationDataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocationDataLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final countryList = _allCountries
        .map((c) => {"name": c["name"], "code": c["iso2"]})
        .toList();

    final regionList = _getRegionsForCountry(_selectedCountry);
    final cityList = _getCitiesForRegion(_selectedCountry, _selectedRegion);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    LocationHeaderWidget(),
                    SizedBox(height: 3.h),
                    if (_isUsingCurrentLocation || _isLocationPermissionGranted)
                      CurrentLocationCardWidget(
                        locationData: _currentLocationData,
                        isLoading: _isLoadingLocation,
                      ),
                    SizedBox(height: 2.h),
                    if (!_isUsingCurrentLocation)
                      _buildUseCurrentLocationButton(),
                    SizedBox(height: 2.h),
                    _buildManualSelectionToggle(),
                    if (_showManualSelection) ...[
                      SizedBox(height: 2.h),
                      ManualLocationWidget(
                        countries: countryList,
                        regions: regionList,
                        cities: cityList,
                        selectedCountry: _selectedCountry,
                        selectedRegion: _selectedRegion,
                        selectedCity: _selectedCity,
                        onCountryChanged: (country) {
                          setState(() {
                            _selectedCountry = country;
                            _selectedRegion = null;
                            _selectedCity = null;
                          });
                        },
                        onRegionChanged: (region) {
                          setState(() {
                            _selectedRegion = region;
                            _selectedCity = null;
                          });
                        },
                        onCityChanged: (city) {
                          setState(() {
                            _selectedCity = city;
                          });
                        },
                      ),
                    ],
                    SizedBox(height: 3.h),
                    DistancePreferenceWidget(
                      selectedDistance: _selectedDistance,
                      onDistanceChanged: (distance) {
                        setState(() {
                          _selectedDistance = distance;
                        });
                      },
                    ),
                    SizedBox(height: 3.h),
                    _buildPrivacyNotice(),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
            LocationActionsWidget(
              canContinue: _isUsingCurrentLocation ||
                  (_selectedCountry != null &&
                      _selectedRegion != null &&
                      _selectedCity != null),
              onSkip: _handleSkip,
              onContinue: _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      height: 4,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildUseCurrentLocationButton() {
    return Container(
      width: double.infinity,
      height: 14.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleUseCurrentLocation,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'my_location',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 32,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Use Current Location',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Get personalized listings near you',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualSelectionToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showManualSelection = !_showManualSelection;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: _showManualSelection
                  ? 'keyboard_arrow_up'
                  : 'keyboard_arrow_down',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Or select location manually',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
                iconName: 'privacy_tip',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Privacy Notice',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Your location is used to show relevant nearby listings and improve your marketplace experience. We never share your exact location with other users.',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () {
              // Navigate to privacy policy
            },
            child: Text(
              'View Privacy Policy',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUseCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoadingLocation = false;
      _isLocationPermissionGranted = true;
      _isUsingCurrentLocation = true;
      _showManualSelection = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Location set to ${_currentLocationData["city"]}, ${_currentLocationData["region"]}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _handleSkip() {
    Navigator.pushNamed(context, '/home-screen');
  }

  void _handleContinue() {
    if (_isUsingCurrentLocation ||
        (_selectedCountry != null &&
            _selectedRegion != null &&
            _selectedCity != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location preferences saved successfully!'),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        ),
      );
      Navigator.pushNamed(context, '/home-screen');
    }
  }

  List<String> _getRegionsForCountry(String? countryName) {
    if (countryName == null) return [];
    final country = _allCountries.firstWhere(
      (c) => c['name'] == countryName,
      orElse: () => {},
    );
    return (country['states'] as List?)
            ?.map<String>((s) => s['name'] as String)
            .toList() ??
        [];
  }

  List<String> _getCitiesForRegion(String? countryName, String? regionName) {
    if (countryName == null || regionName == null) return [];
    final country = _allCountries.firstWhere(
      (c) => c['name'] == countryName,
      orElse: () => {},
    );
    final state = (country['states'] as List?)?.firstWhere(
      (s) => s['name'] == regionName,
      orElse: () => {},
    );
    return (state['cities'] as List?)
            ?.map<String>((c) => c.toString())
            .toList() ??
        [];
  }
}
