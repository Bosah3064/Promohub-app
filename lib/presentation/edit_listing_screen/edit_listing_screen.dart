import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/discount_ribbon_widget.dart';

class EditListingScreen extends StatefulWidget {
  const EditListingScreen({super.key});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Form data
  final List<String> _selectedImages = [
    "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg",
    "https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg",
    "https://images.pexels.com/photos/1440727/pexels-photo-1440727.jpeg",
    "https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg"
  ];
  final TextEditingController _titleController =
      TextEditingController(text: 'iPhone 14 Pro Max - 256GB Space Black');
  final TextEditingController _priceController =
      TextEditingController(text: '850000');
  final TextEditingController _descriptionController = TextEditingController(
      text:
          """Selling my iPhone 14 Pro Max in excellent condition. Used for only 6 months with screen protector and case from day one. 

Features:
• 256GB Storage
• Space Black Color
• 48MP Camera System
• A16 Bionic Chip
• 6.7-inch Super Retina XDR Display

Includes original box, charger, and unused EarPods. No scratches or dents. Battery health at 98%. Reason for sale: upgrading to iPhone 15 Pro Max.

Serious buyers only. Price slightly negotiable.""");
  String _selectedCategory = 'Electronics';
  String _selectedCondition = 'Like New';
  String _selectedLocation = 'Lagos, Nigeria';
  int _listingDuration = 30;
  bool _allowCalls = true;
  bool _allowDelivery = false;
  bool _allowPickup = true;

  // Discount ribbon settings
  bool _applyDiscountRibbon = false;
  String _selectedRibbonStyle = 'SALE';
  double _discountPercentage = 10.0;
  double _originalPrice = 950000;

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

  final List<Map<String, dynamic>> _ribbonStyles = [
    {
      "id": "SALE",
      "name": "SALE",
      "description": "Red diagonal banner",
      "color": Color(0xFFE53935),
    },
    {
      "id": "DISCOUNT",
      "name": "DISCOUNT",
      "description": "Yellow banner",
      "color": Color(0xFFFFC107),
    },
    {
      "id": "LIMITED_TIME",
      "name": "LIMITED TIME",
      "description": "Orange flash",
      "color": Color(0xFFFF9800),
    },
    {
      "id": "BEST_PRICE",
      "name": "BEST PRICE",
      "description": "Green badge",
      "color": Color(0xFF4CAF50),
    },
    {
      "id": "HOT_DEAL",
      "name": "HOT DEAL",
      "description": "Fire icon",
      "color": Color(0xFFFF5722),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateDiscountedPrice();
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

  void _calculateDiscountedPrice() {
    if (_applyDiscountRibbon) {
      final discountAmount = _originalPrice * (_discountPercentage / 100);
      final discountedPrice = _originalPrice - discountAmount;
      _priceController.text = discountedPrice.toStringAsFixed(0);
    } else {
      _priceController.text = _originalPrice.toStringAsFixed(0);
    }
    setState(() {
      _hasUnsavedChanges = true;
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

  void _updateListing() async {
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
      _hasUnsavedChanges = false;
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
                'Listing Updated!',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your listing has been successfully updated and is now live on PromoHub.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              Text(
                'Share your updated listing:',
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
                Navigator.pushNamed(context, '/listing-detail-screen');
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

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Listing'),
          content: Text(
              'Are you sure you want to delete this listing? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                // Simulate delete operation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Listing deleted successfully'),
                    backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                );
                Navigator.pop(context); // Return to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Discard Changes'),
          content: Text(
              'You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: Text('Discard'),
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Add Photos',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    'Camera',
                    'photo_camera',
                    () {
                      Navigator.pop(context);
                      _addImageFromCamera();
                    },
                  ),
                  _buildImageSourceOption(
                    'Gallery',
                    'photo_library',
                    () {
                      Navigator.pop(context);
                      _addImageFromGallery();
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption(
      String label, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 28,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  void _addImageFromCamera() {
    // Simulate camera capture
    if (_selectedImages.length < 10) {
      final mockImages = [
        "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg",
        "https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg",
        "https://images.pexels.com/photos/1440727/pexels-photo-1440727.jpeg",
        "https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg",
        "https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg",
      ];

      setState(() {
        _selectedImages
            .add(mockImages[_selectedImages.length % mockImages.length]);
        _hasUnsavedChanges = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo captured successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 10 photos allowed'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _addImageFromGallery() {
    // Simulate gallery selection
    if (_selectedImages.length < 10) {
      final mockImages = [
        "https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg",
        "https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg",
        "https://images.pexels.com/photos/1440727/pexels-photo-1440727.jpeg",
        "https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg",
        "https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg",
      ];

      setState(() {
        _selectedImages
            .add(mockImages[_selectedImages.length % mockImages.length]);
        _hasUnsavedChanges = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo selected from gallery'),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 10 photos allowed'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _hasUnsavedChanges = true;
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      final item = _selectedImages.removeAt(oldIndex);
      _selectedImages.insert(newIndex, item);
      _hasUnsavedChanges = true;
    });
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Category',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['name'];

                    return ListTile(
                      leading: CustomIconWidget(
                        iconName: category['icon'] as String,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      title: Text(
                        category['name'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['name'] as String;
                          _hasUnsavedChanges = true;
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
  }

  void _showLocationPicker() {
    final List<String> locations = [
      'Lagos, Nigeria',
      'Abuja, Nigeria',
      'Kano, Nigeria',
      'Ibadan, Nigeria',
      'Port Harcourt, Nigeria',
      'Benin City, Nigeria',
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Location',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    final isSelected = _selectedLocation == location;

                    return ListTile(
                      leading: CustomIconWidget(
                        iconName: 'location_on',
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      title: Text(
                        location,
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLocation = location;
                          _hasUnsavedChanges = true;
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
  }

  void _showRibbonStylePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Ribbon Style',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _ribbonStyles.length,
                  itemBuilder: (context, index) {
                    final style = _ribbonStyles[index];
                    final isSelected = _selectedRibbonStyle == style['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRibbonStyle = style['id'] as String;
                          _hasUnsavedChanges = true;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: style['color'] as Color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                style['name'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Listing Preview'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_selectedImages.first),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_applyDiscountRibbon)
                      DiscountRibbonWidget(
                        style: _selectedRibbonStyle,
                        percentage: _discountPercentage.toInt(),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                _titleController.text,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              if (_applyDiscountRibbon) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₦${_originalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '₦${_priceController.text}',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              ] else
                Text(
                  '₦${_priceController.text}',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          _showDiscardChangesDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          elevation: 1,
          leading: IconButton(
            onPressed: () {
              if (_hasUnsavedChanges) {
                _showDiscardChangesDialog();
              } else {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          title: Text(
            'Edit Listing',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          actions: [
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: _updateListing,
                child: Text('Update'),
              ),
            PopupMenuButton<String>(
              icon: CustomIconWidget(
                iconName: 'more_vert',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmationDialog();
                } else if (value == 'preview') {
                  _showPreviewDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'preview',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'preview',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text('Preview Changes'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete Listing',
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  _buildPhotosStep(),

                  // Step 2: Details
                  _buildDetailsStep(),

                  // Step 3: Advanced Options
                  _buildOptionsStep(),
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
                        : (_currentStep == 2 ? _updateListing : _nextStep),
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
                        : Text(_currentStep == 2 ? 'Update Listing' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Photos',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Add up to 10 photos. The first photo will be your main image.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24),

          // Photo grid
          _selectedImages.isEmpty ? _buildEmptyState() : _buildPhotoGrid(),

          SizedBox(height: 24),

          // Add photo button
          if (_selectedImages.length < 10)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: CustomIconWidget(
                  iconName: 'add_photo_alternate',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: Text('Add More Photos'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

          SizedBox(height: 16),

          // Photo tips
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Photo Tips',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildTip('Use good lighting and clear focus'),
                _buildTip('Show different angles of your item'),
                _buildTip('Include any defects or wear'),
                _buildTip('Avoid watermarks or logos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Listing Details',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 24),

          // Title field
          Text(
            'Title *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'What are you selling?',
              counterText: '${_titleController.text.length}/80',
            ),
            maxLength: 80,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              setState(() {
                _hasUnsavedChanges = true;
              });
            },
          ),
          SizedBox(height: 24),

          // Category field
          Text(
            'Category *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _showCategoryPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: Row(
                children: [
                  if (_selectedCategory.isNotEmpty) ...[
                    CustomIconWidget(
                      iconName: _categories.firstWhere(
                              (cat) => cat['name'] == _selectedCategory)['icon']
                          as String,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      _selectedCategory.isEmpty
                          ? 'Select a category'
                          : _selectedCategory,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: _selectedCategory.isEmpty
                            ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Condition chips
          Text(
            'Condition *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ['New', 'Like New', 'Good', 'Fair', 'Poor'].map((condition) {
              final isSelected = _selectedCondition == condition;
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCondition = condition;
                      _hasUnsavedChanges = true;
                    });
                  }
                },
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24),

          // Discount Ribbon Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'discount',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Apply Discount Ribbon',
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Switch(
                      value: _applyDiscountRibbon,
                      onChanged: (value) {
                        setState(() {
                          _applyDiscountRibbon = value;
                          _hasUnsavedChanges = true;
                          _calculateDiscountedPrice();
                        });
                      },
                    ),
                  ],
                ),
                if (_applyDiscountRibbon) ...[
                  SizedBox(height: 16),
                  Text(
                    'Ribbon Style',
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showRibbonStylePicker,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.lightTheme.colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _ribbonStyles.firstWhere((s) =>
                                      s['id'] == _selectedRibbonStyle)['color']
                                  as Color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _selectedRibbonStyle,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap to change style',
                              style: TextStyle(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          CustomIconWidget(
                            iconName: 'keyboard_arrow_down',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Original Price (₦)',
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                      ),
                      Spacer(),
                      Text(
                        'Discount ${_discountPercentage.toInt()}%',
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: _originalPrice.toString(),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '₦ ',
                      prefixStyle:
                          AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _originalPrice = double.tryParse(value) ?? 0;
                        _hasUnsavedChanges = true;
                        _calculateDiscountedPrice();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Discount Percentage: ${_discountPercentage.toInt()}%',
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),
                  SizedBox(height: 8),
                  Slider(
                    value: _discountPercentage,
                    min: 5,
                    max: 75,
                    divisions: 14,
                    label: '${_discountPercentage.toInt()}%',
                    onChanged: (value) {
                      setState(() {
                        _discountPercentage = value;
                        _hasUnsavedChanges = true;
                        _calculateDiscountedPrice();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Final Price: ₦${_priceController.text}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                'After ${_discountPercentage.toInt()}% discount applied',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24),

          // Description field
          Text(
            'Description',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Describe your item in detail...',
              counterText: '${_descriptionController.text.length}/500',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              setState(() {
                _hasUnsavedChanges = true;
              });
            },
          ),
          SizedBox(height: 24),

          // Location field
          Text(
            'Location *',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _showLocationPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedLocation,
                      style: AppTheme.lightTheme.textTheme.bodyLarge,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Options',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 24),

          // Listing Duration
          _buildSectionCard(
            title: 'Listing Duration',
            icon: 'schedule',
            child: Column(
              children: [
                Text(
                  'How long should your listing be active?',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDurationOption(7, '7 Days'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildDurationOption(15, '15 Days'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildDurationOption(30, '30 Days'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Contact Preferences
          _buildSectionCard(
            title: 'Contact Preferences',
            icon: 'contact_phone',
            child: Column(
              children: [
                _buildSwitchOption(
                  title: 'Allow Phone Calls',
                  subtitle: 'Buyers can call you directly',
                  value: _allowCalls,
                  onChanged: (value) {
                    setState(() {
                      _allowCalls = value;
                      _hasUnsavedChanges = true;
                    });
                  },
                  icon: 'phone',
                ),
                Divider(height: 24),
                Text(
                  'Messages are always enabled for all listings',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Delivery Options
          _buildSectionCard(
            title: 'Delivery Options',
            icon: 'local_shipping',
            child: Column(
              children: [
                _buildSwitchOption(
                  title: 'Pickup Available',
                  subtitle: 'Buyers can collect from your location',
                  value: _allowPickup,
                  onChanged: (value) {
                    setState(() {
                      _allowPickup = value;
                      _hasUnsavedChanges = true;
                    });
                  },
                  icon: 'location_on',
                ),
                Divider(height: 24),
                _buildSwitchOption(
                  title: 'Delivery Available',
                  subtitle: 'You can deliver to buyers',
                  value: _allowDelivery,
                  onChanged: (value) {
                    setState(() {
                      _allowDelivery = value;
                      _hasUnsavedChanges = true;
                    });
                  },
                  icon: 'delivery_dining',
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Preview Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showPreviewDialog,
              icon: CustomIconWidget(
                iconName: 'preview',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              label: Text('Preview Changes'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDurationOption(int days, String label) {
    final isSelected = _listingDuration == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          _listingDuration = days;
          _hasUnsavedChanges = true;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primaryContainer
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required String icon,
  }) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: value
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'photo_camera',
            color: AppTheme.lightTheme.colorScheme.outline,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'No photos added yet',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap "Add Photos" to get started',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: _reorderImages,
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Container(
          key: ValueKey(_selectedImages[index]),
          margin: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: index == 0
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: index == 0 ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CustomImageWidget(
                          imageUrl: _selectedImages[index],
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              index == 0 ? 'Main Photo' : 'Photo ${index + 1}',
                              style: AppTheme.lightTheme.textTheme.titleSmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tap and hold to reorder',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeImage(index),
                        icon: CustomIconWidget(
                          iconName: 'delete',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 20,
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'drag_handle',
                        color: AppTheme.lightTheme.colorScheme.outline,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
