import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isVoiceSearchActive;
  final List<String> recentSearches;
  final VoidCallback onVoiceSearch;
  final VoidCallback onBarcodeSearch;
  final VoidCallback onFilterToggle;
  final bool isFilterActive;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isVoiceSearchActive,
    required this.recentSearches,
    required this.onVoiceSearch,
    required this.onBarcodeSearch,
    required this.onFilterToggle,
    required this.isFilterActive,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  bool _showSuggestions = false;
  late AnimationController _voiceAnimationController;
  late Animation<double> _voiceAnimation;

  final List<String> _categorySuggestions = [
    "Electronics",
    "Vehicles",
    "Real Estate",
    "Fashion",
    "Services",
    "Jobs",
  ];

  @override
  void initState() {
    super.initState();
    _voiceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _voiceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _voiceAnimationController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(() {
      setState(() {
        _showSuggestions =
            widget.focusNode.hasFocus && widget.controller.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _voiceAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVoiceSearchActive && !oldWidget.isVoiceSearchActive) {
      _voiceAnimationController.repeat(reverse: true);
    } else if (!widget.isVoiceSearchActive && oldWidget.isVoiceSearchActive) {
      _voiceAnimationController.stop();
      _voiceAnimationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(
              color: widget.focusNode.hasFocus
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              width: widget.focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search for products, services...',
                    hintStyle:
                        AppTheme.lightTheme.inputDecorationTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.sp,
                      vertical: 12.sp,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.sp),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                  onChanged: (value) {
                    setState(() {
                      _showSuggestions =
                          value.isEmpty && widget.focusNode.hasFocus;
                    });
                  },
                ),
              ),

              // Voice Search Button
              AnimatedBuilder(
                animation: _voiceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isVoiceSearchActive
                        ? _voiceAnimation.value
                        : 1.0,
                    child: IconButton(
                      onPressed: widget.onVoiceSearch,
                      icon: CustomIconWidget(
                        iconName:
                            widget.isVoiceSearchActive ? 'mic' : 'mic_none',
                        color: widget.isVoiceSearchActive
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                    ),
                  );
                },
              ),

              // Barcode Scanner Button
              IconButton(
                onPressed: widget.onBarcodeSearch,
                icon: CustomIconWidget(
                  iconName: 'qr_code_scanner',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
              ),

              // Filter Toggle Button
              Container(
                margin: EdgeInsets.only(right: 8.sp),
                child: IconButton(
                  onPressed: widget.onFilterToggle,
                  icon: Stack(
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: widget.isFilterActive
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                      if (widget.isFilterActive)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8.sp,
                            height: 8.sp,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Suggestions Dropdown
        if (_showSuggestions)
          Container(
            margin: EdgeInsets.only(top: 8.sp),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.sp),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.recentSearches.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Text(
                      'Recent Searches',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                  ),
                  ...widget.recentSearches.take(3).map(
                        (search) => ListTile(
                          leading: CustomIconWidget(
                            iconName: 'history',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 18.sp,
                          ),
                          title: Text(
                            search,
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                          onTap: () {
                            widget.controller.text = search;
                            widget.focusNode.unfocus();
                          },
                        ),
                      ),
                  Divider(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    height: 1,
                  ),
                ],
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Text(
                    'Browse Categories',
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),
                ),
                ..._categorySuggestions.map(
                  (category) => ListTile(
                    leading: CustomIconWidget(
                      iconName: 'category',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 18.sp,
                    ),
                    title: Text(
                      category,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      widget.controller.text = category;
                      widget.focusNode.unfocus();
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
