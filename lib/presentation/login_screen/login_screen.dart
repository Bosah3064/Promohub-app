import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/biometric_prompt.dart';
import './widgets/login_form_field.dart';
import './widgets/login_header.dart';
import './widgets/social_login_button.dart';

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

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'buyer@promohub.com': 'buyer123',
    'seller@promohub.com': 'seller123',
    'admin@promohub.com': 'admin123',
    '+234123456789': 'mobile123',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadSavedCredentials() {
    // Simulate loading saved email/phone from secure storage
    _emailController.text = 'buyer@promohub.com';
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

      // Check mock credentials
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_mockCredentials.containsKey(email) &&
          _mockCredentials[email] == password) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        // Show biometric prompt for first-time login
        if (email == 'buyer@promohub.com') {
          setState(() {
            _showBiometricPrompt = true;
          });
        } else {
          _navigateToHome();
        }
      } else {
        // Invalid credentials
        _showErrorMessage('Invalid email/phone or password. Please try again.');
      }
    } catch (e) {
      _showErrorMessage(
          'Network error. Please check your connection and try again.');
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

                  // Login Form
                  Form(
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
                              // Navigate to forgot password
                              _showErrorMessage(
                                  'Forgot password feature coming soon!');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading || !_isFormValid() ? null : _signIn,
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme
                                            .lightTheme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelLarge
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
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
                                color: AppTheme.lightTheme.colorScheme.outline,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                'Or continue with',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
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
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign Up',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
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
