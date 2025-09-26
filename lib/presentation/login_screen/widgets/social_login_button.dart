import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginButton extends StatelessWidget {
  final String iconName;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginButton({
    super.key,
    required this.iconName,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? AppTheme.lightTheme.colorScheme.surface,
          foregroundColor:
              textColor ?? AppTheme.lightTheme.colorScheme.onSurface,
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        ),
        icon: CustomIconWidget(
          iconName: iconName,
          color: textColor ?? AppTheme.lightTheme.colorScheme.onSurface,
          size: 20,
        ),
        label: Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: textColor ?? AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
