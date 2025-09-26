import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bulk_actions_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/saved_listing_card.dart';
import './widgets/saved_search_card.dart';
import './widgets/sort_bottom_sheet.dart';

class FavoritesAndSavedItems extends StatefulWidget {
  const FavoritesAndSavedItems({super.key});

  @override
  State<FavoritesAndSavedItems> createState() => _FavoritesAndSavedItemsState();
}

class _FavoritesAndSavedItemsState extends State<FavoritesAndSavedItems>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = false;
  String _currentSortOption = 'recently_saved';
  bool _isBulkSelectionMode = false;
  Set<int> _selectedListingIds = {};
  final Set<int> _selectedSearchIds = {};

  // Mock data for saved listings
  final List<Map<String, dynamic>> _savedListings = [
    {
      "id": 1,
      "title": "iPhone 14 Pro Max 256GB Space Black",
      "price": "\$899",
      "originalPrice": "\$1,099",
      "location": "Lagos, Nigeria",
      "datePosted": "2 days ago",
      "status": "available",
      "hasPriceDrop": true,
      "image":
          "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=400&fit=crop",
    },
    {
      "id": 2,
      "title": "Toyota Camry 2019 - Low Mileage",
      "price": "\$18,500",
      "originalPrice": "",
      "location": "Abuja, Nigeria",
      "datePosted": "1 week ago",
      "status": "available",
      "hasPriceDrop": false,
      "image":
          "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400&h=400&fit=crop",
    },
    {
      "id": 3,
      "title": "3 Bedroom Apartment in Victoria Island",
      "price": "\$1,200/month",
      "originalPrice": "",
      "location": "Lagos, Nigeria",
      "datePosted": "3 days ago",
      "status": "sold",
      "hasPriceDrop": false,
      "image":
          "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400&h=400&fit=crop",
    },
    {
      "id": 4,
      "title": "MacBook Pro 16-inch M2 Chip",
      "price": "\$1,899",
      "originalPrice": "",
      "location": "Accra, Ghana",
      "datePosted": "2 weeks ago",
      "status": "expired",
      "hasPriceDrop": false,
      "image":
          "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400&h=400&fit=crop",
    },
    {
      "id": 5,
      "title": "Samsung Galaxy S23 Ultra 512GB",
      "price": "\$749",
      "originalPrice": "\$899",
      "location": "Nairobi, Kenya",
      "datePosted": "5 days ago",
      "status": "available",
      "hasPriceDrop": true,
      "image":
          "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400&h=400&fit=crop",
    },
  ];

  // Mock data for saved searches
  final List<Map<String, dynamic>> _savedSearches = [
    {
      "id": 1,
      "title": "iPhone 14 Pro in Lagos under \$1000",
      "category": "Electronics",
      "location": "Lagos, Nigeria",
      "priceRange": "\$500 - \$1000",
      "keywords": "iPhone 14 Pro",
      "resultCount": 23,
      "hasNewResults": true,
      "notificationsEnabled": true,
      "lastUpdated": "2 hours ago",
    },
    {
      "id": 2,
      "title": "Toyota Cars 2018-2022",
      "category": "Vehicles",
      "location": "Nigeria",
      "priceRange": "\$15,000 - \$25,000",
      "keywords": "Toyota Camry Corolla",
      "resultCount": 45,
      "hasNewResults": false,
      "notificationsEnabled": true,
      "lastUpdated": "1 day ago",
    },
    {
      "id": 3,
      "title": "2-3 Bedroom Apartments Victoria Island",
      "category": "Real Estate",
      "location": "Victoria Island, Lagos",
      "priceRange": "\$800 - \$1500/month",
      "keywords": "apartment furnished",
      "resultCount": 12,
      "hasNewResults": true,
      "notificationsEnabled": false,
      "lastUpdated": "6 hours ago",
    },
    {
      "id": 4,
      "title": "MacBook Pro M2 Chip",
      "category": "Electronics",
      "location": "West Africa",
      "priceRange": "\$1500 - \$2500",
      "keywords": "MacBook Pro M2",
      "resultCount": 8,
      "hasNewResults": false,
      "notificationsEnabled": true,
      "lastUpdated": "3 days ago",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSavedListingsTab(),
                _buildSavedSearchesTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isBulkSelectionMode ? _buildBulkActionsBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 6.w,
        ),
      ),
      title: Text(
        'Favorites & Saved',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      actions: [
        if (_tabController.index == 0 && !_isBulkSelectionMode) ...[
          // View toggle button
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: CustomIconWidget(
              iconName: _isGridView ? 'view_list' : 'grid_view',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          // Sort button
          IconButton(
            onPressed: _showSortBottomSheet,
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          // Bulk selection button
          IconButton(
            onPressed: () {
              setState(() {
                _isBulkSelectionMode = true;
              });
            },
            icon: CustomIconWidget(
              iconName: 'checklist',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedLabelColor:
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: AppTheme.lightTheme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Saved Listings'),
          Tab(text: 'Saved Searches'),
        ],
      ),
    );
  }

  Widget _buildSavedListingsTab() {
    if (_savedListings.isEmpty) {
      return EmptyStateWidget(
        title: 'No Saved Listings',
        description:
            'Start saving listings you\'re interested in to see them here. Tap the heart icon on any listing to save it.',
        buttonText: 'Browse Marketplace',
        iconName: 'favorite_border',
        onButtonPressed: () {
          Navigator.pushNamed(context, '/marketplace-home');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshListings,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: _isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      itemCount: _savedListings.length,
      itemBuilder: (context, index) {
        final listing = _savedListings[index];
        final isSelected = _selectedListingIds.contains(listing['id']);

        return _isBulkSelectionMode
            ? _buildSelectableListingCard(listing, isSelected, index)
            : SavedListingCard(
                listing: listing,
                onTap: () => _openListingDetail(listing),
                onDelete: () => _deleteListing(index),
                onFindSimilar: listing['status'] == 'expired'
                    ? () => _findSimilarListings(listing)
                    : null,
              );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.75,
      ),
      itemCount: _savedListings.length,
      itemBuilder: (context, index) {
        final listing = _savedListings[index];
        final isSelected = _selectedListingIds.contains(listing['id']);

        return _isBulkSelectionMode
            ? _buildSelectableGridCard(listing, isSelected, index)
            : _buildGridCard(listing, index);
      },
    );
  }

  Widget _buildSelectableListingCard(
      Map<String, dynamic> listing, bool isSelected, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Stack(
        children: [
          SavedListingCard(
            listing: listing,
            onTap: () => _toggleListingSelection(listing['id'] as int),
            onDelete: () => _deleteListing(index),
            onFindSimilar: listing['status'] == 'expired'
                ? () => _findSimilarListings(listing)
                : null,
          ),
          Positioned(
            top: 2.h,
            right: 6.w,
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.surface,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 4.w,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableGridCard(
      Map<String, dynamic> listing, bool isSelected, int index) {
    return Stack(
      children: [
        _buildGridCard(listing, index),
        Positioned(
          top: 2.w,
          right: 2.w,
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: isSelected
                ? Center(
                    child: CustomIconWidget(
                      iconName: 'check',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 3.w,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildGridCard(Map<String, dynamic> listing, int index) {
    final bool isExpired = listing['status'] == 'expired';
    final bool hasPriceDrop = listing['hasPriceDrop'] == true;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isBulkSelectionMode
            ? () => _toggleListingSelection(listing['id'] as int)
            : () => _openListingDetail(listing),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      CustomImageWidget(
                        imageUrl: listing['image'] as String,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (hasPriceDrop)
                        Positioned(
                          top: 2.w,
                          left: 2.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 1.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Price Drop',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onError,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['title'] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isExpired
                            ? AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6)
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      listing['price'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: isExpired
                            ? AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6)
                            : AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.w),
                    Text(
                      listing['location'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedSearchesTab() {
    if (_savedSearches.isEmpty) {
      return EmptyStateWidget(
        title: 'No Saved Searches',
        description:
            'Create custom search filters and save them to get notified when new matching listings are posted.',
        buttonText: 'Create Search',
        iconName: 'search',
        onButtonPressed: () {
          Navigator.pushNamed(context, '/search-and-filters');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshSearches,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: _savedSearches.length,
        itemBuilder: (context, index) {
          final search = _savedSearches[index];
          return SavedSearchCard(
            search: search,
            onEdit: () => _editSearch(search),
            onDelete: () => _deleteSearch(index),
            onNotificationToggle: (enabled) =>
                _toggleSearchNotifications(index, enabled),
          );
        },
      ),
    );
  }

  Widget _buildBulkActionsBar() {
    final selectedCount = _selectedListingIds.length;
    final isAllSelected = selectedCount == _savedListings.length;

    return BulkActionsBar(
      selectedCount: selectedCount,
      isAllSelected: isAllSelected,
      onSelectAll: _selectAllListings,
      onDeselectAll: _deselectAllListings,
      onDelete: _deleteSelectedListings,
      onShare: _shareSelectedListings,
      onCancel: () {
        setState(() {
          _isBulkSelectionMode = false;
          _selectedListingIds.clear();
        });
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheet(
        currentSortOption: _currentSortOption,
        onSortChanged: (option) {
          setState(() {
            _currentSortOption = option;
          });
          _applySorting();
        },
      ),
    );
  }

  void _applySorting() {
    setState(() {
      switch (_currentSortOption) {
        case 'recently_saved':
          // Already in order
          break;
        case 'price_low_high':
          _savedListings.sort((a, b) {
            final priceA = double.tryParse(
                    (a['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
                0;
            final priceB = double.tryParse(
                    (b['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
                0;
            return priceA.compareTo(priceB);
          });
          break;
        case 'price_high_low':
          _savedListings.sort((a, b) {
            final priceA = double.tryParse(
                    (a['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
                0;
            final priceB = double.tryParse(
                    (b['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
                0;
            return priceB.compareTo(priceA);
          });
          break;
        case 'distance':
        case 'date_posted':
          // Mock sorting - in real app would sort by actual distance/date
          break;
      }
    });
  }

  void _toggleListingSelection(int listingId) {
    setState(() {
      if (_selectedListingIds.contains(listingId)) {
        _selectedListingIds.remove(listingId);
      } else {
        _selectedListingIds.add(listingId);
      }
    });
  }

  void _selectAllListings() {
    setState(() {
      _selectedListingIds =
          _savedListings.map((listing) => listing['id'] as int).toSet();
    });
  }

  void _deselectAllListings() {
    setState(() {
      _selectedListingIds.clear();
    });
  }

  void _deleteSelectedListings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Selected Items',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedListingIds.length} selected items? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _savedListings.removeWhere(
                    (listing) => _selectedListingIds.contains(listing['id']));
                _selectedListingIds.clear();
                _isBulkSelectionMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected items deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // Implement undo functionality
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareSelectedListings() {
    final selectedListings = _savedListings
        .where((listing) => _selectedListingIds.contains(listing['id']))
        .toList();

    // Create shareable wishlist
    String shareText = 'My PromoHub Wishlist:\n\n';
    for (final listing in selectedListings) {
      shareText += '• ${listing['title']} - ${listing['price']}\n';
    }
    shareText += '\nShared from PromoHub - African Marketplace';

    // In a real app, would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wishlist copied to clipboard'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: () {
            // Implement actual sharing
          },
        ),
      ),
    );
  }

  void _openListingDetail(Map<String, dynamic> listing) {
    Navigator.pushNamed(context, '/listing-detail');
  }

  void _deleteListing(int index) {
    final listing = _savedListings[index];
    setState(() {
      _savedListings.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${listing['title']} removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _savedListings.insert(index, listing);
            });
          },
        ),
      ),
    );
  }

  void _findSimilarListings(Map<String, dynamic> listing) {
    Navigator.pushNamed(context, '/search-and-filters');
  }

  void _editSearch(Map<String, dynamic> search) {
    Navigator.pushNamed(context, '/search-and-filters');
  }

  void _deleteSearch(int index) {
    final search = _savedSearches[index];
    setState(() {
      _savedSearches.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Search "${search['title']}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _savedSearches.insert(index, search);
            });
          },
        ),
      ),
    );
  }

  void _toggleSearchNotifications(int index, bool enabled) {
    setState(() {
      _savedSearches[index]['notificationsEnabled'] = enabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(enabled
            ? 'Notifications enabled for this search'
            : 'Notifications disabled for this search'),
      ),
    );
  }

  Future<void> _refreshListings() async {
    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, would fetch updated data from API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorites updated'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _refreshSearches() async {
    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, would fetch updated search results
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search results updated'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
