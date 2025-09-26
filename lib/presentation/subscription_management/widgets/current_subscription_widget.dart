import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrentSubscriptionWidget extends StatelessWidget {
  final Map<String, dynamic> subscriptionStats;
  final VoidCallback onManage;

  const CurrentSubscriptionWidget({
    super.key,
    required this.subscriptionStats,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final tier = subscriptionStats['tier'] as String;
    final planName = subscriptionStats['plan_name'] as String;
    final currentListings = subscriptionStats['current_listings'] as int;
    final listingLimit = subscriptionStats['listing_limit'] as int?;
    final isUnlimited = subscriptionStats['is_unlimited'] as bool;
    final daysRemaining = subscriptionStats['days_remaining'] as int;
    final features = List<String>.from(subscriptionStats['features'] ?? []);

    final Color tierColor = _getTierColor(tier);
    final double usagePercent = isUnlimited
        ? 0.0
        : listingLimit != null
            ? (currentListings / listingLimit).clamp(0.0, 1.0)
            : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tierColor.withAlpha(26), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tierColor.withAlpha(77)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: tierColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tier.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                if (daysRemaining > 0)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: daysRemaining <= 3
                          ? Colors.orange[100]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: daysRemaining <= 3
                            ? Colors.orange[300]!
                            : Colors.green[300]!,
                      ),
                    ),
                    child: Text(
                      '$daysRemaining days left',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: daysRemaining <= 3
                            ? Colors.orange[700]
                            : Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 2.h),

            // Plan Name and Price
            Text(
              planName,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),

            if (tier != 'free') ...[
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Text(
                    'KSh ${subscriptionStats['price_ksh']?.toStringAsFixed(0) ?? '0'}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    ' / month',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 3.h),

            // Usage Statistics
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Listings Used',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        isUnlimited
                            ? '$currentListings / ∞'
                            : '$currentListings / ${listingLimit ?? 0}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: tierColor,
                        ),
                      ),
                    ],
                  ),
                  if (!isUnlimited) ...[
                    SizedBox(height: 1.h),
                    LinearProgressIndicator(
                      value: usagePercent,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        usagePercent >= 0.9
                            ? Colors.red[400]!
                            : usagePercent >= 0.7
                                ? Colors.orange[400]!
                                : tierColor,
                      ),
                      minHeight: 8,
                    ),
                    SizedBox(height: 1.h),
                    if (usagePercent >= 0.8)
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 14.sp,
                              color: Colors.orange[700],
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                usagePercent >= 1.0
                                    ? 'Listing limit reached! Upgrade to create more listings.'
                                    : 'Approaching listing limit. Consider upgrading.',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Key Features
            if (features.isNotEmpty) ...[
              Text(
                'Your Plan Includes:',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: features
                    .take(3)
                    .map((feature) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: tierColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: tierColor.withAlpha(77)),
                          ),
                          child: Text(
                            feature,
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              color: tierColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],

            SizedBox(height: 3.h),

            // Action Buttons
            Row(
              children: [
                if (tier != 'premium')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/subscription-management');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tierColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                      child: Text(
                        'Upgrade Plan',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (tier != 'premium') SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onManage,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: tierColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: Text(
                      'Manage',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: tierColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'free':
        return Colors.green[600]!;
      case 'standard':
        return Colors.blue[600]!;
      case 'premium':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
