import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/active_listings_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/reviews_section_widget.dart';
import './widgets/statistics_cards_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final bool _isCurrentUser = true; // Toggle for viewing own profile vs others

  // Mock user profile data
  final Map<String, dynamic> userProfile = {
    "id": "user_12345",
    "name": "Amara Okafor",
    "profileImage":
        "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
    "memberSince": "January 2023",
    "rating": 4.8,
    "reviewCount": 127,
    "isVerified": true,
    "phoneVerified": true,
    "emailVerified": true,
    "idVerified": false,
    "bio":
        "Passionate entrepreneur selling quality electronics and home goods. Fast shipping and excellent customer service guaranteed!",
    "location": "Lagos, Nigeria",
    "responseTime": "< 2 hours",
    "languages": ["English", "Yoruba", "Hausa"],
  };

  // Mock user statistics
  final Map<String, dynamic> userStats = {
    "totalListings": 45,
    "successfulSales": 38,
    "responseTime": "< 2 hours",
    "userRating": 4.8,
    "joinDate": "2023-01-15",
    "lastActive": "2 hours ago",
  };

  // Mock active listings
  final List<Map<String, dynamic>> activeListings = [
    {
      "id": "listing_001",
      "title": "iPhone 14 Pro Max - Excellent Condition",
      "price": "₦850,000",
      "image":
          "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Active",
      "views": 234,
      "likes": 18,
      "datePosted": "2025-01-25",
    },
    {
      "id": "listing_002",
      "title": "Samsung 55\" 4K Smart TV",
      "price": "₦420,000",
      "image":
          "https://images.pexels.com/photos/1201996/pexels-photo-1201996.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Pending",
      "views": 156,
      "likes": 12,
      "datePosted": "2025-01-22",
    },
    {
      "id": "listing_003",
      "title": "MacBook Air M2 - Like New",
      "price": "₦1,200,000",
      "image":
          "https://images.pexels.com/photos/205421/pexels-photo-205421.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Active",
      "views": 89,
      "likes": 7,
      "datePosted": "2025-01-20",
    },
  ];

  // Mock reviews data
  final List<Map<String, dynamic>> reviews = [
    {
      "id": "review_001",
      "reviewerName": "Kemi Adebayo",
      "reviewerAvatar":
          "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400",
      "rating": 5,
      "comment":
          "Excellent seller! The phone was exactly as described and shipping was super fast. Highly recommend!",
      "date": "Jan 28, 2025",
      "transaction": {
        "itemName": "iPhone 13 Pro",
        "itemImage":
            "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=400",
        "price": "₦650,000",
      },
    },
    {
      "id": "review_002",
      "reviewerName": "Chidi Okonkwo",
      "reviewerAvatar":
          "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400",
      "rating": 4,
      "comment":
          "Good communication and fair pricing. Item arrived in good condition. Would buy again.",
      "date": "Jan 25, 2025",
      "transaction": {
        "itemName": "Wireless Headphones",
        "itemImage":
            "https://images.pexels.com/photos/3394650/pexels-photo-3394650.jpeg?auto=compress&cs=tinysrgb&w=400",
        "price": "₦45,000",
      },
    },
    {
      "id": "review_003",
      "reviewerName": "Fatima Hassan",
      "reviewerAvatar":
          "https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg?auto=compress&cs=tinysrgb&w=400",
      "rating": 5,
      "comment":
          "Amazing seller! Very professional and the laptop works perfectly. Thank you!",
      "date": "Jan 20, 2025",
      "transaction": null,
    },
  ];

  // Mock rating breakdown
  final Map<String, dynamic> ratingBreakdown = {
    "averageRating": 4.8,
    "totalReviews": 127,
    "breakdown": {
      "5": 78.0,
      "4": 15.0,
      "3": 5.0,
      "2": 1.5,
      "1": 0.5,
    },
  };

  // Mock achievements
  final List<Map<String, dynamic>> achievements = [
    {
      "id": "badge_001",
      "type": "top_seller",
      "title": "Top Seller",
      "description": "Sold 25+ items",
      "icon": "trending_up",
      "earnedDate": "2025-01-15",
    },
    {
      "id": "badge_002",
      "type": "quick_responder",
      "title": "Quick Responder",
      "description": "Responds within 2 hours",
      "icon": "flash_on",
      "earnedDate": "2025-01-10",
    },
    {
      "id": "badge_003",
      "type": "trusted_buyer",
      "title": "Trusted Member",
      "description": "Verified account",
      "icon": "verified_user",
      "earnedDate": "2025-01-05",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeaderWidget(
              userProfile: userProfile,
              onProfileImageTap: _showFullScreenImage,
              onEditProfile: _editProfile,
            ),
            SizedBox(height: 3.h),
            StatisticsCardsWidget(userStats: userStats),
            SizedBox(height: 3.h),
            ActiveListingsWidget(
              activeListings: activeListings,
              onEditListing: _editListing,
              onViewListing: _viewListing,
            ),
            SizedBox(height: 3.h),
            ReviewsSectionWidget(
              reviews: reviews,
              ratingBreakdown: ratingBreakdown,
            ),
            SizedBox(height: 3.h),
            AchievementBadgesWidget(achievements: achievements),
            SizedBox(height: 3.h),
            if (!_isCurrentUser) _buildActionButtons(),
            SizedBox(height: 3.h),
          ],
        ),
      ),
      floatingActionButton:
          _isCurrentUser ? _buildFloatingActionButton() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title:
          Text(_isCurrentUser ? 'My Profile' : userProfile["name"] as String),
      actions: [
        if (_isCurrentUser) ...[
          IconButton(
            onPressed: _openSettings,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ] else ...[
          IconButton(
            onPressed: _shareProfile,
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'report',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Report User'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'block',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Block User'),
                  ],
                ),
              ),
            ],
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _sendMessage,
              icon: CustomIconWidget(
                iconName: 'message',
                color: AppTheme.lightTheme.primaryColor,
                size: 18,
              ),
              label: Text('Message'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _viewListings,
              icon: CustomIconWidget(
                iconName: 'store',
                color: Colors.white,
                size: 18,
              ),
              label: Text('View Store'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _createListing,
      icon: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 24,
      ),
      label: Text('Create Listing'),
    );
  }

  void _showFullScreenImage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: userProfile["profileImage"] as String,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5.h,
              right: 5.w,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    Navigator.pushNamed(context, '/settings-and-account-management');
  }

  void _editListing(Map<String, dynamic> listing) {
    Navigator.pushNamed(context, '/create-listing');
  }

  void _viewListing(Map<String, dynamic> listing) {
    Navigator.pushNamed(context, '/listing-detail');
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings-and-account-management');
  }

  void _shareProfile() {
    // Share profile functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile link copied to clipboard')),
    );
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
      builder: (context) => AlertDialog(
        title: Text('Report User'),
        content: Text(
            'Are you sure you want to report this user for inappropriate behavior?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User reported successfully')),
              );
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text(
            'Are you sure you want to block this user? You won\'t see their listings or receive messages from them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User blocked successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Block'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    Navigator.pushNamed(context, '/messages-and-chat');
  }

  void _viewListings() {
    Navigator.pushNamed(context, '/marketplace-home');
  }

  void _createListing() {
    Navigator.pushNamed(context, '/create-listing');
  }
}
