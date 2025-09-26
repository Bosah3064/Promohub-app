import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/login_redirect_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';
import './widgets/social_signup_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Mock user data for demonstration
  final List<Map<String, dynamic>> _existingUsers = [
    {
      'email': 'john.doe@example.com',
      'phone': '+2348123456789',
      'fullName': 'John Doe',
    },
    {
      'email': 'jane.smith@example.com',
      'phone': '+2547123456789',
      'fullName': 'Jane Smith',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBackPressed() {
    Navigator.pop(context);
  }

  Future<void> _handleFormSubmit(Map<String, String> formData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if email already exists
      final emailExists = _existingUsers.any(
        (user) =>
            (user['email'] as String).toLowerCase() ==
            formData['email']!.toLowerCase(),
      );

      if (emailExists) {
        _showErrorMessage(
            'An account with this email already exists. Please use a different email or sign in.');
        return;
      }

      // Check if phone already exists
      final phoneExists = _existingUsers.any(
        (user) => user['phone'] == formData['phone'],
      );

      if (phoneExists) {
        _showErrorMessage(
            'An account with this phone number already exists. Please use a different number.');
        return;
      }

      // Simulate successful registration
      _showSuccessMessage('Account created successfully! Welcome to PromoHub.');

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to marketplace home after short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/marketplace-home');
      }
    } catch (e) {
      _showErrorMessage(
          'Network error. Please check your connection and try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSocialSignup(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate social signup delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful social signup
      _showSuccessMessage(
          'Successfully signed up with $provider! Welcome to PromoHub.');

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to marketplace home after short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/marketplace-home');
      }
    } catch (e) {
      _showErrorMessage('Failed to sign up with $provider. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLoginRedirect() {
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            RegistrationHeaderWidget(
              onBackPressed: _handleBackPressed,
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Registration Form
                    RegistrationFormWidget(
                      onFormSubmit: _handleFormSubmit,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 4.h),

                    // Social Signup Options
                    SocialSignupWidget(
                      onSocialSignup: _handleSocialSignup,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 4.h),

                    // Login Redirect
                    LoginRedirectWidget(
                      onLoginTap: _handleLoginRedirect,
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
