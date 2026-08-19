import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_prompt.dart';
import './widgets/login_form_field.dart';
import './widgets/login_header.dart';
import './widgets/social_login_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  bool _showBiometricPrompt = false;
  String? _emailError;
  String? _passwordError;

  // No mock credentials needed anymore

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or phone number is required';
    }

    // Check if it's a phone number (starts with +)
    if (value.startsWith('+')) {
      if (value.length < 10) {
        return 'Please enter a valid phone number';
      }
      return null;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  bool _isFormValid() {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null;
  }

  Future<void> _signIn() async {
    setState(() {
      _showEmailError = true;
      _showPasswordError = true;
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (!_isFormValid()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final response = await FirebaseService().signIn(
        email: email,
        password: password,
      );

      if (response != null) {
        // Save email for next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);

        HapticFeedback.lightImpact();

        // Check if biometric is supported and prompt if not already configured
        // For simplicity, just navigating to home now
        _navigateToHome();
      } else {
        _showErrorMessage('Invalid email or password. Please try again.');
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('email_not_confirmed') ||
          errorStr.contains('Email not confirmed')) {
        _showErrorMessage(
            'Please check your email and click the confirmation link to sign in.');
      } else {
        _showErrorMessage(
            'Login failed. Please check your credentials and try again.');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/marketplace-home');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate social login
      await Future.delayed(const Duration(seconds: 1));

      HapticFeedback.lightImpact();
      _navigateToHome();
    } catch (e) {
      _showErrorMessage('$provider login failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _enableBiometric() {
    setState(() {
      _showBiometricPrompt = false;
    });
    _navigateToHome();
  }

  void _skipBiometric() {
    setState(() {
      _showBiometricPrompt = false;
    });
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const LoginHeader(),
                  SizedBox(height: 4.h),

                  // Login Form Card
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          LoginFormField(
                            label: 'Email or Phone',
                            hint: 'Enter your email or phone number',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            validator: _validateEmail,
                            showError: _showEmailError,
                            errorText: _emailError,
                          ),
                          SizedBox(height: 2.h),

                          LoginFormField(
                            label: 'Password',
                            hint: 'Enter your password',
                            isPassword: true,
                            controller: _passwordController,
                            validator: _validatePassword,
                            showError: _showPasswordError,
                            errorText: _passwordError,
                          ),
                          SizedBox(height: 1.h),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.forgotPassword);
                              },
                              child: Text(
                                'Forgot Password?',
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Sign In Button
                          GestureDetector(
                            onTap: _isLoading ? null : _signIn,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 6.h,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryLight
                                        .withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Text(
                                  'Or continue with',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),

                          // Social Login Buttons
                          SocialLoginButton(
                            iconName: 'g_translate',
                            label: 'Continue with Google',
                            onPressed: _isLoading
                                ? () {}
                                : () => _handleSocialLogin('Google'),
                          ),
                          SocialLoginButton(
                            iconName: 'apple',
                            label: 'Continue with Apple',
                            onPressed: _isLoading
                                ? () {}
                                : () => _handleSocialLogin('Apple'),
                          ),
                          SocialLoginButton(
                            iconName: 'facebook',
                            label: 'Continue with Facebook',
                            onPressed: _isLoading
                                ? () {}
                                : () => _handleSocialLogin('Facebook'),
                          ),
                          SizedBox(height: 4.h),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to PromoHub? ',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/registration-screen');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Biometric Prompt Overlay
            if (_showBiometricPrompt)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: BiometricPrompt(
                    onBiometricPressed: _enableBiometric,
                    onSkipPressed: _skipBiometric,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
