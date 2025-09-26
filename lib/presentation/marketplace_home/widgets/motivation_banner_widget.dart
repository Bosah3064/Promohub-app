import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class MotivationBannerWidget extends StatelessWidget {
  final String userName;
  final int totalSales;
  final int totalPurchases;
  final double rating;
  final VoidCallback? onViewAchievements;

  const MotivationBannerWidget({
    super.key,
    required this.userName,
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.rating = 0.0,
    this.onViewAchievements,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey $userName! 👋',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _getMotivationalMessage(),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sell,
                  label: 'Sales',
                  value: totalSales.toString(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.shopping_cart,
                  label: 'Purchases',
                  value: totalPurchases.toString(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  label: 'Rating',
                  value: rating.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          if (onViewAchievements != null) ...[
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewAchievements,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6C63FF),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
                child: Text(
                  'View Achievements',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 5.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.white.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    if (totalSales == 0 && totalPurchases == 0) {
      return 'Ready to start your marketplace journey?';
    } else if (totalSales >= 10) {
      return 'You are a power seller! Keep it up!';
    } else if (totalSales >= 5) {
      return 'Great progress! You are building a reputation!';
    } else if (totalSales >= 1) {
      return 'Awesome! You made your first sale!';
    } else if (totalPurchases >= 5) {
      return 'Great buyer! Consider selling some items too!';
    } else {
      return 'Explore amazing deals and start trading!';
    }
  }
}
