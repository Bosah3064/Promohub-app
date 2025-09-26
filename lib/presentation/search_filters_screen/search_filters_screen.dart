import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/filter_panel_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/search_results_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';

class SearchFiltersScreen extends StatefulWidget {
  const SearchFiltersScreen({super.key});

  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isFilterPanelVisible = false;
  bool _isVoiceSearchActive = false;
  String _selectedSortOption = 'Relevance';

  // Mock data for search results
  final List<Map<String, dynamic>> _searchResults = [
    {
      "id": 1,
      "title": "iPhone 14 Pro Max",
      "price": "\$1,200",
      "location": "Lagos, Nigeria",
      "image":
          "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg",
      "condition": "New",
      "seller": "TechStore Lagos",
      "distance": "2.5 km",
      "postedDate": "2 hours ago",
      "isFavorite": false,
    },
    {
      "id": 2,
      "title": "MacBook Air M2",
      "price": "\$999",
      "location": "Abuja, Nigeria",
      "image":
          "https://images.pexels.com/photos/205421/pexels-photo-205421.jpeg",
      "condition": "Used",
      "seller": "John Doe",
      "distance": "5.2 km",
      "postedDate": "1 day ago",
      "isFavorite": true,
    },
    {
      "id": 3,
      "title": "Samsung Galaxy S23",
      "price": "\$800",
      "location": "Port Harcourt, Nigeria",
      "image":
          "https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg",
      "condition": "New",
      "seller": "Mobile World",
      "distance": "1.8 km",
      "postedDate": "3 hours ago",
      "isFavorite": false,
    },
    {
      "id": 4,
      "title": "Dell XPS 13",
      "price": "\$750",
      "location": "Kano, Nigeria",
      "image": "https://images.pexels.com/photos/18105/pexels-photo.jpg",
      "condition": "Used",
      "seller": "Tech Hub",
      "distance": "3.1 km",
      "postedDate": "5 hours ago",
      "isFavorite": false,
    },
  ];

  // Mock data for active filters
  final List<Map<String, dynamic>> _activeFilters = [
    {"label": "Electronics", "type": "category"},
    {"label": "\$500 - \$1500", "type": "price"},
    {"label": "Within 5km", "type": "location"},
  ];

  // Mock data for recent searches
  final List<String> _recentSearches = [
    "iPhone 14",
    "MacBook Pro",
    "Samsung Galaxy",
    "Gaming Laptop",
    "iPad Air",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
    });
  }

  void _removeFilter(int index) {
    setState(() {
      _activeFilters.removeAt(index);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SortBottomSheetWidget(
        selectedSort: _selectedSortOption,
        onSortSelected: (sortOption) {
          setState(() {
            _selectedSortOption = sortOption;
          });
        },
      ),
    );
  }

  void _onVoiceSearch() {
    setState(() {
      _isVoiceSearchActive = !_isVoiceSearchActive;
    });

    // Simulate voice search animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isVoiceSearchActive = false;
          _searchController.text = "iPhone 14 Pro";
        });
      }
    });
  }

  void _onBarcodeSearch() {
    // Simulate barcode scanner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barcode scanner opened'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Search & Filters',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _showSortBottomSheet,
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  isVoiceSearchActive: _isVoiceSearchActive,
                  recentSearches: _recentSearches,
                  onVoiceSearch: _onVoiceSearch,
                  onBarcodeSearch: _onBarcodeSearch,
                  onFilterToggle: _toggleFilterPanel,
                  isFilterActive: _activeFilters.isNotEmpty,
                ),
                SizedBox(height: 12.sp),
                FilterChipsWidget(
                  activeFilters: _activeFilters,
                  onRemoveFilter: _removeFilter,
                  onClearAll: _clearAllFilters,
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _isFilterPanelVisible
                ? FilterPanelWidget(
                    onApplyFilters: (filters) {
                      setState(() {
                        _activeFilters.clear();
                        _activeFilters.addAll(filters);
                        _isFilterPanelVisible = false;
                      });
                    },
                    onClose: () {
                      setState(() {
                        _isFilterPanelVisible = false;
                      });
                    },
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: SearchResultsWidget(
                      searchResults: _searchResults,
                      selectedSort: _selectedSortOption,
                      onItemTap: (item) {
                        Navigator.pushNamed(context, '/listing-detail-screen');
                      },
                      onFavoriteToggle: (index) {
                        setState(() {
                          _searchResults[index]['isFavorite'] =
                              !(_searchResults[index]['isFavorite'] as bool);
                        });
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
