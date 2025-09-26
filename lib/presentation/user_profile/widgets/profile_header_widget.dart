import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userProfile;
  final VoidCallback onProfileImageTap;
  final VoidCallback onEditProfile;

  const ProfileHeaderWidget({
    super.key,
    required this.userProfile,
    required this.onProfileImageTap,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onProfileImageTap,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: userProfile["profileImage"] as String,
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userProfile["name"] as String,
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if ((userProfile["isVerified"] as bool))
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'verified',
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Verified',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Member since ${userProfile["memberSince"] as String}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return CustomIconWidget(
                              iconName: index <
                                      (userProfile["rating"] as double).floor()
                                  ? 'star'
                                  : 'star_border',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 16,
                            );
                          }),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${userProfile["rating"]} (${userProfile["reviewCount"]} reviews)',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildVerificationBadge(
                  'Phone',
                  userProfile["phoneVerified"] as bool,
                  'phone',
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildVerificationBadge(
                  'Email',
                  userProfile["emailVerified"] as bool,
                  'email',
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildVerificationBadge(
                  'ID',
                  userProfile["idVerified"] as bool,
                  'badge',
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEditProfile,
              icon: CustomIconWidget(
                iconName: 'edit',
                color: Colors.white,
                size: 18,
              ),
              label: Text('Edit Profile'),
              style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(
      String title, bool isVerified, String iconName) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: isVerified
            ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        border: Border.all(
          color: isVerified
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: isVerified
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: isVerified
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: isVerified ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
