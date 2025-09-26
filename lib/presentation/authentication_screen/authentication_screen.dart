import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/auth_form_widget.dart';
import './widgets/promo_hub_logo_widget.dart';
import './widgets/social_login_widget.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  if (!_isKeyboardVisible) ...[
                    SizedBox(height: 4.h),
                    const PromoHubLogoWidget(),
                    SizedBox(height: 4.h),
                  ] else
                    SizedBox(height: 2.h),

                  // Segmented Control
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(2),
                      labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
                      unselectedLabelColor:
                          AppTheme.lightTheme.colorScheme.onSurface,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Login'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Auth Form
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        AuthFormWidget(
                          isLogin: true,
                          onSubmit: _handleLogin,
                        ),
                        AuthFormWidget(
                          isLogin: false,
                          onSubmit: _handleSignUp,
                        ),
                      ],
                    ),
                  ),

                  // Social Login Section
                  if (!_isKeyboardVisible) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: const SocialLoginWidget(),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(Map<String, String> credentials) async {
    // Mock authentication logic
    final email = credentials['email'] ?? '';
    final password = credentials['password'] ?? '';

    // Mock credentials for testing
    if (email == 'user@promohub.com' && password == 'password123') {
      // Success - navigate to home screen
      Navigator.pushReplacementNamed(context, '/home-screen');
    } else if (email == 'admin@promohub.com' && password == 'admin123') {
      // Admin success - navigate to home screen
      Navigator.pushReplacementNamed(context, '/home-screen');
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Invalid credentials. Try user@promohub.com / password123'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _handleSignUp(Map<String, String> credentials) async {
    // Mock sign up logic
    final email = credentials['email'] ?? '';
    final phone = credentials['phone'] ?? '';
    final password = credentials['password'] ?? '';

    if (email.isNotEmpty && phone.isNotEmpty && password.isNotEmpty) {
      // Success - navigate to location setup
      Navigator.pushReplacementNamed(context, '/location-setup-screen');
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }
}
