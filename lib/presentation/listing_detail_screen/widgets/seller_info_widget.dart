import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class SellerInfoWidget extends StatelessWidget {
  final Map<String, dynamic> seller;

  const SellerInfoWidget({
    super.key,
    required this.seller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: seller["avatar"] as String,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (seller["isVerified"] == true)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'verified',
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        seller["name"] as String,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (seller["isVerified"] == true)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Verified',
                          style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        double rating = (seller["rating"] as double? ?? 0.0);
                        return CustomIconWidget(
                          iconName:
                              index < rating.floor() ? 'star' : 'star_border',
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${seller["rating"]} (${seller["reviewCount"]} reviews)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  seller["responseTime"] as String? ??
                      'Response time not available',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              // Navigate to seller profile
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening seller profile...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'View Profile',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
