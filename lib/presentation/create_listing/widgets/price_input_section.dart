import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';

class PriceInputSection extends StatefulWidget {
  final String? price;
  final String selectedCurrency;
  final Function(String) onPriceChanged;
  final Function(String) onCurrencyChanged;
  final String? category;

  const PriceInputSection({
    super.key,
    this.price,
    required this.selectedCurrency,
    required this.onPriceChanged,
    required this.onCurrencyChanged,
    this.category,
  });

  @override
  State<PriceInputSection> createState() => _PriceInputSectionState();
}

class _PriceInputSectionState extends State<PriceInputSection> {
  final TextEditingController _priceController = TextEditingController();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.price ?? '';
    _detectDeviceCurrency();
  }

  Future<void> _detectDeviceCurrency() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final countryCode = placemarks.first.isoCountryCode ?? 'US';
        final currency =
            NumberFormat.simpleCurrency(locale: 'en_$countryCode').currencyName;
        if (currency != null) {
          widget.onCurrencyChanged(currency);
        }
      }
    } catch (e) {
      print("Currency detection error: $e");
    }
  }

  String _getCurrencySymbol() {
    try {
      return NumberFormat.simpleCurrency(name: widget.selectedCurrency)
          .currencySymbol;
    } catch (_) {
      return widget.selectedCurrency;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'attach_money',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Price',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _showSuggestions = !_showSuggestions),
                icon: CustomIconWidget(
                  iconName: _showSuggestions ? 'expand_less' : 'expand_more',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                label: Text(
                  'AI Suggestions',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              GestureDetector(
                onTap: () {}, // Currency picker disabled
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCurrencySymbol(),
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  ),
                  onChanged: widget.onPriceChanged,
                ),
              ),
            ],
          ),
          if (_showSuggestions) ...[
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Price Suggestions',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  ...priceSuggestions.map((suggestion) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            Container(
                              width: 1.w,
                              height: 1.w,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion['range'],
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    suggestion['description'],
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Set a competitive price to attract more buyers',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> priceSuggestions = [
    {'range': '₦5,000 - ₦15,000', 'description': 'Similar phones in your area'},
    {
      'range': '₦12,000 - ₦18,000',
      'description': 'Based on condition and model'
    },
    {
      'range': '₦8,000 - ₦25,000',
      'description': 'Market average for this category'
    },
  ];
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final newText = newValue.text.replaceAll(',', '');
    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      final remaining = newText.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
