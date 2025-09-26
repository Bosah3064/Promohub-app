import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class RegistrationFormWidget extends StatefulWidget {
  final Function(Map<String, String>) onFormSubmit;
  final bool isLoading;

  const RegistrationFormWidget({
    super.key,
    required this.onFormSubmit,
    required this.isLoading,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true,
      _obscureConfirmPassword = true,
      _agreeToTerms = false;
  List<Map<String, String>> _countryCodes = [];
  String? _selectedCountryCode;
  String _passwordStrength = '', _passwordStrengthColorName = '';

  @override
  void initState() {
    super.initState();
    _loadCountryCodes();
  }

  Future<void> _loadCountryCodes() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/countryPhoneCodes.json',
      );

      final jsonData = json.decode(jsonString);

      if (jsonData is! List) {
        throw const FormatException('Invalid JSON format: Expected a List');
      }

      setState(() {
        _countryCodes = jsonData
            .map<Map<String, String>>((e) => {
                  'code': '+${e['code']?.toString() ?? ''}', // add "+" prefix
                  'country': e['country']?.toString() ?? '',
                  'flag': '', // No flag field in your JSON
                })
            .where((c) => c['code']!.isNotEmpty && c['country']!.isNotEmpty)
            .toList();

        if (_countryCodes.isEmpty) {
          debugPrint('⚠ No valid country codes found in JSON');
        }

        _selectedCountryCode =
            _countryCodes.isNotEmpty ? _countryCodes.first['code'] : null;
      });
    } on FlutterError catch (e) {
      debugPrint('❌ Asset loading failed: $e');
    } on FormatException catch (e) {
      debugPrint('❌ JSON format error: $e');
    } catch (e, stack) {
      debugPrint('❌ Unexpected error while loading country codes: $e');
      debugPrint(stack.toString());
    }
  }

  void _checkPasswordStrength(String password) {
    int score = (password.length >= 8 ? 1 : 0) +
        (RegExp(r'[A-Z]').hasMatch(password) ? 1 : 0) +
        (RegExp(r'[a-z]').hasMatch(password) ? 1 : 0) +
        (RegExp(r'\d').hasMatch(password) ? 1 : 0) +
        (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password) ? 1 : 0);

    setState(() {
      if (score <= 1) {
        _passwordStrength = 'Weak';
        _passwordStrengthColorName = 'error';
      } else if (score <= 3) {
        _passwordStrength = 'Medium';
        _passwordStrengthColorName = 'warning';
      } else {
        _passwordStrength = 'Strong';
        _passwordStrengthColorName = 'success';
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      widget.onFormSubmit({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': '${_selectedCountryCode ?? ''}${_phoneController.text.trim()}',
        'password': _passwordController.text,
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Please enter a valid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 6) return 'Enter a valid phone number';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters required';
    return null;
  }

  String? _validateConfirmPassword(String? val) {
    if (val == null || val.isEmpty) return 'Please confirm your password';
    if (val != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_countryCodes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final color = _passwordStrength.isEmpty
        ? Colors.grey
        : (_passwordStrengthColorName == 'error'
            ? AppTheme.lightTheme.colorScheme.error
            : _passwordStrengthColorName == 'warning'
                ? AppTheme.warningLight
                : AppTheme.successLight);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().length < 2)
                ? 'Enter a valid name'
                : null,
          ),
          SizedBox(height: 2.h),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email Address'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          SizedBox(height: 2.h),

          // Phone + Country Code
          Row(
            children: [
              SizedBox(
                width: 25.w,
                child: DropdownButtonFormField<String>(
                  isExpanded: true, // ✅ ensures full width usage
                  value: _selectedCountryCode,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12), // ✅ increases height
                  ),
                  items: _countryCodes
                      .map((c) => DropdownMenuItem(
                            value: c['code'],
                            child: Row(
                              children: [
                                if ((c['flag'] ?? '').isNotEmpty)
                                  Text(c['flag']!,
                                      style: TextStyle(fontSize: 16.sp)),
                                SizedBox(width: 1.w),
                                Text(c['code']!,
                                    style: TextStyle(fontSize: 12.sp)),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCountryCode = v),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12), // ✅ match dropdown height
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: _validatePhone,
                ),
              ),
            ],
          ),
          // Password & Strength
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: _validatePassword,
            onChanged: _checkPasswordStrength,
          ),
          if (_passwordStrength.isNotEmpty) ...[
            SizedBox(height: 0.5.h),
            Row(children: [
              Text('Password strength: ', style: TextStyle(fontSize: 12.sp)),
              Text(_passwordStrength,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: color,
                      fontWeight: FontWeight.w500)),
            ]),
          ],
          SizedBox(height: 2.h),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: _validateConfirmPassword,
          ),
          SizedBox(height: 3.h),

          // Terms & Submit
          Row(
            children: [
              Checkbox(
                  value: _agreeToTerms,
                  onChanged: (v) => setState(() => _agreeToTerms = v!)),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('I agree to the '),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _agreeToTerms = !_agreeToTerms),
                      child: Text('Terms of Service',
                          style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              decoration: TextDecoration.underline)),
                    ),
                    const Text(' and '),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _agreeToTerms = !_agreeToTerms),
                      child: Text('Privacy Policy',
                          style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _agreeToTerms && !widget.isLoading ? _submitForm : null,
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary)),
                    )
                  : Text('Create Account', style: TextStyle(fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }
}
