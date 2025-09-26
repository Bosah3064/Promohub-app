import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/image_gallery_widget.dart';
import './widgets/make_offer_bottom_sheet.dart';
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
  bool _isFavorite = false;
  late Map<String, dynamic> _currentListing;
  late Map<String, dynamic> _seller;
  late List<Map<String, dynamic>> _similarListings;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _currentListing = {
      "id": "PH001",
      "title": "iPhone 14 Pro Max - 256GB Space Black",
      "price": "\$1,200",
      "originalPrice": "\$1,399",
      "description":
          """Excellent condition iPhone 14 Pro Max with 256GB storage in Space Black. 
      
This phone has been my daily driver for 8 months and is in pristine condition. Always kept in a case with screen protector. Battery health is at 94%. 

Includes:
- Original box and documentation
- Lightning to USB-C cable
- 20W USB-C power adapter
- Clear case and screen protector (already applied)

No scratches, dents, or damage. Fully unlocked and works with all carriers. Perfect for someone looking for a premium iPhone at a great price.

Reason for selling: Upgrading to iPhone 15 Pro Max.""",
      "translatedDescription":
          """Excellent condition iPhone 14 Pro Max na 256GB hifadhi katika Space Black.

Simu hii imekuwa simu yangu ya kila siku kwa miezi 8 na iko katika hali nzuri sana. Daima imehifadhiwa katika kesi na kinga ya skrini. Afya ya betri iko 94%.

Inajumuisha:
- Sanduku la asili na nyaraka
- Kebo ya Lightning hadi USB-C
- Adapta ya nguvu ya 20W USB-C
- Kesi wazi na kinga ya skrini (tayari imewekwa)

Hakuna michubuko, mikunjo, au uharibifu. Imefunguliwa kabisa na inafanya kazi na wauzaji wote. Kamili kwa mtu anayetafuta iPhone ya hali ya juu kwa bei nzuri.

Sababu ya kuuza: Kuboresha hadi iPhone 15 Pro Max.""",
      "category": "Electronics",
      "condition": "Like New",
      "location": "Lagos, Nigeria",
      "distance": "2.5 km",
      "mapThumbnail":
          "https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&w=400",
      "postedDate": "3 days ago",
      "viewCount": 247,
      "listingId": "PH001",
      "images": [
        "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=800",
        "https://images.pexels.com/photos/1275229/pexels-photo-1275229.jpeg?auto=compress&cs=tinysrgb&w=800",
        "https://images.pexels.com/photos/3999538/pexels-photo-3999538.jpeg?auto=compress&cs=tinysrgb&w=800",
        "https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg?auto=compress&cs=tinysrgb&w=800",
      ],
    };

    _seller = {
      "id": "seller_001",
      "name": "Adebayo Johnson",
      "profileImage":
          "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400",
      "rating": 4.8,
      "reviewCount": 156,
      "isVerified": true,
      "responseTime": "2 hours",
      "phoneNumber": "+234 801 234 5678",
      "memberSince": "2021",
      "totalListings": 23,
    };

    _similarListings = [
      {
        "id": "PH002",
        "title": "iPhone 13 Pro - 128GB Blue",
        "price": "\$950",
        "location": "Abuja, Nigeria",
        "postedDate": "1 day ago",
        "images": [
          "https://images.pexels.com/photos/1275229/pexels-photo-1275229.jpeg?auto=compress&cs=tinysrgb&w=400"
        ],
      },
      {
        "id": "PH003",
        "title": "Samsung Galaxy S23 Ultra",
        "price": "\$1,100",
        "location": "Port Harcourt, Nigeria",
        "postedDate": "5 days ago",
        "images": [
          "https://images.pexels.com/photos/3999538/pexels-photo-3999538.jpeg?auto=compress&cs=tinysrgb&w=400"
        ],
      },
      {
        "id": "PH004",
        "title": "iPhone 14 - 128GB Purple",
        "price": "\$850",
        "location": "Kano, Nigeria",
        "postedDate": "1 week ago",
        "images": [
          "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=400"
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
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
            onMessageSeller: () {
              Navigator.pushNamed(context, '/messages-and-chat');
            },
            onMakeOffer: _showMakeOfferBottomSheet,
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

  void _showMakeOfferBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MakeOfferBottomSheet(
          currentPrice: _currentListing["price"] as String,
          onOfferSubmitted: () {
            // Handle offer submission
          },
        ),
      ),
    );
  }
}
