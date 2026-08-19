import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import './widgets/category_chip_widget.dart';
import './widgets/featured_listing_card_widget.dart';
import './widgets/nearby_deal_card_widget.dart';
import './widgets/recent_listing_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _featuredPageController = PageController();
  int _currentBottomNavIndex = 0;
  int _currentFeaturedIndex = 0;

  // Dynamic data lists
  List<Map<String, dynamic>> featuredListings = [];
  List<Map<String, dynamic>> nearbyDeals = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> recentListings = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startFeaturedAutoScroll();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final marketplaceService = MarketplaceService();
      
      final results = await Future.wait([
        marketplaceService.getFeaturedListings(limit: 5),
        marketplaceService.getListings(limit: 4),
        marketplaceService.getCategories(),
        marketplaceService.getListings(limit: 3),
      ]);
      
      if (mounted) {
        setState(() {
          featuredListings = List<Map<String, dynamic>>.from(results[0]);
          nearbyDeals = List<Map<String, dynamic>>.from(results[1]);
          categories = List<Map<String, dynamic>>.from(results[2]);
          recentListings = List<Map<String, dynamic>>.from(results[3]);
          
          // Empty state handling will be done in the UI
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // We could show an error, but let's just leave them empty for now
      }
    }
  }

  void _startFeaturedAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _featuredPageController.hasClients && featuredListings.isNotEmpty) {
        final nextPage = (_currentFeaturedIndex + 1) % featuredListings.length;
        _featuredPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startFeaturedAutoScroll();
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Navigator.pushNamed(context, '/search-filters-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/create-listing-screen');
        break;
      case 3:
        // Navigate to Messages
        break;
      case 4:
        // Navigate to Profile
        break;
    }
  }

  void _onCategoryTap(int index) {
    setState(() {
      for (int i = 0; i < categories.length; i++) {
        categories[i]["isActive"] = i == index;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _featuredPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.primaryColor,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                )
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
              // Sticky Header
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 2,
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                title: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Lagos, Nigeria',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: CustomIconWidget(
                          iconName: 'notifications',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 2.w),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for anything...',
                                hintStyle: AppTheme
                                    .lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CustomIconWidget(
                                    iconName: 'search',
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: CustomIconWidget(
                                iconName: 'mic',
                                color: AppTheme.lightTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Featured Listings Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Listings',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('See All'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.w),
                    SizedBox(
                      height: 280,
                      child: PageView.builder(
                        controller: _featuredPageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentFeaturedIndex = index;
                          });
                        },
                        itemCount: featuredListings.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: FeaturedListingCardWidget(
                              listing: featuredListings[index],
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/listing-detail-screen');
                              },
                              onFavoriteToggle: () {
                                setState(() {
                                  featuredListings[index]["isFavorite"] =
                                      !featuredListings[index]["isFavorite"];
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 2.w),
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        featuredListings.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          width: _currentFeaturedIndex == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentFeaturedIndex == index
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme.lightTheme.colorScheme.outline,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Browse Categories',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.w),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 3.w),
                            child: CategoryChipWidget(
                              category: categories[index],
                              onTap: () => _onCategoryTap(index),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Nearby Deals Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nearby Deals',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('View All'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 3.w,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: nearbyDeals.length,
                        itemBuilder: (context, index) {
                          return NearbyDealCardWidget(
                            deal: nearbyDeals[index],
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/listing-detail-screen');
                            },
                            onFavoriteToggle: () {
                              setState(() {
                                nearbyDeals[index]["isFavorite"] =
                                    !nearbyDeals[index]["isFavorite"];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Listings Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Recent Listings',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.w),
                  ],
                ),
              ),

              // Recent Listings List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
                      child: RecentListingCardWidget(
                        listing: recentListings[index],
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/listing-detail-screen');
                        },
                        onFavoriteToggle: () {
                          setState(() {
                            recentListings[index]["isFavorite"] =
                                !recentListings[index]["isFavorite"];
                          });
                        },
                      ),
                    );
                  },
                  childCount: recentListings.length,
                ),
              ),

              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(height: 20.w),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.primaryColor,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentBottomNavIndex == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: _currentBottomNavIndex == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'add_circle',
              color: _currentBottomNavIndex == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'message',
              color: _currentBottomNavIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentBottomNavIndex == 4
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-listing-screen');
        },
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onSecondary,
          size: 28,
        ),
      ),
    );
  }
}
