import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/apply_filters_widget.dart';
import './widgets/barcode_scanner_widget.dart';
import './widgets/category_filter_widget.dart';
import './widgets/condition_filter_widget.dart';
import './widgets/date_filter_widget.dart';
import './widgets/filter_section_widget.dart';
import './widgets/image_search_widget.dart';
import './widgets/location_filter_widget.dart';
import './widgets/price_range_filter_widget.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/search_input_widget.dart';
import './widgets/search_suggestions_widget.dart';
import './widgets/voice_search_overlay_widget.dart';

class SearchAndFilters extends StatefulWidget {
  const SearchAndFilters({super.key});

  @override
  State<SearchAndFilters> createState() => _SearchAndFiltersState();
}

class _SearchAndFiltersState extends State<SearchAndFilters> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Search state
  List<String> _recentSearches = [
    'iPhone 13 Pro Max',
    'Samsung Galaxy S23',
    'MacBook Pro 2023',
    'Nike Air Jordan',
    'Toyota Camry 2022',
  ];

  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;
  bool _showVoiceOverlay = false;
  bool _showBarcodeScanner = false;
  bool _showImageSearch = false;

  // Filter state
  final Map<String, bool> _expandedFilters = {
    'Category': false,
    'Price Range': false,
    'Location': false,
    'Condition': false,
    'Date Posted': false,
  };

  // Filter values
  List<String> _selectedCategories = [];
  final double _minPrice = 0.0;
  final double _maxPrice = 10000.0;
  double _currentMinPrice = 0.0;
  double _currentMaxPrice = 10000.0;
  String? _selectedLocation;
  double _selectedRadius = 25.0;
  List<String> _selectedConditions = [];
  String? _selectedDateRange;

  // Mock data
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Electronics',
      'icon': 'devices',
      'subcategories': [
        'Smartphones',
        'Laptops',
        'Tablets',
        'Cameras',
        'Audio',
        'Gaming'
      ],
    },
    {
      'name': 'Vehicles',
      'icon': 'directions_car',
      'subcategories': [
        'Cars',
        'Motorcycles',
        'Trucks',
        'Boats',
        'Parts & Accessories'
      ],
    },
    {
      'name': 'Real Estate',
      'icon': 'home',
      'subcategories': [
        'Houses',
        'Apartments',
        'Commercial',
        'Land',
        'Vacation Rentals'
      ],
    },
    {
      'name': 'Fashion',
      'icon': 'checkroom',
      'subcategories': [
        'Clothing',
        'Shoes',
        'Accessories',
        'Bags',
        'Jewelry',
        'Watches'
      ],
    },
    {
      'name': 'Jobs',
      'icon': 'work',
      'subcategories': [
        'Full-time',
        'Part-time',
        'Contract',
        'Internship',
        'Remote'
      ],
    },
    {
      'name': 'Services',
      'icon': 'build',
      'subcategories': [
        'Home Services',
        'Professional',
        'Personal',
        'Automotive',
        'Events'
      ],
    },
    {
      'name': 'Sports & Recreation',
      'icon': 'sports_soccer',
      'subcategories': [
        'Equipment',
        'Fitness',
        'Outdoor',
        'Team Sports',
        'Water Sports'
      ],
    },
    {
      'name': 'Others',
      'icon': 'category',
      'subcategories': [
        'Books',
        'Toys',
        'Pets',
        'Health & Beauty',
        'Garden',
        'Antiques'
      ],
    },
  ];

  final List<String> _popularSearches = [
    'iPhone 14 Pro',
    'Samsung Galaxy S23',
    'MacBook Pro M2',
    'Toyota Camry',
    'Nike Air Max',
    'PlayStation 5',
    'Apartment Lagos',
    'Honda Civic',
    'Canon EOS R5',
    'Adidas Ultraboost',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final suggestions = _popularSearches
        .where((search) => search.toLowerCase().contains(query))
        .take(5)
        .toList();

    setState(() {
      _searchSuggestions = suggestions;
      _showSuggestions = suggestions.isNotEmpty;
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _showSuggestions = false;
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches = _recentSearches.take(10).toList();
        }
      }
    });

    _performSearch(query);
  }

  void _performSearch(String query) {
    // Navigate to search results or perform search logic
    Navigator.pushNamed(context, '/marketplace-home');
  }

  void _onRecentSearchTap(String search) {
    _searchController.text = search;
    _onSearchSubmitted(search);
  }

  void _onDeleteRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _onSearchSubmitted(suggestion);
  }

  void _onVoiceSearch() {
    setState(() {
      _showVoiceOverlay = true;
    });
  }

  void _onVoiceResult(String result) {
    _searchController.text = result;
    _onSearchSubmitted(result);
  }

  void _onCloseVoiceOverlay() {
    setState(() {
      _showVoiceOverlay = false;
    });
  }

  void _onBarcodeSearch() {
    setState(() {
      _showBarcodeScanner = true;
    });
  }

  void _onBarcodeScanned(String barcode) {
    _searchController.text = 'Barcode: $barcode';
    _onSearchSubmitted('Barcode: $barcode');
  }

  void _onCloseBarcodeScanner() {
    setState(() {
      _showBarcodeScanner = false;
    });
  }

  void _onImageSearch() {
    setState(() {
      _showImageSearch = true;
    });
  }

  void _onImageSearchResult(String result) {
    _searchController.text = result;
    _onSearchSubmitted(result);
  }

  void _onCloseImageSearch() {
    setState(() {
      _showImageSearch = false;
    });
  }

  void _onClearSearch() {
    setState(() {
      _searchSuggestions = [];
      _showSuggestions = false;
    });
  }

  void _toggleFilterSection(String filterName) {
    setState(() {
      _expandedFilters[filterName] = !(_expandedFilters[filterName] ?? false);
    });
  }

  void _onCategoriesChanged(List<String> categories) {
    setState(() {
      _selectedCategories = categories;
    });
  }

  void _onPriceRangeChanged(double minPrice, double maxPrice) {
    setState(() {
      _currentMinPrice = minPrice;
      _currentMaxPrice = maxPrice;
    });
  }

  void _onLocationChanged(String? location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _onRadiusChanged(double radius) {
    setState(() {
      _selectedRadius = radius;
    });
  }

  void _onConditionsChanged(List<String> conditions) {
    setState(() {
      _selectedConditions = conditions;
    });
  }

  void _onDateRangeChanged(String? dateRange) {
    setState(() {
      _selectedDateRange = dateRange;
    });
  }

  void _onApplyFilters() {
    // Apply filters and navigate to results
    Navigator.pushNamed(context, '/marketplace-home');
  }

  void _onClearFilters() {
    setState(() {
      _selectedCategories = [];
      _currentMinPrice = _minPrice;
      _currentMaxPrice = _maxPrice;
      _selectedLocation = null;
      _selectedRadius = 25.0;
      _selectedConditions = [];
      _selectedDateRange = null;
      _expandedFilters.updateAll((key, value) => false);
    });
  }

  bool get _hasActiveFilters {
    return _selectedCategories.isNotEmpty ||
        _currentMinPrice != _minPrice ||
        _currentMaxPrice != _maxPrice ||
        _selectedLocation != null ||
        _selectedRadius != 25.0 ||
        _selectedConditions.isNotEmpty ||
        _selectedDateRange != null;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategories.isNotEmpty) count++;
    if (_currentMinPrice != _minPrice || _currentMaxPrice != _maxPrice) count++;
    if (_selectedLocation != null) count++;
    if (_selectedConditions.isNotEmpty) count++;
    if (_selectedDateRange != null) count++;
    return count;
  }

  int get _resultCount {
    // Mock result count based on filters
    int baseCount = 1247;
    if (_selectedCategories.isNotEmpty) baseCount = (baseCount * 0.6).round();
    if (_currentMinPrice != _minPrice || _currentMaxPrice != _maxPrice) {
      baseCount = (baseCount * 0.8).round();
    }
    if (_selectedLocation != null) baseCount = (baseCount * 0.7).round();
    if (_selectedConditions.isNotEmpty) baseCount = (baseCount * 0.9).round();
    if (_selectedDateRange != null) baseCount = (baseCount * 0.85).round();
    return baseCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                  AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Search & Filters',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          if (_hasActiveFilters)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '$_activeFilterCount',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Input
              SearchInputWidget(
                controller: _searchController,
                onVoiceSearch: _onVoiceSearch,
                onBarcodeSearch: _onBarcodeSearch,
                onImageSearch: _onImageSearch,
                onChanged: (value) => _onSearchChanged(),
                onClear: _onClearSearch,
              ),

              // Search Suggestions
              if (_showSuggestions)
                SearchSuggestionsWidget(
                  suggestions: _searchSuggestions,
                  onSuggestionTap: _onSuggestionTap,
                ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Recent Searches
                      if (!_showSuggestions)
                        RecentSearchesWidget(
                          recentSearches: _recentSearches,
                          onSearchTap: _onRecentSearchTap,
                          onDeleteSearch: _onDeleteRecentSearch,
                        ),

                      // Filters Section
                      if (!_showSuggestions) ...[
                        SizedBox(height: 2.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'tune',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 24,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Advanced Filters',
                                style: AppTheme.lightTheme.textTheme.titleLarge
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // Category Filter
                        FilterSectionWidget(
                          title: 'Category',
                          content: CategoryFilterWidget(
                            categories: _categories,
                            selectedCategories: _selectedCategories,
                            onCategoriesChanged: _onCategoriesChanged,
                          ),
                          activeCount: _selectedCategories.length,
                          isExpanded: _expandedFilters['Category'] ?? false,
                          onToggle: () => _toggleFilterSection('Category'),
                        ),

                        // Price Range Filter
                        FilterSectionWidget(
                          title: 'Price Range',
                          content: PriceRangeFilterWidget(
                            minPrice: _minPrice,
                            maxPrice: _maxPrice,
                            currentMinPrice: _currentMinPrice,
                            currentMaxPrice: _currentMaxPrice,
                            onPriceRangeChanged: _onPriceRangeChanged,
                          ),
                          activeCount: (_currentMinPrice != _minPrice ||
                                  _currentMaxPrice != _maxPrice)
                              ? 1
                              : null,
                          isExpanded: _expandedFilters['Price Range'] ?? false,
                          onToggle: () => _toggleFilterSection('Price Range'),
                        ),

                        // Location Filter
                        FilterSectionWidget(
                          title: 'Location',
                          content: LocationFilterWidget(
                            selectedLocation: _selectedLocation,
                            selectedRadius: _selectedRadius,
                            onLocationChanged: _onLocationChanged,
                            onRadiusChanged: _onRadiusChanged,
                          ),
                          activeCount: _selectedLocation != null ? 1 : null,
                          isExpanded: _expandedFilters['Location'] ?? false,
                          onToggle: () => _toggleFilterSection('Location'),
                        ),

                        // Condition Filter
                        FilterSectionWidget(
                          title: 'Condition',
                          content: ConditionFilterWidget(
                            selectedConditions: _selectedConditions,
                            onConditionsChanged: _onConditionsChanged,
                          ),
                          activeCount: _selectedConditions.length,
                          isExpanded: _expandedFilters['Condition'] ?? false,
                          onToggle: () => _toggleFilterSection('Condition'),
                        ),

                        // Date Posted Filter
                        FilterSectionWidget(
                          title: 'Date Posted',
                          content: DateFilterWidget(
                            selectedDateRange: _selectedDateRange,
                            onDateRangeChanged: _onDateRangeChanged,
                          ),
                          activeCount: _selectedDateRange != null ? 1 : null,
                          isExpanded: _expandedFilters['Date Posted'] ?? false,
                          onToggle: () => _toggleFilterSection('Date Posted'),
                        ),

                        // Bottom padding for sticky button
                        SizedBox(height: 12.h),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Apply Filters Button (Sticky)
          if (!_showSuggestions)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ApplyFiltersWidget(
                resultCount: _resultCount,
                onApplyFilters: _onApplyFilters,
                onClearFilters: _onClearFilters,
                hasActiveFilters: _hasActiveFilters,
              ),
            ),

          // Voice Search Overlay
          if (_showVoiceOverlay)
            VoiceSearchOverlayWidget(
              onVoiceResult: _onVoiceResult,
              onClose: _onCloseVoiceOverlay,
            ),

          // Barcode Scanner
          if (_showBarcodeScanner)
            BarcodeScannerWidget(
              onBarcodeScanned: _onBarcodeScanned,
              onClose: _onCloseBarcodeScanner,
            ),

          // Image Search
          if (_showImageSearch)
            ImageSearchWidget(
              onImageSearchResult: _onImageSearchResult,
              onClose: _onCloseImageSearch,
            ),
        ],
      ),
    );
  }
}
