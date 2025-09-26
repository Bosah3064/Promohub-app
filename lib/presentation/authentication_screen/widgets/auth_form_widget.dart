import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './custom_text_field_widget.dart';

class AuthFormWidget extends StatefulWidget {
  final bool isLogin;
  final Function(Map<String, String>) onSubmit;

  const AuthFormWidget({
    super.key,
    required this.isLogin,
    required this.onSubmit,
  });

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  String _selectedCountryCode = '+234';

  final List<Map<String, String>> _countryCodes = [
    {'code': '+234', 'country': 'NG', 'name': 'Nigeria'},
    {'code': '+254', 'country': 'KE', 'name': 'Kenya'},
    {'code': '+233', 'country': 'GH', 'name': 'Ghana'},
    {'code': '+1', 'country': 'US', 'name': 'United States'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email Field
            CustomTextFieldWidget(
              controller: _emailController,
              label: 'Email Address',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              validator: _validateEmail,
            ),

            SizedBox(height: 2.h),

            // Phone Field (only for sign up)
            if (!widget.isLogin) ...[
              Text(
                'Phone Number',
                style: AppTheme.lightTheme.textTheme.labelLarge,
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  // Country Code Picker
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        items: _countryCodes.map((country) {
                          return DropdownMenuItem<String>(
                            value: country['code'],
                            child: Text(
                              '${country['country']} ${country['code']}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryCode = value ?? '+234';
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Phone Number Field
                  Expanded(
                    child: CustomTextFieldWidget(
                      controller: _phoneController,
                      hintText: 'Phone number',
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],

            // Password Field
            CustomTextFieldWidget(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Enter your password',
              obscureText: !_isPasswordVisible,
              prefixIcon: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                child: CustomIconWidget(
                  iconName:
                      _isPasswordVisible ? 'visibility' : 'visibility_off',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              validator: _validatePassword,
            ),

            SizedBox(height: 2.h),

            // Confirm Password Field (only for sign up)
            if (!widget.isLogin) ...[
              CustomTextFieldWidget(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hintText: 'Confirm your password',
                obscureText: !_isConfirmPasswordVisible,
                prefixIcon: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  child: CustomIconWidget(
                    iconName: _isConfirmPasswordVisible
                        ? 'visibility'
                        : 'visibility_off',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
              SizedBox(height: 2.h),
            ],

            // Forgot Password Link (only for login)
            if (widget.isLogin) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle forgot password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent to your email'),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
            ],

            // Terms Acceptance (only for sign up)
            if (!widget.isLogin) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _acceptTerms = !_acceptTerms;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 1.5.h),
                        child: RichText(
                          text: TextSpan(
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isFormValid() ? _handleSubmit : null,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        widget.isLogin ? 'Login' : 'Create Account',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (!widget.isLogin && (value == null || value.isEmpty)) {
      return 'Phone number is required';
    }
    if (!widget.isLogin && value!.length < 10) {
      return 'Enter a valid phone number';
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

  String? _validateConfirmPassword(String? value) {
    if (!widget.isLogin && (value == null || value.isEmpty)) {
      return 'Please confirm your password';
    }
    if (!widget.isLogin && value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _isFormValid() {
    if (_isLoading) return false;

    if (widget.isLogin) {
      return _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    } else {
      return _emailController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _acceptTerms;
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      final credentials = {
        'email': _emailController.text,
        'phone': widget.isLogin
            ? ''
            : '$_selectedCountryCode${_phoneController.text}',
        'password': _passwordController.text,
      };

      widget.onSubmit(credentials);

      setState(() {
        _isLoading = false;
      });
    }
  }
}
