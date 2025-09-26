import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionFeaturesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> plans;

  const SubscriptionFeaturesWidget({
    super.key,
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    // Extract all unique features from all plans
    final Set<String> allFeatures = {};
    for (final plan in plans) {
      final features = List<String>.from(plan['features'] ?? []);
      allFeatures.addAll(features);
    }

    final List<String> featureList = allFeatures.toList()..sort();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
            Text(
              'Feature Comparison',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 2.h),

            // Header Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Features',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                ...plans.map((plan) => Expanded(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getTierColor(plan['tier']).withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            plan['tier'].toString().toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: _getTierColor(plan['tier']),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),

            SizedBox(height: 1.h),

            Divider(color: Colors.grey[200]),

            SizedBox(height: 1.h),

            // Feature Rows
            ...featureList.map((feature) => _buildFeatureRow(feature, plans)),

            SizedBox(height: 2.h),

            // Product Limits Row
            _buildLimitRow('Product Listings', plans),

            SizedBox(height: 1.h),

            // Price Row
            _buildPriceRow(plans),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, List<Map<String, dynamic>> plans) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          ...plans.map((plan) {
            final planFeatures = List<String>.from(plan['features'] ?? []);
            final hasFeature = planFeatures.contains(feature);

            return Expanded(
              child: Center(
                child: Icon(
                  hasFeature ? Icons.check_circle : Icons.remove_circle,
                  size: 16.sp,
                  color: hasFeature ? Colors.green[600] : Colors.grey[400],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String label, List<Map<String, dynamic>> plans) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          ...plans.map((plan) {
            final limit = plan['product_limit'];
            final limitText = limit == null ? '∞' : limit.toString();

            return Expanded(
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: limit == null ? Colors.purple[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: limit == null
                          ? Colors.purple[200]!
                          : Colors.blue[200]!,
                    ),
                  ),
                  child: Text(
                    limitText,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          limit == null ? Colors.purple[700] : Colors.blue[700],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceRow(List<Map<String, dynamic>> plans) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: Text(
                'Monthly Price',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          ...plans.map((plan) {
            final priceKsh = plan['price_ksh'] as num;
            final priceUsd = plan['price_usd'] as num;
            final isFree = plan['tier'] == 'free';

            return Expanded(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      isFree ? 'FREE' : 'KSh ${priceKsh.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: isFree ? Colors.green[600] : Colors.grey[800],
                      ),
                    ),
                    if (!isFree)
                      Text(
                        '\$${priceUsd.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
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
