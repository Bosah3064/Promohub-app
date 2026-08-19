import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
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

  final MarketplaceService _marketplaceService = MarketplaceService();

  Map<String, dynamic>? _userShop;
  bool _isLoadingShop = true;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _profileSubscription;

  // User profile data (starts with mock, updated in initState)
  Map<String, dynamic> userProfile = {
    "id": "user_12345",
    "name": "User",
    "profileImage": "",
    "memberSince": "Today",
    "rating": 5.0,
    "reviewCount": 0,
    "isVerified": false,
    "phoneVerified": false,
    "emailVerified": false,
    "idVerified": false,
    "bio": "New to PromoHub!",
    "location": "Not specified",
    "responseTime": "< 2 hours",
    "languages": ["English"],
  };

  @override
  void initState() {
    super.initState();
    _loadUserShop();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _profileSubscription = FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(userId)
          .snapshots()
          .listen(_applyProfileSnapshot);
    }
  }

  void _applyProfileSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!mounted || !snapshot.exists) return;
    final data = snapshot.data()!;
    final createdAt = data['created_at'];
    setState(() {
      userProfile['name'] = data['full_name'] ?? userProfile['name'];
      userProfile['profileImage'] = data['avatar_url'] ??
          FirebaseAuth.instance.currentUser?.photoURL ??
          '';
      userProfile['phoneVerified'] = data['phone_verified'] == true;
      userProfile['idVerified'] = data['id_verified'] == true;
      userProfile['isVerified'] = data['is_verified'] == true;
      userProfile['bio'] = data['bio'] ?? userProfile['bio'];
      userProfile['location'] = data['location'] ?? userProfile['location'];
      if (createdAt is Timestamp) {
        final date = createdAt.toDate();
        userProfile['memberSince'] = '${date.day}/${date.month}/${date.year}';
      }
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserShop() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (user != null) {
        final email = user.email ?? 'No email';
        final phone = user.phoneNumber ?? 'No phone';
        final name = user.displayName ?? email.split('@')[0];

        setState(() {
          userProfile['name'] = name;
          userProfile['emailVerified'] = user.emailVerified;
          userProfile['phoneVerified'] = phone != 'No phone';
          userProfile['id'] = user.uid;
          userProfile['profileImage'] =
              user.photoURL ?? userProfile['profileImage'];
        });
      }

      if (userId != null) {
        final shop = await _marketplaceService.getUserShop(userId);
        final listings =
            await _marketplaceService.getListingsBySellerId(userId);
        if (mounted) {
          setState(() {
            _userShop = shop;
            activeListings = listings;
            userStats["totalListings"] = listings.length;

            // Format data for the UI
            for (var i = 0; i < activeListings.length; i++) {
              if (activeListings[i]['images'] != null &&
                  (activeListings[i]['images'] as List).isNotEmpty) {
                activeListings[i]['image'] = activeListings[i]['images'][0];
              } else {
                activeListings[i]['image'] =
                    'https://images.unsplash.com/photo-1560393464-5c69a73c5770'; // fallback
              }

              // Format price
              final price = activeListings[i]['price'];
              activeListings[i]['price'] = '₦$price';

              // Add missing mock fields expected by the widget
              activeListings[i]['views'] = activeListings[i]['view_count'] ?? 0;
              activeListings[i]['likes'] = 0;
            }

            _isLoadingShop = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingShop = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingShop = false);
    }
  }

  // User statistics
  Map<String, dynamic> userStats = {
    "totalListings": 0,
    "successfulSales": 0,
    "responseTime": "N/A",
    "userRating": 0.0,
    "joinDate": "Unknown",
    "lastActive": "Just now",
  };

  // Active listings
  List<Map<String, dynamic>> activeListings = [];

  // Reviews data (empty state since we don't have review fetch implemented yet)
  final List<Map<String, dynamic>> reviews = [];

  // Computed rating breakdown (empty state)
  final Map<String, dynamic> ratingBreakdown = {
    "averageRating": 0.0,
    "totalReviews": 0,
    "breakdown": {
      "5": 0.0,
      "4": 0.0,
      "3": 0.0,
      "2": 0.0,
      "1": 0.0,
    },
  };

  // Computed achievements
  final List<Map<String, dynamic>> achievements = [
    {
      "id": "badge_003",
      "type": "trusted_buyer",
      "title": "Trusted Member",
      "description": "Verified account",
      "icon": "verified_user",
      "earnedDate":
          DateTime.now().toString().split(' ')[0], // Computed basic badge
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
            SizedBox(height: 2.h),
            if (!_isLoadingShop)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton.icon(
                    icon: Icon(
                        _userShop != null ? Icons.store : Icons.add_business),
                    label: Text(_userShop != null
                        ? 'Seller Dashboard'
                        : 'Become a Seller'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (_userShop != null) {
                        Navigator.pushNamed(context, '/seller-dashboard',
                            arguments: _userShop!['id']);
                      } else {
                        Navigator.pushNamed(context, '/seller-registration')
                            .then((_) => _loadUserShop());
                      }
                    },
                  ),
                ),
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
