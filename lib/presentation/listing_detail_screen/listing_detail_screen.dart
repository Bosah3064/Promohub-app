import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  bool _isFavorite = false;

  // Mock listing data
  final Map<String, dynamic> listingData = {
    "id": 1,
    "title": "iPhone 14 Pro Max - 256GB Space Black",
    "price": "₦850,000",
    "originalPrice": "₦950,000",
    "condition": "Like New",
    "category": "Electronics > Mobile Phones > Apple",
    "description":
        """Selling my iPhone 14 Pro Max in excellent condition. Used for only 6 months with screen protector and case from day one. 

Features:
• 256GB Storage
• Space Black Color
• 48MP Camera System
• A16 Bionic Chip
• 6.7-inch Super Retina XDR Display

Includes original box, charger, and unused EarPods. No scratches or dents. Battery health at 98%. Reason for sale: upgrading to iPhone 15 Pro Max.

Serious buyers only. Price slightly negotiable.""",
    "images": [
      "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg",
      "https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg",
      "https://images.pexels.com/photos/1440727/pexels-photo-1440727.jpeg",
      "https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg"
    ],
    "seller": {
      "id": 101,
      "name": "Ahmed Okafor",
      "avatar":
          "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg",
      "rating": 4.8,
      "reviewCount": 127,
      "isVerified": true,
      "joinDate": "2022-03-15",
      "responseTime": "Usually responds within 2 hours"
    },
    "location": {
      "city": "Lagos",
      "state": "Lagos State",
      "area": "Victoria Island",
      "distance": "2.3 km away",
      "coordinates": {"lat": 6.4281, "lng": 3.4219}
    },
    "postedDate": "2024-01-15T10:30:00Z",
    "views": 1247,
    "likes": 89,
    "isPromoted": true,
    "tags": ["negotiable", "original-box", "warranty"]
  };

  final List<Map<String, dynamic>> similarListings = [
    {
      "id": 2,
      "title": "iPhone 13 Pro - 128GB Blue",
      "price": "₦650,000",
      "image":
          "https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg",
      "condition": "Excellent",
      "distance": "1.8 km"
    },
    {
      "id": 3,
      "title": "Samsung Galaxy S23 Ultra",
      "price": "₦780,000",
      "image":
          "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg",
      "condition": "Like New",
      "distance": "3.2 km"
    },
    {
      "id": 4,
      "title": "iPhone 14 - 256GB Purple",
      "price": "₦720,000",
      "image":
          "https://images.pexels.com/photos/1440727/pexels-photo-1440727.jpeg",
      "condition": "Good",
      "distance": "4.1 km"
    }
  ];

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
    // Share functionality would be implemented here
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
                  background: ImageGalleryWidget(
                    images: (listingData["images"] as List).cast<String>(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    SellerInfoWidget(
                      seller: listingData["seller"] as Map<String, dynamic>,
                    ),
                    SizedBox(height: 16),
                    ProductInfoWidget(
                      listing: listingData,
                    ),
                    SizedBox(height: 16),
                    LocationInfoWidget(
                      location: listingData["location"] as Map<String, dynamic>,
                    ),
                    SizedBox(height: 16),
                    SimilarListingsWidget(
                      listings: similarListings,
                    ),
                    SizedBox(height: 100), // Space for bottom actions
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ActionButtonsWidget(
              seller: listingData["seller"] as Map<String, dynamic>,
            ),
          ),
        ],
      ),
    );
  }
}
