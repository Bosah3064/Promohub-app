import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class UpgradeBenefitsWidget extends StatelessWidget {
  final String currentTier;

  const UpgradeBenefitsWidget({
    super.key,
    required this.currentTier,
  });

  @override
  Widget build(BuildContext context) {
    final benefits = _getBenefitsForUpgrade(currentTier);

    if (benefits.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock More Potential',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'See what you can achieve with an upgrade',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Benefits Grid
            ...benefits.map((benefit) => Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: benefit['color'].withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          benefit['icon'] as IconData,
                          size: 16.sp,
                          color: benefit['color'] as Color,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benefit['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              benefit['description'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (benefit['highlight'] != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: benefit['color'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            benefit['highlight'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),

            SizedBox(height: 2.h),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () {
                  // Scroll to plans or navigate to upgrade
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Upgrade Options',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.arrow_forward, size: 16.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getBenefitsForUpgrade(String currentTier) {
    switch (currentTier.toLowerCase()) {
      case 'free':
        return [
          {
            'icon': Icons.inventory_2,
            'title': '30 Listings with Standard',
            'description':
                'Expand from 7 to 30 product listings to grow your business',
            'color': Colors.blue[600],
            'highlight': '4x More',
          },
          {
            'icon': Icons.star,
            'title': 'Featured Listings',
            'description':
                'Get your products seen by more buyers with priority placement',
            'color': Colors.orange[600],
            'highlight': 'NEW',
          },
          {
            'icon': Icons.analytics,
            'title': 'Enhanced Analytics',
            'description':
                'Track views, favorites, and conversion rates for better insights',
            'color': Colors.green[600],
            'highlight': null,
          },
          {
            'icon': Icons.all_inclusive,
            'title': 'Go Unlimited with Premium',
            'description':
                'No limits on listings plus advanced marketing tools',
            'color': Colors.purple[600],
            'highlight': '∞',
          },
        ];
      case 'standard':
        return [
          {
            'icon': Icons.all_inclusive,
            'title': 'Unlimited Listings',
            'description':
                'Remove all restrictions and list as many products as you want',
            'color': Colors.purple[600],
            'highlight': '∞',
          },
          {
            'icon': Icons.palette,
            'title': 'Custom Branding',
            'description':
                'Personalize your seller profile with custom colors and branding',
            'color': Colors.indigo[600],
            'highlight': 'NEW',
          },
          {
            'icon': Icons.api,
            'title': 'API Access',
            'description':
                'Integrate with your existing systems using our developer API',
            'color': Colors.teal[600],
            'highlight': 'PRO',
          },
          {
            'icon': Icons.support_agent,
            'title': '24/7 Priority Support',
            'description':
                'Get instant help whenever you need it with premium support',
            'color': Colors.red[600],
            'highlight': '24/7',
          },
        ];
      default:
        return [];
    }
  }
}
