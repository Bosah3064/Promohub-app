import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
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

  final MarketplaceService _marketplaceService = MarketplaceService();
  bool _isSearching = false;

  // Dynamic data from database
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _activeFilters = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadInitialResults();
  }

  Future<void> _loadInitialResults() async {
    setState(() => _isSearching = true);
    try {
      final results = await _marketplaceService.getListings(limit: 20);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // Allow user to trigger search when typing stops (simplified)
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _loadInitialResults();
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await _marketplaceService.getListings(
        searchQuery: query,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
          // Add to recent searches
          if (!_recentSearches.contains(query)) {
            _recentSearches.insert(0, query);
            if (_recentSearches.length > 10) _recentSearches.removeLast();
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

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
    await _loadInitialResults();
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
            padding: EdgeInsets.all(18.0),
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
                SizedBox(height: 14.0),
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
