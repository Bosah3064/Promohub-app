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
  String _passwordStrength = '';
  double _passwordStrengthValue = 0;
  Color _passwordStrengthColor = Colors.grey;

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
                  'code': '+${e['code']?.toString() ?? ''}',
                  'country': e['country']?.toString() ?? '',
                  'flag': '',
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
      if (password.isEmpty) {
        _passwordStrength = '';
        _passwordStrengthValue = 0;
        _passwordStrengthColor = Colors.grey;
      } else if (score <= 1) {
        _passwordStrength = 'Weak';
        _passwordStrengthValue = 0.25;
        _passwordStrengthColor = AppTheme.errorLight;
      } else if (score <= 3) {
        _passwordStrength = 'Medium';
        _passwordStrengthValue = 0.55;
        _passwordStrengthColor = AppTheme.warningLight;
      } else {
        _passwordStrength = 'Strong';
        _passwordStrengthValue = 1.0;
        _passwordStrengthColor = AppTheme.successLight;
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      widget.onFormSubmit({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone':
            '${_selectedCountryCode ?? ''}${_phoneController.text.trim()}',
        'password': _passwordController.text,
      });
    }
  }

  void _showCountryPickerBottomSheet() {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final filteredCountries = _countryCodes.where((c) {
              final query = searchQuery.toLowerCase();
              return c['country']!.toLowerCase().contains(query) ||
                  c['code']!.contains(query);
            }).toList();

            return Container(
              height: 70.h,
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
              child: Column(
                children: [
                  Container(
                    width: 12.w,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Select Country',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search country or code...',
                      prefixIcon:
                          Icon(Icons.search, color: AppTheme.primaryLight),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredCountries.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final isSelected =
                            country['code'] == _selectedCountryCode;
                        return ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 2.w),
                          title: Text(
                            country['country']!,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.primaryLight
                                  : AppTheme.textPrimaryLight,
                            ),
                          ),
                          trailing: Text(
                            country['code']!,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: AppTheme.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCountryCode = country['code'];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  Widget _buildFieldLabel(String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryLight),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_countryCodes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name
          _buildFieldLabel('Full Name', Icons.person_outline),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.badge_outlined,
                  color: AppTheme.textSecondaryLight, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 1.6.h),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().length < 2)
                ? 'Enter a valid name'
                : null,
          ),
          SizedBox(height: 2.5.h),

          // Email
          _buildFieldLabel('Email Address', Icons.email_outlined),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.alternate_email,
                  color: AppTheme.textSecondaryLight, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 1.6.h),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          SizedBox(height: 2.5.h),

          // Phone + Country Code
          _buildFieldLabel('Phone Number', Icons.phone_outlined),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 26.w,
                child: GestureDetector(
                  onTap: _showCountryPickerBottomSheet,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.5.w, vertical: 1.65.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.05),
                      border: Border.all(
                          color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCountryCode ?? '+1',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.unfold_more,
                            color: AppTheme.primaryLight, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 1.6.h),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: _validatePhone,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),

          // Password & Strength
          _buildFieldLabel('Password', Icons.lock_outline),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 1.6.h),
              prefixIcon: Icon(Icons.lock_outline,
                  color: AppTheme.textSecondaryLight, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondaryLight,
                  size: 20,
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
            SizedBox(height: 1.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _passwordStrengthValue,
                backgroundColor: AppTheme.dividerLight,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                minHeight: 4,
              ),
            ),
            SizedBox(height: 0.5.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _passwordStrength,
                style: TextStyle(
                  fontSize: 12.0,
                  color: _passwordStrengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SizedBox(height: 2.5.h),

          // Confirm Password
          _buildFieldLabel('Confirm Password', Icons.lock_outline),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              hintText: 'Re-enter your password',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 1.6.h),
              prefixIcon: Icon(Icons.lock_reset_outlined,
                  color: AppTheme.textSecondaryLight, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondaryLight,
                  size: 20,
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

          // Terms & Conditions
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _agreeToTerms
                    ? AppTheme.primaryLight.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (v) =>
                        setState(() => _agreeToTerms = v!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('I agree to the ',
                          style: TextStyle(fontSize: 13.0)),
                      GestureDetector(
                        onTap: () => setState(
                            () => _agreeToTerms = !_agreeToTerms),
                        child: Text('Terms of Service',
                            style: TextStyle(
                                fontSize: 13.0,
                                color:
                                    AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(' and ',
                          style: TextStyle(fontSize: 13.0)),
                      GestureDetector(
                        onTap: () => setState(
                            () => _agreeToTerms = !_agreeToTerms),
                        child: Text('Privacy Policy',
                            style: TextStyle(
                                fontSize: 13.0,
                                color:
                                    AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Submit Button — Premium gradient
          GestureDetector(
            onTap: _agreeToTerms && !widget.isLoading ? _submitForm : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 6.h,
              decoration: BoxDecoration(
                gradient: _agreeToTerms && !widget.isLoading
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: [Colors.grey[350]!, Colors.grey[400]!]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: _agreeToTerms
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryLight
                              .withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch_outlined,
                              color: Colors.white, size: 20),
                          SizedBox(width: 2.w),
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
