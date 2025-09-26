import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AchievementBadgesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;

  const AchievementBadgesWidget({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements & Badges',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            children: achievements
                .map((achievement) => _buildBadge(achievement))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(Map<String, dynamic> achievement) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getBadgeColor(achievement["type"] as String),
            _getBadgeColor(achievement["type"] as String)
                .withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getBadgeColor(achievement["type"] as String)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: achievement["icon"] as String,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            achievement["title"] as String,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (achievement["description"] != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              achievement["description"] as String,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Color _getBadgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'top_seller':
        return Color(0xFFFFD700); // Gold
      case 'trusted_buyer':
        return AppTheme.lightTheme.primaryColor;
      case 'quick_responder':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'verified_seller':
        return Color(0xFF4CAF50);
      case 'milestone':
        return Color(0xFF9C27B0);
      default:
        return AppTheme.lightTheme.colorScheme.tertiary;
    }
  }
}
