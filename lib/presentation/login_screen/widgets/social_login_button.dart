import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  // Map icon names to SVG asset paths and brand colors
  String? _getSvgPath() {
    switch (iconName) {
      case 'g_translate':
        return 'assets/icons/google_logo.svg';
      case 'facebook':
        return 'assets/icons/facebook_logo.svg';
      case 'apple':
        return 'assets/icons/apple_logo.svg';
      default:
        return null;
    }
  }

  Color _getBrandColor() {
    switch (iconName) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'apple':
        return Colors.black;
      default:
        return AppTheme.textPrimaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final svgPath = _getSvgPath();
    final brandColor = _getBrandColor();
    final isGoogle = iconName == 'g_translate';
    final isFacebook = iconName == 'facebook';
    final isApple = iconName == 'apple';

    return Container(
      width: double.infinity,
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 0.6.h),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isApple
              ? Colors.black
              : isFacebook
                  ? const Color(0xFF1877F2)
                  : Colors.white,
          foregroundColor: (isApple || isFacebook) ? Colors.white : Colors.black87,
          side: BorderSide(
            color: isGoogle
                ? Colors.grey.shade300
                : (isApple ? Colors.black : const Color(0xFF1877F2)),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgPath != null)
              SizedBox(
                width: 22,
                height: 22,
                child: SvgPicture.asset(
                  svgPath,
                  width: 22,
                  height: 22,
                ),
              )
            else
              CustomIconWidget(
                iconName: iconName,
                color: (isApple || isFacebook) ? Colors.white : brandColor,
                size: 22,
              ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: (isApple || isFacebook) ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
