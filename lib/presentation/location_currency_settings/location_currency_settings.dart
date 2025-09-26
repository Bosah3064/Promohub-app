import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_currency_service.dart';
import '../../services/supabase_service.dart';
import './widgets/currency_preview_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/location_detection_widget.dart';

class LocationCurrencySettings extends StatefulWidget {
  const LocationCurrencySettings({super.key});

  @override
  State<LocationCurrencySettings> createState() =>
      _LocationCurrencySettingsState();
}

class _LocationCurrencySettingsState extends State<LocationCurrencySettings> {
  final LocationCurrencyService _locationService = LocationCurrencyService();
  String? _currentUserId;
  bool _isLoading = true;
  bool _isDetecting = false;

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _currencies = [];
  Map<String, dynamic>? _userPreferences;

  String? _selectedCountryCode;
  String? _selectedCurrencyId;
  String? _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // Fix: Use getter instead of method call
      _currentUserId = SupabaseService().currentUserId;

      // Fix: Use correct method name
      final results = await Future.wait([
        _locationService.getAllCountries(),
        _locationService.getAllCurrencies(),
        if (_currentUserId != null)
          _locationService.getUserPreferences(_currentUserId!)
        else
          Future.value(null),
      ]);

      setState(() {
        _countries = results[0] as List<Map<String, dynamic>>;
        _currencies = results[1] as List<Map<String, dynamic>>;
        _userPreferences =
            results.length > 2 ? results[2] as Map<String, dynamic>? : null;

        // Set initial values from user preferences
        if (_userPreferences != null) {
          _selectedCurrencyId = _userPreferences!['preferred_currency_id'];
          _selectedLanguage = _userPreferences!['language_code'] ?? 'en';

          if (_userPreferences!['preferred_location_id'] != null) {
            final location = _userPreferences!['preferred_location_id']
                as Map<String, dynamic>;
            _selectedCountryCode = location['country_code'];
          }
        }

        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load data: $error'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetecting = true);
    try {
      // Add location detection logic here
      await Future.delayed(Duration(seconds: 2)); // Placeholder
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to detect location: $error'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    } finally {
      setState(() => _isDetecting = false);
    }
  }

  Future<void> _savePreferences() async {
    if (_currentUserId == null) return;

    try {
      await _locationService.updateUserPreferences(_currentUserId!,
          currencyId: _selectedCurrencyId, languageCode: _selectedLanguage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Preferences saved successfully!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to save preferences: $error'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  String _getCurrencyName(String? currencyId) {
    if (currencyId == null) return 'Select Currency';

    final currency = _currencies.firstWhere((c) => c['id'] == currencyId,
        orElse: () => {'name': 'Unknown Currency', 'symbol': ''});

    return '${currency['name']} (${currency['symbol']})';
  }

  String _getCountryName(String? countryCode) {
    if (countryCode == null) return 'Select Country';

    final country = _countries.firstWhere(
        (c) => c['country_code'] == countryCode,
        orElse: () => {'country_name': 'Unknown Country'});

    return country['country_name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
            title: Text("Location & Currency Settings",
                style: AppTheme.lightTheme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24)),
            actions: [
              TextButton(
                  onPressed: _currentUserId != null ? _savePreferences : null,
                  child: Text('Save',
                      style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600))),
            ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(children: [
                SizedBox(height: 2.h),

                // Location Detection Widget
                LocationDetectionWidget(
                  isDetecting: _isDetecting,
                  onDetectLocation: _detectLocation,
                ),

                SizedBox(height: 3.h),

                // Currency Selection
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.lightTheme.dividerColor, width: 1)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Currency Preference',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          SizedBox(height: 2.h),
                          InkWell(
                              onTap: () => _showCurrencySelection(),
                              child: Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              AppTheme.lightTheme.dividerColor),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(children: [
                                    CustomIconWidget(
                                        iconName: 'attach_money',
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        size: 20),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                        child: Text(
                                            _getCurrencyName(
                                                _selectedCurrencyId),
                                            style: AppTheme.lightTheme.textTheme
                                                .bodyLarge)),
                                    CustomIconWidget(
                                        iconName: 'arrow_drop_down',
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                        size: 20),
                                  ]))),
                        ])),

                // Currency Preview Widget
                if (_selectedCurrencyId != null)
                  CurrencyPreviewWidget(
                    currencies: _currencies,
                    currencyCode: _selectedCurrencyId!,
                  ),

                SizedBox(height: 3.h),

                // Language Selector Widget
                LanguageSelectorWidget(
                    selectedLanguage: _selectedLanguage ?? 'en',
                    onLanguageChanged: (language) {
                      setState(() => _selectedLanguage = language);
                    }),

                SizedBox(height: 4.h),
              ])));
  }

  void _showCurrencySelection() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            height: 60.h,
            decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(children: [
              Container(
                  margin: EdgeInsets.symmetric(vertical: 1.h),
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                      color: AppTheme.lightTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Text("Select Currency",
                      style: AppTheme.lightTheme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600))),
              Expanded(
                  child: ListView.builder(
                      itemCount: _currencies.length,
                      itemBuilder: (context, index) {
                        final currency = _currencies[index];
                        final isSelected =
                            currency['id'] == _selectedCurrencyId;

                        return ListTile(
                            leading: CircleAvatar(
                                backgroundColor: AppTheme
                                    .lightTheme.colorScheme.primary
                                    .withAlpha(26),
                                child: Text(currency['symbol'] ?? '',
                                    style: TextStyle(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.bold))),
                            title: Text(currency['name'] ?? ''),
                            subtitle: Text(
                                '${currency['code']} - ${currency['symbol']}'),
                            trailing: isSelected
                                ? CustomIconWidget(
                                    iconName: 'check',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 20)
                                : null,
                            onTap: () {
                              setState(
                                  () => _selectedCurrencyId = currency['id']);
                              Navigator.pop(context);
                            });
                      })),
            ])));
  }
}
