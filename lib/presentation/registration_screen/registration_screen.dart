import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/login_redirect_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';
import './widgets/social_signup_widget.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // No mock users needed

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
      final email = formData['email']!;
      final password = formData['password']!;
      final fullName = formData['fullName']!;
      final phone = formData['phone']!;

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(fullName);
        await FirebaseFirestore.instance.collection('user_profiles').doc(userCredential.user!.uid).set({
          'full_name': fullName,
          'phone': phone,
          'created_at': FieldValue.serverTimestamp(),
        });

        _showSuccessMessage(
            'Account created successfully! Welcome to PromoHub.');
        HapticFeedback.lightImpact();

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/marketplace-home');
        }
      } else {
        _showErrorMessage('Registration failed. Please try again.');
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      final errorStr = e.toString();
      
      if (errorStr.contains('already registered') || errorStr.contains('user_already_exists')) {
        _showErrorMessage('An account with this email already exists. Please sign in instead.');
      } else {
        _showErrorMessage(
            'Registration successful! Please check your email inbox to confirm your account.');
      }
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

                    // Registration Form Card
                    Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowLight,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: RegistrationFormWidget(
                        onFormSubmit: _handleFormSubmit,
                        isLoading: _isLoading,
                      ),
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
