import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialSignupWidget extends StatelessWidget {
  final Function(String provider) onSocialSignup;
  final bool isLoading;

  const SocialSignupWidget({
    super.key,
    required this.onSocialSignup,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.dividerColor,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.dividerColor,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Social Signup Buttons
        Column(
          children: [
            // Google Sign Up
            _buildSocialButton(
              context: context,
              provider: 'Google',
              icon: 'g_translate',
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              borderColor: Colors.grey.shade300,
              onTap: () => onSocialSignup('google'),
            ),
            SizedBox(height: 2.h),

            // Facebook Sign Up
            _buildSocialButton(
              context: context,
              provider: 'Facebook',
              icon: 'facebook',
              backgroundColor: const Color(0xFF1877F2),
              textColor: Colors.white,
              borderColor: const Color(0xFF1877F2),
              onTap: () => onSocialSignup('facebook'),
            ),
            SizedBox(height: 2.h),

            // Apple Sign Up (iOS only, but shown for demo)
            _buildSocialButton(
              context: context,
              provider: 'Apple',
              icon: 'apple',
              backgroundColor: Colors.black,
              textColor: Colors.white,
              borderColor: Colors.black,
              onTap: () => onSocialSignup('apple'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String provider,
    required String icon,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: textColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Continue with $provider',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
