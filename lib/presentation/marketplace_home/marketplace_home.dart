import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_currency_service.dart';
import '../../services/marketplace_service.dart';
import '../../services/firebase_service.dart';
import './widgets/category_chips_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/featured_listings_carousel_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/listing_card_widget.dart';
import './widgets/location_selector_widget.dart';
import './widgets/quick_actions_bottom_sheet_widget.dart';
import './widgets/promo_banner_widget.dart';
import './widgets/search_bar_widget.dart';

class MarketplaceHome extends StatefulWidget {
  const MarketplaceHome({super.key});

  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MarketplaceService _marketplaceService = MarketplaceService();
  final LocationCurrencyService _locationService = LocationCurrencyService();
  final FirebaseService _firebaseService = FirebaseService();

  int _currentBottomNavIndex = 0;
  String _currentLocation = 'Lagos, Nigeria';
  String? _selectedCategory;
  bool _isRefreshing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _appliedFilters;

  // Database-driven data
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _featuredListings = [];
  List<Map<String, dynamic>> _recentListings = [];
  List<Map<String, dynamic>> _sponsoredListings = [];
  List<String> _availableLocations = [];

  // Pagination state
  int _currentPage = 0;
  final int _limit = 20;
  bool _hasMoreListings = true;
  bool _isLoadingMore = false;

  List<Map<String, dynamic>> get _filteredListings {
    List<Map<String, dynamic>> filtered = List.from(_recentListings);

    if (_selectedCategory != null && _selectedCategory != 'All Categories') {
      filtered = filtered
          .where(
              (listing) => listing['category_id']?['name'] == _selectedCategory)
          .toList();
    }

    if (_appliedFilters != null) {
      // Apply price filter
      if (_appliedFilters!['priceMin'] != null &&
          _appliedFilters!['priceMax'] != null) {
        filtered = filtered.where((listing) {
          final price = (listing['price'] as num?)?.toDouble() ?? 0;
          return price >= _appliedFilters!['priceMin'] &&
              price <= _appliedFilters!['priceMax'];
        }).toList();
      }

      // Apply category filter from bottom sheet
      if (_appliedFilters!['category'] != null &&
          _appliedFilters!['category'] != 'All Categories') {
        filtered = filtered
            .where((listing) =>
                listing['category_id']?['name'] == _appliedFilters!['category'])
            .toList();
      }

      // Apply condition filter
      if (_appliedFilters!['condition'] != null) {
        filtered = filtered
            .where((listing) =>
                listing['condition'] == _appliedFilters!['condition'])
            .toList();
      }

      // Apply location filter
      if (_appliedFilters!['location'] != null) {
        final filterLocation = _appliedFilters!['location'].toString();
        filtered = filtered
            .where((listing) => (listing['location']?.toString() ?? '')
                .toLowerCase()
                .contains(filterLocation.toLowerCase()))
            .toList();
      }
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _setupRealtimeSubscription();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreListings) {
      _loadMoreListings();
    }
  }

  StreamSubscription? _listingsSubscription;
  StreamSubscription? _sponsoredSubscription;

  void _setupRealtimeSubscription() async {
    final firestore = _firebaseService.firestore;
    _listingsSubscription =
        firestore.collection('listings').snapshots().listen((snapshot) {
      if (mounted && !_isRefreshing) {
        _refreshListings();
      }
    });
    _sponsoredSubscription = firestore
        .collection('sponsored_products')
        .snapshots()
        .listen((snapshot) {
      if (mounted && !_isRefreshing) {
        _refreshListings();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _listingsSubscription?.cancel();
    _sponsoredSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Load each data source independently — if one fails, the rest still work
    List<Map<String, dynamic>> categories = [];
    List<Map<String, dynamic>> featured = [];
    List<Map<String, dynamic>> recent = [];
    List<Map<String, dynamic>> countries = [];
    List<Map<String, dynamic>> sponsored = [];

    try {
      categories = await _marketplaceService.getCategories();
    } catch (e) {
      debugPrint('Categories load error: $e');
    }

    try {
      featured = await _marketplaceService.getFeaturedListings(limit: 10);
    } catch (e) {
      debugPrint('Featured listings load error: $e');
    }

    try {
      recent = await _marketplaceService.getListings(limit: _limit, offset: 0);
    } catch (e) {
      debugPrint('Recent listings load error: $e');
    }

    try {
      countries = await _locationService.getCountries();
    } catch (e) {
      debugPrint('Countries load error: $e');
    }

    try {
      sponsored = await _marketplaceService.getSponsoredListings(limit: 5);
    } catch (e) {
      debugPrint('Sponsored load error: $e');
    }

    if (mounted) {
      setState(() {
        _categories = categories;
        _featuredListings = featured;
        _recentListings = recent;
        _sponsoredListings = sponsored;

        if (_recentListings.length < _limit) {
          _hasMoreListings = false;
        }

        // Extract location names from countries data
        _availableLocations =
            countries.map((country) => '${country['country_name']}').toList();

        _isLoading = false;
      });
    }
  }

  Future<void> _refreshListings() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    try {
      _currentPage = 0;
      _hasMoreListings = true;

      List<Map<String, dynamic>> featured = _featuredListings;
      List<Map<String, dynamic>> recent = _recentListings;
      List<Map<String, dynamic>> sponsored = _sponsoredListings;

      try {
        featured = await _marketplaceService.getFeaturedListings(limit: 10);
      } catch (e) {
        debugPrint('Refresh featured error: $e');
      }
      try {
        recent =
            await _marketplaceService.getListings(limit: _limit, offset: 0);
      } catch (e) {
        debugPrint('Refresh recent error: $e');
      }
      try {
        sponsored = await _marketplaceService.getSponsoredListings(limit: 5);
      } catch (e) {
        debugPrint('Refresh sponsored error: $e');
      }

      if (mounted) {
        setState(() {
          _featuredListings = featured;
          _recentListings = recent;
          _sponsoredListings = sponsored;
          _isRefreshing = false;
          if (_recentListings.length < _limit) {
            _hasMoreListings = false;
          }
        });

        Fluttertoast.showToast(
          msg: "Listings updated!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isRefreshing = false);

        Fluttertoast.showToast(
          msg: "Failed to refresh listings",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  Future<void> _loadMoreListings() async {
    if (_isLoadingMore || !_hasMoreListings) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextOffset = (_currentPage + 1) * _limit;
      final moreListings = await _marketplaceService.getListings(
        limit: _limit,
        offset: nextOffset,
      );

      if (mounted) {
        setState(() {
          _currentPage++;
          if (moreListings.isEmpty || moreListings.length < _limit) {
            _hasMoreListings = false;
          }
          // Avoid duplicates
          for (var listing in moreListings) {
            if (!_recentListings.any((r) => r['id'] == listing['id'])) {
              _recentListings.add(listing);
            }
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onLocationTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Select Location',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView.builder(
                itemCount: _availableLocations.length,
                itemBuilder: (context, index) {
                  final location = _availableLocations[index];
                  return ListTile(
                    leading: CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    title: Text(location),
                    trailing: _currentLocation == location
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _currentLocation = location;
                      });
                      Navigator.pop(context);
                      _refreshListings(); // Refresh with new location
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
    });
  }

  void _onListingTap(Map<String, dynamic> listing) {
    Navigator.pushNamed(
      context,
      '/listing-detail',
      arguments: listing['id'],
    );
  }

  Future<void> _onFavoriteTap(Map<String, dynamic> listing) async {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      Fluttertoast.showToast(
        msg: "Please log in to save favorites",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    HapticFeedback.lightImpact();

    try {
      final listingId = listing['id'] as String;
      final isFavorite =
          await _marketplaceService.isInFavorites(currentUserId, listingId);

      if (isFavorite) {
        await _marketplaceService.removeFromFavorites(currentUserId, listingId);
        Fluttertoast.showToast(
          msg: "Removed from favorites",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        await _marketplaceService.addToFavorites(currentUserId, listingId);
        Fluttertoast.showToast(
          msg: "Added to favorites",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }

      // Update local state
      setState(() {
        listing['isFavorite'] = !isFavorite;
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to update favorites",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _onListingLongPress(Map<String, dynamic> listing) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsBottomSheetWidget(
        listing: listing,
        onSave: () => _onFavoriteTap(listing),
        onShare: () {
          Fluttertoast.showToast(
            msg: "Sharing listing...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
        onReport: () {
          Fluttertoast.showToast(
            msg: "Listing reported",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    final filteredListings = _filteredListings;
    final hasListings =
        _featuredListings.isNotEmpty || filteredListings.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'shopping_cart',
                        color: const Color(0xFF0F7B2D), // Green
                        size: 32,
                      ),
                      SizedBox(width: 2.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PromoHub',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Sell More. Buy Better.',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: const Color(0xFF0F7B2D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Stack(
                      children: [
                        const CustomIconWidget(
                          iconName: 'notifications_none',
                          color: Colors.black87,
                          size: 28,
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky search bar
            SearchBarWidget(
              searchController: _searchController,
              onSearchTap: _onSearchTap,
              onVoiceSearchTap: _onVoiceSearchTap,
              onFilterTap: _onFilterTap,
              onSearchChanged: _onSearchChanged,
            ),

            // Main content
            Expanded(
              child: hasListings
                  ? RefreshIndicator(
                      onRefresh: _refreshListings,
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // Location selector
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: LocationSelectorWidget(
                                currentLocation: _currentLocation,
                                onLocationTap: _onLocationTap,
                              ),
                            ),
                          ),

                          // Category chips - Convert database categories to display format
                          if (_categories.isNotEmpty)
                            SliverToBoxAdapter(
                              child: CategoryChipsWidget(
                                categories: _categories
                                    .map((cat) => {
                                          'name': cat['name']?.toString() ??
                                              'Other',
                                          'icon': _getCategoryIcon(
                                              cat['name']?.toString() ?? ''),
                                        })
                                    .toList(),
                                selectedCategory: _selectedCategory,
                                onCategorySelected: _onCategorySelected,
                              ),
                            ),

                          // Promo Banner
                          SliverToBoxAdapter(
                            child: PromoBannerWidget(
                              onExploreTap: () => Navigator.pushNamed(
                                  context, '/search-and-filters'),
                            ),
                          ),

                          SliverToBoxAdapter(child: SizedBox(height: 3.h)),

                          // Featured listings carousel
                          if (_featuredListings.isNotEmpty)
                            SliverToBoxAdapter(
                              child: FeaturedListingsCarouselWidget(
                                featuredListings:
                                    _featuredListings.map((listing) {
                                  // Safely extract category
                                  String categoryName = 'Other';
                                  if (listing['category_id'] is Map) {
                                    categoryName = listing['category_id']
                                                ['name']
                                            ?.toString() ??
                                        'Other';
                                  } else if (listing['category_id'] != null) {
                                    categoryName =
                                        listing['category_id'].toString();
                                  }

                                  // Safely extract image
                                  String imageUrl =
                                      'https://images.unsplash.com/photo-1560472355-536de3962603?w=500&h=300&fit=crop';
                                  if (listing['images'] is List &&
                                      (listing['images'] as List).isNotEmpty) {
                                    imageUrl = (listing['images'] as List)[0]
                                            ?.toString() ??
                                        imageUrl;
                                  }

                                  return {
                                    'id': listing['id']?.toString() ?? '',
                                    'title': listing['title']?.toString() ??
                                        'Unknown',
                                    'price':
                                        '\$${listing['price']?.toString() ?? '0'}',
                                    'location':
                                        listing['location']?.toString() ??
                                            'Location not set',
                                    'timePosted':
                                        _formatTimeAgo(listing['created_at']),
                                    'image': imageUrl,
                                    'isFavorite': listing['isFavorite'] == true,
                                    'category': categoryName,
                                  };
                                }).toList(),
                                onListingTap: _onListingTap,
                                onFavoriteTap: _onFavoriteTap,
                              ),
                            ),

                          if (_featuredListings.isNotEmpty)
                            SliverToBoxAdapter(child: SizedBox(height: 4.h)),

                          // Sponsored Listings Block
                          if (_sponsoredListings.isNotEmpty &&
                              _selectedCategory == null &&
                              _appliedFilters == null)
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Row(
                                      children: [
                                        Icon(Icons.auto_awesome,
                                            color: AppTheme.secondaryLight,
                                            size: 20),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Sponsored',
                                          style: AppTheme
                                              .lightTheme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.secondaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  SizedBox(
                                    height: 32.h,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4.w),
                                      itemCount: _sponsoredListings.length,
                                      itemBuilder: (context, index) {
                                        final ad = _sponsoredListings[index];
                                        final listing = ad['listing_id']
                                                as Map<String, dynamic>? ??
                                            {};
                                        if (listing.isEmpty) {
                                          return const SizedBox();
                                        }

                                        // Safely extract category
                                        String categoryName = 'Other';
                                        if (listing['category_id'] is Map) {
                                          categoryName = listing['category_id']
                                                      ['name']
                                                  ?.toString() ??
                                              'Other';
                                        } else if (listing['category_id'] !=
                                            null) {
                                          categoryName =
                                              listing['category_id'].toString();
                                        }

                                        // Safely extract image
                                        String imageUrl =
                                            'https://images.unsplash.com/photo-1560472355-536de3962603?w=400&h=300&fit=crop';
                                        if (listing['images'] is List &&
                                            (listing['images'] as List)
                                                .isNotEmpty) {
                                          imageUrl =
                                              (listing['images'] as List)[0]
                                                      ?.toString() ??
                                                  imageUrl;
                                        }

                                        final displayListing = {
                                          'id': listing['id']?.toString() ?? '',
                                          'title':
                                              listing['title']?.toString() ??
                                                  'Unknown',
                                          'price':
                                              'KSh ${listing['price']?.toString() ?? '0'}',
                                          'location':
                                              listing['location']?.toString() ??
                                                  'Location not set',
                                          'timePosted':
                                              listing['created_at'] != null
                                                  ? _formatTimeAgo(
                                                      listing['created_at'])
                                                  : '',
                                          'image': imageUrl,
                                          'isFavorite':
                                              listing['isFavorite'] == true,
                                          'category': categoryName,
                                          'isSponsored': true,
                                        };

                                        return Container(
                                          width: 45.w,
                                          margin: EdgeInsets.only(right: 3.w),
                                          child: ListingCardWidget(
                                            listing: displayListing,
                                            onTap: () {
                                              _marketplaceService.recordAdClick(
                                                  ad['id'].toString());
                                              _onListingTap(displayListing);
                                            },
                                            onFavoriteTap: () =>
                                                _onFavoriteTap(displayListing),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                ],
                              ),
                            ),

                          // Recent listings header
                          if (filteredListings.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Text(
                                  'Recent Listings',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                          if (filteredListings.isNotEmpty)
                            SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                          // Recent listings grid
                          if (filteredListings.isNotEmpty)
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 3.w,
                                  mainAxisSpacing: 3.w,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final listing = filteredListings[index];
                                    // Safely extract category
                                    String categoryName = 'Other';
                                    if (listing['category_id'] is Map) {
                                      categoryName = listing['category_id']
                                                  ['name']
                                              ?.toString() ??
                                          'Other';
                                    } else if (listing['category_id'] != null) {
                                      categoryName =
                                          listing['category_id'].toString();
                                    }

                                    // Safely extract image
                                    String imageUrl =
                                        'https://images.unsplash.com/photo-1560472355-536de3962603?w=400&h=300&fit=crop';
                                    if (listing['images'] is List &&
                                        (listing['images'] as List)
                                            .isNotEmpty) {
                                      imageUrl = (listing['images'] as List)[0]
                                              ?.toString() ??
                                          imageUrl;
                                    }

                                    final displayListing = {
                                      'id': listing['id']?.toString() ?? '',
                                      'title': listing['title']?.toString() ??
                                          'Unknown',
                                      'price':
                                          '\$${listing['price']?.toString() ?? '0'}',
                                      'location':
                                          listing['location']?.toString() ??
                                              'Location not set',
                                      'timePosted':
                                          _formatTimeAgo(listing['created_at']),
                                      'image': imageUrl,
                                      'isFavorite':
                                          listing['isFavorite'] == true,
                                      'category': categoryName,
                                    };

                                    return ListingCardWidget(
                                      listing: displayListing,
                                      onTap: () => _onListingTap(listing),
                                      onFavoriteTap: () =>
                                          _onFavoriteTap(listing),
                                      onLongPress: () =>
                                          _onListingLongPress(listing),
                                    );
                                  },
                                  childCount: filteredListings.length,
                                ),
                              ),
                            ),

                          if (_isLoadingMore)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),

                          // Bottom padding
                          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                        ],
                      ),
                    )
                  : EmptyStateWidget(
                      currentLocation: _currentLocation,
                      onPostAdTap: _onPostAdTap,
                    ),
            ),
          ],
        ),
      ),

      // Floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onPostAdTap,
        icon: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onSecondary,
          size: 24,
        ),
        label: Text(
          'Post Ad',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentBottomNavIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: _currentBottomNavIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'favorite',
              color: _currentBottomNavIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'message',
              color: _currentBottomNavIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentBottomNavIndex == 4
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        return 'phone_android';
      case 'fashion':
      case 'clothing':
        return 'checkroom';
      case 'vehicles':
        return 'directions_car';
      case 'real estate':
        return 'home';
      case 'jobs':
        return 'work';
      case 'services':
        return 'build';
      case 'sports':
        return 'sports_soccer';
      case 'books':
        return 'menu_book';
      default:
        return 'category';
    }
  }

  String _formatTimeAgo(dynamic createdAt) {
    if (createdAt == null) return 'Recently';

    try {
      DateTime created;
      if (createdAt is String) {
        created = DateTime.parse(createdAt);
      } else if (createdAt.runtimeType.toString() == 'Timestamp') {
        created = createdAt.toDate();
      } else {
        return 'Recently';
      }

      final DateTime now = DateTime.now();
      final Duration difference = now.difference(created);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _onSearchTap() {
    Navigator.pushNamed(context, '/search-and-filters');
  }

  void _onVoiceSearchTap() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Voice search activated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        onFiltersApplied: (filters) {
          setState(() {
            _appliedFilters = filters;
          });
          Fluttertoast.showToast(
            msg: "Filters applied",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    // Implement real-time search if needed
    if (query.isNotEmpty && query.length >= 3) {
      // Debounced search implementation could go here
    }
  }

  void _onPostAdTap() {
    Navigator.pushNamed(context, '/create-listing');
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/search-and-filters');
        break;
      case 2:
        Navigator.pushNamed(context, '/favorites-and-saved-items');
        break;
      case 3:
        Navigator.pushNamed(context, '/messages-and-chat');
        break;
      case 4:
        Navigator.pushNamed(context, '/user-profile');
        break;
    }
  }
}
