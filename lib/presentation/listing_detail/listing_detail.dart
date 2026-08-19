import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/image_gallery_widget.dart';
import './widgets/product_details_widget.dart';
import './widgets/safety_tips_banner_widget.dart';
import './widgets/seller_info_card_widget.dart';
import './widgets/similar_listings_widget.dart';

class ListingDetail extends StatefulWidget {
  const ListingDetail({super.key});

  @override
  State<ListingDetail> createState() => _ListingDetailState();
}

class _ListingDetailState extends State<ListingDetail> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  bool _isLoading = true;
  bool _hasError = false;
  bool _isAddingToCart = false;
  bool _isFavorite = false;
  Map<String, dynamic> _currentListing = {};
  Map<String, dynamic> _seller = {};
  List<Map<String, dynamic>> _similarListings = [];

  @override
  void initState() {
    super.initState();
    // Defer so we can access ModalRoute.of(context)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final listingId = ModalRoute.of(context)?.settings.arguments as String?;

    if (listingId != null && listingId.isNotEmpty) {
      try {
        final listing = await _marketplaceService.getListing(listingId);
        if (listing != null && mounted) {
          final sellerData =
              listing['seller_id'] as Map<String, dynamic>? ?? {};
          setState(() {
            _currentListing = {
              "id": listing['id'],
              "title": listing['title'] ?? 'Product',
              "price": 'KSh ${listing['price']}',
              "description": listing['description'] ?? '',
              "category": (listing['category_id'] is Map)
                  ? listing['category_id']['name']
                  : 'General',
              "condition": listing['condition'] ?? 'Used',
              "location": listing['location'] ?? '',
              "postedDate": 'Recently',
              "viewCount": listing['views'] ?? 0,
              "listingId": listing['id']?.toString() ?? '',
              "images": (listing['images'] is List && (listing['images'] as List).isNotEmpty)
                  ? (listing['images'] as List).map((e) => e.toString()).toList()
                  : [
                      "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=800",
                    ],
            };
            _seller = {
              "id": sellerData['id'] ?? '',
              "name": sellerData['full_name'] ?? 'Seller',
              "profileImage": sellerData['avatar_url'] ?? '',
              "rating": sellerData['rating'] ?? 0,
              "reviewCount": 0,
              "isVerified": true,
              "responseTime": "< 1 hour",
              "phoneNumber": sellerData['phone'] ?? '',
              "memberSince": "2024",
              "totalListings": 0,
            };
            _isLoading = false;
          });
          // Load similar listings in background
          _loadSimilarListings(listing['category_id'] is Map
              ? listing['category_id']['id']
              : null);
          return;
        }
      } catch (e) {
        debugPrint('Failed to load listing: $e');
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
}

  Future<void> _loadSimilarListings(String? categoryId) async {
    try {
      final listings = await _marketplaceService.getListings(
        categoryId: categoryId,
        limit: 4,
      );
      if (mounted) {
        setState(() {
          _similarListings = listings
              .where((l) => l['id'] != _currentListing['id'])
              .take(3)
              .map((l) {
            String imageUrl = "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=400";
            if (l['images'] is List && (l['images'] as List).isNotEmpty) {
              imageUrl = (l['images'] as List)[0]?.toString() ?? imageUrl;
            }

            return {
              "id": l['id']?.toString() ?? '',
              "title": l['title']?.toString() ?? 'Unknown',
              "price": 'KSh ${l['price']?.toString() ?? '0'}',
              "location": l['location']?.toString() ?? '',
              "postedDate": "Recently",
              "images": [imageUrl],
            };
          }).toList();
        });
      }
    } catch (e) {
      // Keep similar listings empty on error
    }
  }

  

  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);
    try {
      await _marketplaceService.addToCart(_currentListing['id'], 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to cart'),
            action: SnackBarAction(
              label: 'VIEW CART',
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  Future<void> _buyNow() async {
    await _addToCart();
    if (mounted) {
      Navigator.pushNamed(context, '/checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppTheme.textPrimaryLight,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.lightTheme.colorScheme.error),
              SizedBox(height: 16),
              Text('Failed to load listing', style: AppTheme.lightTheme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppTheme.textPrimaryLight,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery
                      ImageGalleryWidget(
                        images: (_currentListing["images"] as List<String>),
                        heroTag: "listing_${_currentListing["id"]}",
                      ),

                      // Seller Info Card
                      SellerInfoCardWidget(
                        seller: _seller,
                        onViewProfile: () {
                          Navigator.pushNamed(context, '/user-profile');
                        },
                      ),

                      // Product Details
                      ProductDetailsWidget(
                        product: _currentListing,
                      ),

                      SizedBox(height: 2.h),

                      // Safety Tips Banner
                      SafetyTipsBannerWidget(),

                      // Similar Listings
                      SimilarListingsWidget(
                        similarListings: _similarListings,
                        onListingTap: (listing) {
                          // Navigate to another listing detail
                          Navigator.pushNamed(context, '/listing-detail');
                        },
                      ),

                      SizedBox(height: 10.h), // Space for bottom actions
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          ActionButtonsWidget(
            seller: _seller,
            isAddingToCart: _isAddingToCart,
            onMessageSeller: () {
              Navigator.pushNamed(context, '/messages-and-chat');
            },
            onAddToCart: _addToCart,
            onBuyNow: _buyNow,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 6.w,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Listing Details',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'share',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: _shareListing,
        ),
        IconButton(
          icon: CustomIconWidget(
            iconName: _isFavorite ? 'favorite' : 'favorite_border',
            color: _isFavorite
                ? Colors.red
                : AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: _toggleFavorite,
        ),
        PopupMenuButton<String>(
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
          onSelected: _handleMenuAction,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'report',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'report',
                    color: Colors.red,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Report Listing',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'block',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'block',
                    color: Colors.red,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Block Seller',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: _isFavorite ? 'favorite' : 'favorite_border',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Text(
              _isFavorite ? 'Added to favorites' : 'Removed from favorites',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _shareListing() async {
    final String shareText = '''
Check out this ${_currentListing["title"]} for ${_currentListing["price"]} on PromoHub!

${_currentListing["description"].toString().substring(0, 100)}...

Download PromoHub to see more details and contact the seller.
''';

    try {
      await Share.share(
        shareText,
        subject: 'Check out this listing on PromoHub',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to share listing'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        _showReportDialog();
        break;
      case 'block':
        _showBlockDialog();
        break;
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Report Listing',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why are you reporting this listing?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              ...[
                'Inappropriate content',
                'Spam or fake listing',
                'Overpriced item',
                'Suspicious seller',
                'Other'
              ].map((reason) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      reason,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _submitReport(reason);
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Block Seller',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to block ${_seller["name"]}? You won\'t see their listings anymore.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _blockSeller();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Block',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitReport(String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Report submitted. We\'ll review this listing.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _blockSeller() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'block',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                '${_seller["name"]} has been blocked.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}
