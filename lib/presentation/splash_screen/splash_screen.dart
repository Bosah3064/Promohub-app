import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_connection_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _showRetry = false;
  String _loadingText = 'Initializing PromoHub...';

  // Mock user data for demonstration
  final Map<String, dynamic> _mockUserData = {
    "isAuthenticated": false,
    "isFirstTime": true,
    "hasCompletedOnboarding": false,
    "userPreferences": {
      "theme": "light",
      "language": "en",
      "currency": "NGN",
      "location": "Lagos, Nigeria"
    },
    "marketplaceConfig": {
      "categories": [
        "Electronics",
        "Fashion",
        "Vehicles",
        "Real Estate",
        "Jobs",
        "Services"
      ],
      "featuredListings": 25,
      "activeUsers": 15420,
      "lastUpdate": "2025-07-29T07:18:48.829429"
    }
  };

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

    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate authentication check
    final bool isAuthenticated = _mockUserData["isAuthenticated"] as bool;

    if (!isAuthenticated) {
      setState(() {
        _loadingText = 'Setting up user session...';
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    setState(() {
      _loadingText = 'Loading preferences...';
    });

    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate loading user preferences
    final preferences =
        _mockUserData["userPreferences"] as Map<String, dynamic>;

    // Apply theme based on preferences
    if (preferences["theme"] == "dark") {
      // Would apply dark theme here
    }
  }

  Future<void> _fetchMarketplaceConfig() async {
    setState(() {
      _loadingText = 'Fetching marketplace data...';
    });

    await Future.delayed(const Duration(milliseconds: 700));

    // Simulate network timeout scenario (5% chance)
    if (DateTime.now().millisecond % 20 == 0) {
      throw Exception('Network timeout');
    }

    // Simulate successful config fetch
    final config = _mockUserData["marketplaceConfig"] as Map<String, dynamic>;
    final categories = config["categories"] as List;

    setState(() {
      _loadingText = 'Loading ${categories.length} categories...';
    });
  }

  Future<void> _prepareCachedData() async {
    setState(() {
      _loadingText = 'Preparing listings cache...';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate preparing cached listings data
    final config = _mockUserData["marketplaceConfig"] as Map<String, dynamic>;
    final featuredCount = config["featuredListings"] as int;

    setState(() {
      _loadingText = 'Cached $featuredCount featured listings';
    });
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final bool isAuthenticated = _mockUserData["isAuthenticated"] as bool;
    final bool isFirstTime = _mockUserData["isFirstTime"] as bool;
    final bool hasCompletedOnboarding =
        _mockUserData["hasCompletedOnboarding"] as bool;

    String nextRoute;

    if (isAuthenticated) {
      // Authenticated users go directly to marketplace home
      nextRoute = '/marketplace-home';
    } else if (isFirstTime || !hasCompletedOnboarding) {
      // New users see onboarding flow
      nextRoute = '/onboarding-flow';
    } else {
      // Returning non-authenticated users reach login screen
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
        Expanded(
          flex: 1,
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
                    fontSize: 11.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
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
