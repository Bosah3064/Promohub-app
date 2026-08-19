import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 6.h),
        // PromoHub Logo
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                color: AppTheme.primaryLight,
                child: Center(
                  child: Icon(Icons.storefront, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            'Welcome Back',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: Colors.white, // Color is ignored because of ShaderMask, but required to render
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Sign in to continue to your marketplace',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
