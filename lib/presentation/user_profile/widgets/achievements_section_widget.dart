import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AchievementsSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final bool isOwnProfile;

  const AchievementsSectionWidget({
    super.key,
    required this.achievements,
    this.isOwnProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withAlpha(26),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  '${achievements.length} Earned',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.2,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index]['achievement'];
              return _buildAchievementCard(achievement);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final badgeColor = _parseColor(achievement['badge_color'] ?? '#4CAF50');

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: badgeColor.withAlpha(77),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: achievement['icon_url'] != null
                ? ClipOval(
                    child: Image.network(
                      achievement['icon_url'],
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.emoji_events,
                          color: badgeColor,
                          size: 6.w,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.emoji_events,
                    color: badgeColor,
                    size: 6.w,
                  ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            achievement['name'] ?? 'Achievement',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            achievement['description'] ?? '',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (achievement['points'] != null && achievement['points'] > 0) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(26),
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Text(
                '+${achievement['points']} pts',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 15.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            isOwnProfile ? 'No Achievements Yet' : 'No Achievements to Show',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            isOwnProfile
                ? 'Complete your first sale or purchase to earn your first achievement!'
                : 'This user has not earned any achievements yet.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4CAF50); // Default green
    }
  }
}
