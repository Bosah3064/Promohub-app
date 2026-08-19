import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';

class SocialLoginButton extends StatelessWidget {
  final String iconName;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginButton({
    super.key,
    required this.iconName,
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

    return Tooltip(
      message: isGoogle
          ? 'Google'
          : isFacebook
              ? 'Facebook'
              : 'Apple',
      child: SizedBox(
        width: 58,
        height: 58,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: isApple
                ? Colors.black
                : isFacebook
                    ? const Color(0xFF1877F2)
                    : Colors.white,
            foregroundColor:
                (isApple || isFacebook) ? Colors.white : Colors.black87,
            side: BorderSide(
              color: isGoogle
                  ? Colors.grey.shade300
                  : (isApple ? Colors.black : const Color(0xFF1877F2)),
              width: 1.0,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            padding: EdgeInsets.zero,
          ),
          child: svgPath != null
              ? SvgPicture.asset(svgPath, width: 24, height: 24)
              : CustomIconWidget(
                  iconName: iconName,
                  color: (isApple || isFacebook) ? Colors.white : brandColor,
                  size: 24,
                ),
        ),
      ),
    );
  }
}
