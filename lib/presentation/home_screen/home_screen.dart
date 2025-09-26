import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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

  // Mock data for featured listings
  final List<Map<String, dynamic>> featuredListings = [
    {
      "id": 1,
      "title": "iPhone 14 Pro Max - Like New",
      "price": "₦850,000",
      "image":
          "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg",
      "location": "Victoria Island, Lagos",
      "distance": "2.5 km",
      "isVip": true,
      "sellerRating": 4.8,
      "isFavorite": false,
    },
    {
      "id": 2,
      "title": "MacBook Pro M2 - Excellent Condition",
      "price": "₦1,200,000",
      "image": "https://images.pexels.com/photos/18105/pexels-photo.jpg",
      "location": "Ikeja, Lagos",
      "distance": "5.2 km",
      "isVip": true,
      "sellerRating": 4.9,
      "isFavorite": true,
    },
    {
      "id": 3,
      "title": "Toyota Camry 2020 - Low Mileage",
      "price": "₦15,500,000",
      "image":
          "https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg",
      "location": "Lekki, Lagos",
      "distance": "8.1 km",
      "isVip": true,
      "sellerRating": 4.7,
      "isFavorite": false,
    },
  ];

  // Mock data for nearby deals
  final List<Map<String, dynamic>> nearbyDeals = [
    {
      "id": 4,
      "title": "Samsung Galaxy S23",
      "price": "₦450,000",
      "image":
          "https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg",
      "location": "Surulere, Lagos",
      "distance": "3.2 km",
      "sellerRating": 4.6,
      "isFavorite": false,
    },
    {
      "id": 5,
      "title": "Dell XPS 13 Laptop",
      "price": "₦680,000",
      "image": "https://images.pexels.com/photos/18105/pexels-photo.jpg",
      "location": "Yaba, Lagos",
      "distance": "4.8 km",
      "sellerRating": 4.5,
      "isFavorite": true,
    },
    {
      "id": 6,
      "title": "Nike Air Jordan 1",
      "price": "₦85,000",
      "image":
          "https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg",
      "location": "Ikoyi, Lagos",
      "distance": "1.9 km",
      "sellerRating": 4.8,
      "isFavorite": false,
    },
    {
      "id": 7,
      "title": "PlayStation 5 Console",
      "price": "₦320,000",
      "image":
          "https://images.pexels.com/photos/275033/pexels-photo-275033.jpeg",
      "location": "Ajah, Lagos",
      "distance": "12.5 km",
      "sellerRating": 4.7,
      "isFavorite": false,
    },
  ];

  // Mock data for categories
  final List<Map<String, dynamic>> categories = [
    {"name": "Electronics", "icon": "devices", "isActive": false},
    {"name": "Vehicles", "icon": "directions_car", "isActive": false},
    {"name": "Fashion", "icon": "checkroom", "isActive": false},
    {"name": "Real Estate", "icon": "home", "isActive": false},
    {"name": "Jobs", "icon": "work", "isActive": false},
    {"name": "Services", "icon": "build", "isActive": false},
  ];

  // Mock data for recent listings
  final List<Map<String, dynamic>> recentListings = [
    {
      "id": 8,
      "title": "Vintage Leather Sofa Set",
      "price": "₦180,000",
      "image":
          "https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg",
      "location": "Gbagada, Lagos",
      "distance": "7.3 km",
      "sellerRating": 4.4,
      "isFavorite": false,
      "timePosted": "2 hours ago",
    },
    {
      "id": 9,
      "title": "Canon EOS R5 Camera",
      "price": "₦1,850,000",
      "image": "https://images.pexels.com/photos/90946/pexels-photo-90946.jpeg",
      "location": "Maryland, Lagos",
      "distance": "6.1 km",
      "sellerRating": 4.9,
      "isFavorite": true,
      "timePosted": "4 hours ago",
    },
    {
      "id": 10,
      "title": "Mountain Bike - Trek",
      "price": "₦125,000",
      "image":
          "https://images.pexels.com/photos/100582/pexels-photo-100582.jpeg",
      "location": "Festac, Lagos",
      "distance": "15.2 km",
      "sellerRating": 4.3,
      "isFavorite": false,
      "timePosted": "6 hours ago",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startFeaturedAutoScroll();
  }

  void _startFeaturedAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _featuredPageController.hasClients) {
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
    setState(() {});
    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {});
    }
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
          child: CustomScrollView(
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
