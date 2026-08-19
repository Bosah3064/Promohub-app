import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/image_gallery_widget.dart';
import './widgets/location_info_widget.dart';
import './widgets/product_info_widget.dart';
import './widgets/seller_info_widget.dart';
import './widgets/similar_listings_widget.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final MarketplaceService _marketplaceService = MarketplaceService();
  bool _isFavorite = false;
  bool _isLoading = true;

  Map<String, dynamic> listingData = {};
  List<Map<String, dynamic>> similarListings = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadListingData();
    });
  }

  Future<void> _loadListingData() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? listingId;

    if (args is String) {
      listingId = args;
    } else if (args is Map<String, dynamic>) {
      listingId = args['id']?.toString();
      // If the full listing data is passed directly, use it
      if (args.containsKey('title')) {
        setState(() {
          listingData = args;
          _isLoading = false;
        });
        _loadSimilarListings(args['category_id']?.toString());
        return;
      }
    }

    if (listingId != null) {
      try {
        final data = await _marketplaceService.getListing(listingId);
        if (data != null && mounted) {
          setState(() {
            listingData = data;
            _isLoading = false;
          });
          _loadSimilarListings(data['category_id']?.toString());
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSimilarListings(String? categoryId) async {
    if (categoryId == null) return;
    try {
      final listings = await _marketplaceService.getListings(
        categoryId: categoryId,
        limit: 4,
      );
      if (mounted) {
        setState(() {
          similarListings = listings
              .where((l) => l['id'] != listingData['id'])
              .take(3)
              .toList();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    HapticFeedback.lightImpact();
  }

  void _shareListing() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing listing...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _reportListing() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Report this listing',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              title: Text('Inappropriate content'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              title: Text('Suspicious activity'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'block',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              title: Text('Spam or duplicate'),
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (listingData.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(iconName: 'search_off', color: Colors.grey, size: 64),
              SizedBox(height: 16),
              Text('Listing not found', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              Text('This listing may have been removed.'),
            ],
          ),
        ),
      );
    }

    // Extract images safely
    final images = listingData['images'];
    final List<String> imageList = images is List
        ? images.map((e) => e.toString()).toList()
        : [];

    // Extract seller safely
    final seller = listingData['seller_id'] is Map<String, dynamic>
        ? listingData['seller_id'] as Map<String, dynamic>
        : listingData['seller'] is Map<String, dynamic>
            ? listingData['seller'] as Map<String, dynamic>
            : <String, dynamic>{'name': 'Unknown Seller'};

    // Extract location safely
    final location = listingData['location'] is Map<String, dynamic>
        ? listingData['location'] as Map<String, dynamic>
        : <String, dynamic>{'city': listingData['location']?.toString() ?? 'Unknown'};

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 40.h,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: CustomIconWidget(
                        iconName: _isFavorite ? 'favorite' : 'favorite_border',
                        color: _isFavorite ? Colors.red : Colors.white,
                        size: 24,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PopupMenuButton(
                      icon: CustomIconWidget(
                        iconName: 'more_vert',
                        color: Colors.white,
                        size: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: _shareListing,
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'share',
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text('Share'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: _reportListing,
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'report',
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text('Report'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: imageList.isNotEmpty
                      ? ImageGalleryWidget(images: imageList)
                      : Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'image',
                              color: Colors.grey,
                              size: 64,
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    SellerInfoWidget(seller: seller),
                    SizedBox(height: 16),
                    ProductInfoWidget(listing: listingData),
                    SizedBox(height: 16),
                    LocationInfoWidget(location: location),
                    SizedBox(height: 16),
                    if (similarListings.isNotEmpty)
                      SimilarListingsWidget(listings: similarListings),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ActionButtonsWidget(seller: seller),
          ),
        ],
      ),
    );
  }
}
