import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PriceRangeFilterWidget extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final double currentMinPrice;
  final double currentMaxPrice;
  final Function(double, double)? onPriceRangeChanged;

  const PriceRangeFilterWidget({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.currentMinPrice,
    required this.currentMaxPrice,
    this.onPriceRangeChanged,
  });

  @override
  State<PriceRangeFilterWidget> createState() => _PriceRangeFilterWidgetState();
}

class _PriceRangeFilterWidgetState extends State<PriceRangeFilterWidget> {
  late RangeValues _currentRangeValues;
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _currentRangeValues =
        RangeValues(widget.currentMinPrice, widget.currentMaxPrice);
    _minController =
        TextEditingController(text: widget.currentMinPrice.toInt().toString());
    _maxController =
        TextEditingController(text: widget.currentMaxPrice.toInt().toString());
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set your price range',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Min Price',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: AppTheme.lightTheme.textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                    ),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    onChanged: (value) {
                      final minValue =
                          double.tryParse(value) ?? widget.minPrice;
                      if (minValue >= widget.minPrice &&
                          minValue <= _currentRangeValues.end) {
                        setState(() {
                          _currentRangeValues =
                              RangeValues(minValue, _currentRangeValues.end);
                        });
                        _notifyPriceChange();
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Max Price',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: AppTheme.lightTheme.textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                    ),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    onChanged: (value) {
                      final maxValue =
                          double.tryParse(value) ?? widget.maxPrice;
                      if (maxValue <= widget.maxPrice &&
                          maxValue >= _currentRangeValues.start) {
                        setState(() {
                          _currentRangeValues =
                              RangeValues(_currentRangeValues.start, maxValue);
                        });
                        _notifyPriceChange();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
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
          child: RangeSlider(
            values: _currentRangeValues,
            min: widget.minPrice,
            max: widget.maxPrice,
            divisions: ((widget.maxPrice - widget.minPrice) / 10).round(),
            labels: RangeLabels(
              '\$${_currentRangeValues.start.round()}',
              '\$${_currentRangeValues.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
                _minController.text = values.start.round().toString();
                _maxController.text = values.end.round().toString();
              });
            },
            onChangeEnd: (RangeValues values) {
              _notifyPriceChange();
            },
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${widget.minPrice.round()}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '\$${widget.maxPrice.round()}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _notifyPriceChange() {
    if (widget.onPriceRangeChanged != null) {
      widget.onPriceRangeChanged!(
          _currentRangeValues.start, _currentRangeValues.end);
    }
  }
}
