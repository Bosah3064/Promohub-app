import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/listing_form_widget.dart';
import './widgets/photo_upload_widget.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isDraftSaved = false;

  // Form data
  final List<String> _selectedImages = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = '';
  String _selectedCondition = 'New';
  String _selectedLocation = 'Lagos, Nigeria';
  int _listingDuration = 30;
  bool _allowCalls = true;
  bool _allowDelivery = false;
  bool _allowPickup = true;

  // Mock categories data
  final List<Map<String, dynamic>> _categories = [
    {"id": 1, "name": "Electronics", "icon": "phone_android"},
    {"id": 2, "name": "Vehicles", "icon": "directions_car"},
    {"id": 3, "name": "Real Estate", "icon": "home"},
    {"id": 4, "name": "Fashion", "icon": "checkroom"},
    {"id": 5, "name": "Jobs", "icon": "work"},
    {"id": 6, "name": "Services", "icon": "build"},
    {"id": 7, "name": "Sports", "icon": "sports_soccer"},
    {"id": 8, "name": "Books", "icon": "menu_book"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startAutoSave();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startAutoSave() {
    // Auto-save every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _saveDraft();
        _startAutoSave();
      }
    });
  }

  void _saveDraft() {
    setState(() {
      _isDraftSaved = true;
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Draft saved automatically'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );

    // Reset after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isDraftSaved = false;
        });
      }
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _tabController.animateTo(_currentStep);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _tabController.animateTo(_currentStep);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedImages.isNotEmpty;
      case 1:
        return _titleController.text.isNotEmpty &&
            _selectedCategory.isNotEmpty &&
            _priceController.text.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _publishListing() async {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success dialog
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Listing Published!',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your listing has been successfully published and is now live on PromoHub.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              Text(
                'Share your listing:',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareButton('WhatsApp', 'message', () {}),
                  _buildShareButton('Facebook', 'facebook', () {}),
                  _buildShareButton('Copy Link', 'link', () {}),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home-screen');
              },
              child: Text('View Listing'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home-screen');
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShareButton(String label, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Create Listing',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveDraft,
            icon: CustomIconWidget(
              iconName: _isDraftSaved ? 'check' : 'save',
              color: _isDraftSaved
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.primary,
              size: 18,
            ),
            label: Text(
              _isDraftSaved ? 'Saved' : 'Save Draft',
              style: TextStyle(
                color: _isDraftSaved
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of 3',
                      style: AppTheme.lightTheme.textTheme.labelMedium,
                    ),
                    Text(
                      '${(((_currentStep + 1) / 3) * 100).round()}% Complete',
                      style: AppTheme.lightTheme.textTheme.labelMedium,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab indicator
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _currentStep = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'photo_camera',
                        color: _currentStep >= 0
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text('Photos'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'edit',
                        color: _currentStep >= 1
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text('Details'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'settings',
                        color: _currentStep >= 2
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text('Options'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
                _tabController.animateTo(index);
              },
              children: [
                // Step 1: Photos
                PhotoUploadWidget(
                  selectedImages: _selectedImages,
                  onImagesChanged: (images) {
                    setState(() {
                      _selectedImages.clear();
                      _selectedImages.addAll(images);
                    });
                  },
                ),

                // Step 2: Details
                ListingFormWidget(
                  titleController: _titleController,
                  priceController: _priceController,
                  descriptionController: _descriptionController,
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  selectedCondition: _selectedCondition,
                  selectedLocation: _selectedLocation,
                  onCategoryChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  onConditionChanged: (condition) {
                    setState(() {
                      _selectedCondition = condition;
                    });
                  },
                  onLocationChanged: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                ),

                // Step 3: Advanced Options
                AdvancedOptionsWidget(
                  listingDuration: _listingDuration,
                  allowCalls: _allowCalls,
                  allowDelivery: _allowDelivery,
                  allowPickup: _allowPickup,
                  onDurationChanged: (duration) {
                    setState(() {
                      _listingDuration = duration;
                    });
                  },
                  onCallsChanged: (value) {
                    setState(() {
                      _allowCalls = value;
                    });
                  },
                  onDeliveryChanged: (value) {
                    setState(() {
                      _allowDelivery = value;
                    });
                  },
                  onPickupChanged: (value) {
                    setState(() {
                      _allowPickup = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousStep,
                    child: Text('Previous'),
                  ),
                ),
              if (_currentStep > 0) SizedBox(width: 16),
              Expanded(
                flex: _currentStep == 0 ? 1 : 1,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentStep == 2 ? _publishListing : _nextStep),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(_currentStep == 2 ? 'Publish Listing' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
