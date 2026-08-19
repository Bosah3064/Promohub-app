import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
              svgPath: 'assets/icons/google_logo.svg',
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
              svgPath: 'assets/icons/facebook_logo.svg',
              backgroundColor: const Color(0xFF1877F2),
              textColor: Colors.white,
              borderColor: const Color(0xFF1877F2),
              onTap: () => onSocialSignup('facebook'),
            ),
            SizedBox(height: 2.h),

            // Apple Sign Up
            _buildSocialButton(
              context: context,
              provider: 'Apple',
              svgPath: 'assets/icons/apple_logo.svg',
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
    required String svgPath,
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
            SizedBox(
              width: 22,
              height: 22,
              child: SvgPicture.asset(
                svgPath,
                width: 22,
                height: 22,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Continue with $provider',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
