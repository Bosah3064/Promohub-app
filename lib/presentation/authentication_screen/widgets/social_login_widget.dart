import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  const SocialLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        Text(
          'Continue with',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),

        SizedBox(height: 2.h),

        // Social Login Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              context: context,
              iconName: 'g_translate', // Using Google icon
              label: 'Google',
              onTap: () => _handleSocialLogin(context, 'Google'),
            ),
            _buildSocialButton(
              context: context,
              iconName: 'apple', // Using Apple icon
              label: 'Apple',
              onTap: () => _handleSocialLogin(context, 'Apple'),
            ),
            _buildSocialButton(
              context: context,
              iconName: 'facebook', // Using Facebook icon
              label: 'Facebook',
              onTap: () => _handleSocialLogin(context, 'Facebook'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String iconName,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25.w,
        height: 6.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: _getIconColor(label),
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(String provider) {
    switch (provider) {
      case 'Google':
        return const Color(0xFF4285F4);
      case 'Apple':
        return const Color(0xFF000000);
      case 'Facebook':
        return const Color(0xFF1877F2);
      default:
        return AppTheme.lightTheme.colorScheme.onSurface;
    }
  }

  void _handleSocialLogin(BuildContext context, String provider) {
    // Mock social login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login initiated'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );

    // Simulate successful social login
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/home-screen');
    });
  }
}
