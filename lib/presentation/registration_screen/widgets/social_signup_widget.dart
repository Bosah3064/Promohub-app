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
                  fontSize: 16.0,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              context: context,
              svgPath: 'assets/icons/google_logo.svg',
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              borderColor: Colors.grey.shade300,
              onTap: () => onSocialSignup('google'),
            ),
            SizedBox(width: 4.w),
            _buildSocialButton(
              context: context,
              svgPath: 'assets/icons/facebook_logo.svg',
              backgroundColor: const Color(0xFF1877F2),
              textColor: Colors.white,
              borderColor: const Color(0xFF1877F2),
              onTap: () => onSocialSignup('facebook'),
            ),
            SizedBox(width: 4.w),
            _buildSocialButton(
              context: context,
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
    required String svgPath,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final providerName = svgPath.contains('google')
        ? 'Google'
        : svgPath.contains('facebook')
            ? 'Facebook'
            : 'Apple';
    return Tooltip(
      message: providerName,
      child: SizedBox(
        width: 58,
        height: 58,
        child: OutlinedButton(
          onPressed: isLoading ? null : onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            side: BorderSide(color: borderColor, width: 1),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: SizedBox(
            width: 22,
            height: 22,
            child: SvgPicture.asset(
              svgPath,
              width: 22,
              height: 22,
            ),
          ),
        ),
      ),
    );
  }
}
