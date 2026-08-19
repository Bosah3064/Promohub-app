import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_connection_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _showRetry = false;
  String _loadingText = 'Initializing PromoHub...';

  bool _isAuthenticated = false;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlay();
    _initializeApp();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
      _showRetry = false;
      _loadingText = 'Initializing PromoHub...';
    });

    try {
      // Step 1: Check authentication status
      await _checkAuthenticationStatus();

      // Step 2: Load user preferences
      await _loadUserPreferences();

      // Step 3: Fetch marketplace configuration
      await _fetchMarketplaceConfig();

      // Step 4: Prepare cached data
      await _prepareCachedData();

      // Step 5: Navigate to appropriate screen
      await _navigateToNextScreen();
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    setState(() {
      _loadingText = 'Checking authentication...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
      
      // If it's not the first time, check authentication
      if (!_isFirstTime) {
         final user = FirebaseAuth.instance.currentUser;
         _isAuthenticated = user != null;
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      _isAuthenticated = false;
    }

    if (!_isAuthenticated) {
      setState(() {
        _loadingText = 'Setting up user session...';
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    setState(() {
      _loadingText = 'Loading preferences...';
    });
    // In a real app, load preferences from local storage or backend
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _fetchMarketplaceConfig() async {
    setState(() {
      _loadingText = 'Fetching marketplace data...';
    });
    // Optional: Pre-fetch some generic config if needed
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _prepareCachedData() async {
    setState(() {
      _loadingText = 'Preparing app...';
    });
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    String nextRoute;

    if (_isAuthenticated) {
      nextRoute = '/marketplace-home';
    } else if (_isFirstTime) {
      nextRoute = '/onboarding-flow';
    } else {
      nextRoute = '/login-screen';
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  void _handleInitializationError() {
    setState(() {
      _isLoading = false;
      _showRetry = true;
    });

    // Auto-retry after 5 seconds if user doesn't manually retry
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showRetry) {
        _retryInitialization();
      }
    });
  }

  void _retryInitialization() {
    _initializeApp();
  }

  void _onLogoAnimationComplete() {
    if (!mounted) return;
    // Logo animation completed, continue with loading
    if (_isLoading) {
      setState(() {
        _loadingText = 'Welcome to PromoHub';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackgroundGradientWidget(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _showRetry ? _buildRetryView() : _buildSplashContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildSplashContent() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: AnimatedLogoWidget(
              onAnimationComplete: _onLogoAnimationComplete,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  LoadingIndicatorWidget(
                    loadingText: _loadingText,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'African Marketplace • Trusted Commerce',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      fontSize: 13.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildRetryView() {
    return Center(
      child: RetryConnectionWidget(
        onRetry: _retryInitialization,
        message:
            'Connection timeout. Please check your internet connection and try again.',
      ),
    );
  }
}
