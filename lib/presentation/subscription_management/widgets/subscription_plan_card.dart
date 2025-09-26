import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isCurrentPlan;
  final VoidCallback onUpgrade;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isPopular = plan['is_popular'] == true;
    final isPremium = plan['tier'] == 'premium';
    final isFree = plan['tier'] == 'free';
    final features = List<String>.from(plan['features'] ?? []);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan
              ? Colors.blue[300]!
              : isPopular
                  ? Colors.orange[300]!
                  : Colors.grey[200]!,
          width: isCurrentPlan || isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['name'],
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            plan['description'],
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPremium)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple[400]!, Colors.purple[600]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '⭐ PREMIUM',
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Pricing
                if (isFree) ...[
                  Text(
                    'FREE',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.green[600],
                    ),
                  ),
                  Text(
                    'Forever',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'KSh ${plan['price_ksh'].toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '/month',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'USD \$${plan['price_usd'].toStringAsFixed(2)}/month',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],

                SizedBox(height: 2.h),

                // Product Limit
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isPremium ? Colors.purple[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isPremium ? Colors.purple[200]! : Colors.blue[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        plan['product_limit'] == null
                            ? Icons.all_inclusive
                            : Icons.inventory_2,
                        size: 16.sp,
                        color:
                            isPremium ? Colors.purple[600] : Colors.blue[600],
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        plan['product_limit'] == null
                            ? 'Unlimited Listings'
                            : '${plan['product_limit']} Listings',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isPremium ? Colors.purple[700] : Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // Features
                Text(
                  'Features:',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 1.h),

                ...features.take(4).map((feature) => Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14.sp,
                            color: Colors.green[600],
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                if (features.length > 4)
                  Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: Text(
                      '+${features.length - 4} more features',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                SizedBox(height: 3.h),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : onUpgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? Colors.grey[300]
                          : isPremium
                              ? Colors.purple[600]
                              : isPopular
                                  ? Colors.orange[600]
                                  : Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrentPlan
                          ? 'Current Plan'
                          : isFree
                              ? 'Switch to Free'
                              : 'Upgrade Now',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Popular Badge
          if (isPopular && !isCurrentPlan)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'POPULAR',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Current Plan Badge
          if (isCurrentPlan)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
