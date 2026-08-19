import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class ShopProfileScreen extends StatefulWidget {
  final String shopId;

  const ShopProfileScreen({super.key, required this.shopId});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final _firebaseService = FirebaseService();
  Map<String, dynamic>? _shopData;
  final List<Map<String, dynamic>> _shopProducts = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    try {
      final firestore = _firebaseService.firestore;
      final doc = await firestore.collection('shops').doc(widget.shopId).get();
      final data = doc.exists ? {'id': doc.id, ...?doc.data()} : null;

      final reviews = await _marketplaceService.getShopReviews(widget.shopId);

      if (mounted) {
        setState(() {
          _shopData = data;
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_shopData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Store Not Found')),
        body: const Center(child: Text('This store does not exist.')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: Text(_shopData!['name'],
              style:
                  TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {})
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowLight,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                AppTheme.primaryLight.withValues(alpha: 0.1),
                            child: Icon(Icons.store,
                                color: AppTheme.primaryLight, size: 30),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _shopData!['name'],
                                      style: AppTheme
                                          .lightTheme.textTheme.titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                    if (_shopData!['status'] == 'verified') ...[
                                      SizedBox(width: 1.5.w),
                                      Icon(Icons.verified,
                                          color: AppTheme.primaryLight,
                                          size: 18),
                                    ]
                                  ],
                                ),
                                SizedBox(height: 0.5.h),
                                Text(_shopData!['location'],
                                    style: TextStyle(
                                        color: AppTheme.textSecondaryLight)),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                          _shopData!['description'] ??
                              'No description provided.',
                          style: TextStyle(fontSize: 11.sp)),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                              'Rating', '⭐ ${_shopData!['rating']}'),
                          _buildStatColumn(
                              'Orders', '${_shopData!['completed_orders']}'),
                          _buildStatColumn('Reviews', '${_reviews.length}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: AppTheme.primaryLight,
                    unselectedLabelColor: AppTheme.textSecondaryLight,
                    indicatorColor: AppTheme.primaryLight,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontWeight: FontWeight.w800),
                    unselectedLabelStyle:
                        TextStyle(fontWeight: FontWeight.w500),
                    tabs: const [
                      Tab(text: 'Products'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Products Tab
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 60, color: AppTheme.dividerLight),
                    SizedBox(height: 2.h),
                    Text('Products will appear here',
                        style: TextStyle(color: AppTheme.textSecondaryLight)),
                  ],
                ),
              ),
              // Reviews Tab
              _reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_outline_rounded,
                              size: 60, color: AppTheme.dividerLight),
                          SizedBox(height: 2.h),
                          Text('No reviews yet',
                              style: TextStyle(
                                  color: AppTheme.textSecondaryLight)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(4.w),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        final reviewer =
                            review['reviewer'] as Map<String, dynamic>? ?? {};
                        return Container(
                          margin: EdgeInsets.only(bottom: 2.h),
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.shadowLight,
                                  blurRadius: 8,
                                  offset: Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: reviewer['avatar_url'] !=
                                            null
                                        ? NetworkImage(reviewer['avatar_url'])
                                        : null,
                                    backgroundColor: AppTheme.dividerLight,
                                    child: reviewer['avatar_url'] == null
                                        ? Icon(Icons.person,
                                            size: 20, color: Colors.white)
                                        : null,
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      reviewer['full_name'] ?? 'Verified Buyer',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < (review['rating'] ?? 0)
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              if (review['comment'] != null &&
                                  review['comment'].toString().isNotEmpty) ...[
                                SizedBox(height: 1.5.h),
                                Text(review['comment'],
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppTheme.textPrimaryLight)),
                              ]
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16.sp,
                color: AppTheme.primaryLight)),
        Text(label,
            style:
                TextStyle(color: AppTheme.textSecondaryLight, fontSize: 10.sp)),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
