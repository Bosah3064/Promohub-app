import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricPrompt extends StatelessWidget {
  final VoidCallback onBiometricPressed;
  final VoidCallback onSkipPressed;

  const BiometricPrompt({
    super.key,
    required this.onBiometricPressed,
    required this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'fingerprint',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 32,
          ),
          SizedBox(height: 1.h),
          Text(
            'Enable Biometric Login',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Use your fingerprint or face to sign in quickly and securely',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onSkipPressed,
                  child: Text('Skip'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBiometricPressed,
                  child: Text('Enable'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
