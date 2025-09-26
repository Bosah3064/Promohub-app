import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onVoiceSearch;
  final VoidCallback? onBarcodeSearch;
  final VoidCallback? onImageSearch;
  final Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchInputWidget({
    super.key,
    required this.controller,
    this.onVoiceSearch,
    this.onBarcodeSearch,
    this.onImageSearch,
    this.onChanged,
    this.onClear,
  });

  @override
  State<SearchInputWidget> createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _showClearButton = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
    }
    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for products, services...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 2.h,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              onChanged: widget.onChanged,
            ),
          ),
          if (_showClearButton)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                if (widget.onClear != null) {
                  widget.onClear!();
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
          Container(
            width: 1,
            height: 4.h,
            color: AppTheme.lightTheme.dividerColor,
            margin: EdgeInsets.symmetric(horizontal: 1.w),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: widget.onVoiceSearch,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: CustomIconWidget(
                    iconName: 'mic',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onBarcodeSearch,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: CustomIconWidget(
                    iconName: 'qr_code_scanner',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onImageSearch,
                child: Padding(
                  padding: EdgeInsets.only(left: 2.w, right: 4.w),
                  child: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
