import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_navigation_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  bool _userInteracted = false;

  // Mock data for onboarding screens
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "title": "Discover Amazing Deals",
      "description":
          "Browse thousands of listings from trusted sellers across Africa. Find everything from electronics to fashion, all in one place.",
    },
    {
      "imageUrl":
          "https://images.pexels.com/photos/4386321/pexels-photo-4386321.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "title": "Create & Sell Easily",
      "description":
          "List your items in minutes with our simple photo upload and description tools. Reach buyers in your area instantly.",
    },
    {
      "imageUrl":
          "https://cdn.pixabay.com/photo/2020/06/24/19/12/cabbage-5337431_1280.jpg",
      "title": "Chat Securely",
      "description":
          "Connect with buyers and sellers through our secure messaging system. Negotiate prices and arrange meetups safely.",
    },
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "title": "Shop Locally",
      "description":
          "Use location-based search to find items near you. Support local businesses and reduce delivery costs with nearby sellers.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvanceTimer();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!_userInteracted && mounted) {
        if (_currentPage < _onboardingData.length - 1) {
          _nextPage();
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _onUserInteraction() {
    setState(() {
      _userInteracted = true;
    });
    _autoAdvanceTimer?.cancel();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _onUserInteraction();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _onUserInteraction();
    _completeOnboarding();
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: _onUserInteraction,
        onPanUpdate: (details) => _onUserInteraction(),
        child: Column(
          children: [
            // Skip button in top-right
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h, right: 4.w),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Main content area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _onUserInteraction();
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return OnboardingPageWidget(
                    imageUrl: data["imageUrl"] as String,
                    title: data["title"] as String,
                    description: data["description"] as String,
                    isLastPage: index == _onboardingData.length - 1,
                  );
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: PageIndicatorWidget(
                currentPage: _currentPage,
                totalPages: _onboardingData.length,
              ),
            ),

            // Navigation buttons
            OnboardingNavigationWidget(
              isLastPage: _currentPage == _onboardingData.length - 1,
              onNext: () {
                _onUserInteraction();
                _nextPage();
              },
              onSkip: _skipOnboarding,
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
