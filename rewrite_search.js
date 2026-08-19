const fs = require('fs');

const searchAndFiltersPath = 'lib/presentation/search_and_filters/search_and_filters.dart';

const newSearchAndFiltersCode = `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import './widgets/apply_filters_widget.dart';
import './widgets/category_filter_widget.dart';
import './widgets/condition_filter_widget.dart';
import './widgets/date_filter_widget.dart';
import './widgets/location_filter_widget.dart';
import './widgets/price_range_filter_widget.dart';
import './widgets/search_input_widget.dart';

class SearchAndFiltersScreen extends StatefulWidget {
  const SearchAndFiltersScreen({super.key});

  @override
  State<SearchAndFiltersScreen> createState() => _SearchAndFiltersScreenState();
}

class _SearchAndFiltersScreenState extends State<SearchAndFiltersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MarketplaceService _marketplaceService = MarketplaceService();

  // Search state
  List<String> _recentSearches = [
    'iPhone 13 Pro Max',
    'Samsung Galaxy S23',
    'MacBook Pro 2023',
  ];

  final List<String> _popularSearches = [
    'iPhone 14 Pro',
    'Samsung Galaxy S23',
    'MacBook Pro M2',
    'Toyota Camry',
    'Nike Air Max',
    'PlayStation 5',
  ];

  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _marketplaceService.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
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

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      if (!_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        });
      }
      
      HapticFeedback.lightImpact();
      // Navigate to search results
      Navigator.pushNamed(context, AppRoutes.searchFilters, arguments: query);
    }
  }

  void _onClearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should use dark or light theme colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Fantastic colors palette
    final primaryGradient = LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    final surfaceColor = isDark ? Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Color(0xFF2D3142);
    final mutedTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF12121D) : Color(0xFFF7F9FC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'What are you looking for today?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: Transform.translate(
                offset: Offset(0, 30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Hero(
                    tag: 'search_bar_hero',
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _onSearchSubmitted,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Search products, cars, jobs...',
                          hintStyle: TextStyle(color: mutedTextColor),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF6C63FF)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: mutedTextColor),
                                  onPressed: _onClearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 50), // Spacing for floating search bar
          ),
          
          if (_showSuggestions) ...[
            SliverToBoxAdapter(
              child: _buildSectionTitle('Suggestions', surfaceColor, textColor),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final suggestion = _searchSuggestions[index];
                  return ListTile(
                    leading: Icon(Icons.trending_up, color: Color(0xFF6C63FF)),
                    title: Text(suggestion, style: TextStyle(color: textColor)),
                    onTap: () => _onSearchSubmitted(suggestion),
                  );
                },
                childCount: _searchSuggestions.length,
              ),
            ),
          ] else ...[
            // Recent Searches
            if (_recentSearches.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: _onClearRecentSearches,
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: _recentSearches.map((search) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        backgroundColor: surfaceColor,
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.05),
                        label: Text(search, style: TextStyle(color: textColor)),
                        onPressed: () => _onSearchSubmitted(search),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],

            // Popular Categories
            SliverToBoxAdapter(
              child: _buildSectionTitle('Categories', surfaceColor, textColor),
            ),
            if (_isLoadingCategories)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  ),
                ),
              )
            else if (_categories.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = _categories[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              _onSearchSubmitted(category['name'] ?? '');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6C63FF).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.category, 
                                      color: Color(0xFF6C63FF),
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category['name'] ?? '',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _categories.length > 8 ? 8 : _categories.length, // Show up to 8
                  ),
                ),
              ),
              
            SliverToBoxAdapter(child: SizedBox(height: 30)),
            
            // Popular Searches
            SliverToBoxAdapter(
              child: _buildSectionTitle('Trending Now', surfaceColor, textColor),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _popularSearches.map((search) {
                    return InkWell(
                      onTap: () => _onSearchSubmitted(search),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Text(
                              search,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color surfaceColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
`;

fs.writeFileSync(searchAndFiltersPath, newSearchAndFiltersCode);
console.log('Successfully rewrote search_and_filters.dart');
