import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_selector.dart';
import './widgets/condition_toggle.dart';
import './widgets/description_field.dart';
import './widgets/location_picker.dart';
import './widgets/photo_upload_section.dart';
import './widgets/price_input_section.dart';

class CreateListing extends StatefulWidget {
  const CreateListing({super.key});

  @override
  State<CreateListing> createState() => _CreateListingState();
}

class _CreateListingState extends State<CreateListing> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _scrollController = ScrollController();

  // Form data
  List<XFile> _selectedPhotos = [];
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedCondition;
  String? _price;
  String _selectedCurrency = 'NGN';
  String? _selectedLocation;
  String? _description;

  // UI state
  bool _isLoading = false;
  bool _isDraftSaved = false;
  int _titleCharacterCount = 0;
  static const int _maxTitleCharacters = 100;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateTitleCharacterCount);
    _loadDraft();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateTitleCharacterCount() {
    setState(() {
      _titleCharacterCount = _titleController.text.length;
    });
    _saveDraft();
  }

  void _loadDraft() {
    // Simulate loading draft from local storage
    setState(() {
      _isDraftSaved = false;
    });
  }

  void _saveDraft() {
    // Auto-save draft functionality
    if (!_isDraftSaved) {
      setState(() {
        _isDraftSaved = true;
      });

      // Show brief confirmation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isDraftSaved = false;
          });
        }
      });
    }
  }

  bool _isFormValid() {
    return _selectedPhotos.isNotEmpty &&
        _titleController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _selectedCondition != null &&
        _price != null &&
        _price!.isNotEmpty &&
        _selectedLocation != null &&
        _description != null &&
        _description!.trim().isNotEmpty;
  }

  void _showPreview() {
    if (!_isFormValid()) {
      _showValidationErrors();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Preview Listing',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildPreviewContent(),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Edit'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _postListing,
                      child: const Text('Post Listing'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    final currencySymbol = _selectedCurrency == 'NGN'
        ? '₦'
        : _selectedCurrency == 'KES'
            ? 'KSh'
            : _selectedCurrency == 'GHS'
                ? '₵'
                : '\$';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photos preview
        if (_selectedPhotos.isNotEmpty)
          Container(
            height: 30.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.lightTheme.colorScheme.surface,
            ),
            child: PageView.builder(
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: _selectedPhotos[index].path,
                    width: double.infinity,
                    height: 30.h,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

        SizedBox(height: 3.h),

        // Title and price
        Text(
          _titleController.text,
          style: AppTheme.lightTheme.textTheme.headlineSmall,
        ),
        SizedBox(height: 1.h),
        Text(
          '$currencySymbol${_price ?? '0'}',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.lightTheme.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 2.h),

        // Details
        _buildPreviewDetailRow('Category',
            '$_selectedCategory${_selectedSubcategory != null ? ' • $_selectedSubcategory' : ''}'),
        _buildPreviewDetailRow('Condition', _selectedCondition ?? ''),
        _buildPreviewDetailRow('Location', _selectedLocation ?? ''),

        SizedBox(height: 3.h),

        // Description
        Text(
          'Description',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        Text(
          _description ?? '',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPreviewDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationErrors() {
    final errors = <String>[];

    if (_selectedPhotos.isEmpty) errors.add('Add at least one photo');
    if (_titleController.text.trim().isEmpty) errors.add('Enter a title');
    if (_selectedCategory == null) errors.add('Select a category');
    if (_selectedCondition == null) errors.add('Select item condition');
    if (_price == null || _price!.isEmpty) errors.add('Enter a price');
    if (_selectedLocation == null) errors.add('Select location');
    if (_description == null || _description!.trim().isEmpty) {
      errors.add('Add description');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Complete Required Fields',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors
              .map((error) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'error_outline',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            error,
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _postListing() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate posting process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.primaryColor,
                size: 64,
              ),
              SizedBox(height: 2.h),
              Text(
                'Listing Posted Successfully!',
                style: AppTheme.lightTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Your item is now live on PromoHub',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close preview
                Navigator.pop(context); // Close create listing
              },
              child: const Text('View Listing'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close preview
                _resetForm();
              },
              child: const Text('Create Another'),
            ),
          ],
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedPhotos.clear();
      _titleController.clear();
      _selectedCategory = null;
      _selectedSubcategory = null;
      _selectedCondition = null;
      _price = null;
      _selectedLocation = null;
      _description = null;
      _titleCharacterCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Listing'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          if (_isDraftSaved)
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_done',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Saved',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          TextButton(
            onPressed: _isFormValid() ? _showPreview : null,
            child: Text(
              'Preview',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: _isFormValid()
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo Upload Section
                PhotoUploadSection(
                  selectedPhotos: _selectedPhotos,
                  onPhotosChanged: (photos) {
                    setState(() {
                      _selectedPhotos = photos;
                    });
                    _saveDraft();
                  },
                ),

                SizedBox(height: 4.h),

                // Title Field
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'title',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Title',
                            style: AppTheme.lightTheme.textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            '$_titleCharacterCount/$_maxTitleCharacters',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: _titleCharacterCount >
                                      _maxTitleCharacters * 0.9
                                  ? AppTheme.lightTheme.colorScheme.error
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _titleController,
                        maxLength: _maxTitleCharacters,
                        decoration: InputDecoration(
                          hintText: 'What are you selling?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.lightTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(4.w),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Category Selector
                CategorySelector(
                  selectedCategory: _selectedCategory,
                  selectedSubcategory: _selectedSubcategory,
                  onCategoryChanged: (category, subcategory) {
                    setState(() {
                      _selectedCategory = category;
                      _selectedSubcategory = subcategory;
                    });
                    _saveDraft();
                  },
                ),

                SizedBox(height: 4.h),

                // Condition Toggle
                ConditionToggle(
                  selectedCondition: _selectedCondition,
                  onConditionChanged: (condition) {
                    setState(() {
                      _selectedCondition = condition;
                    });
                    _saveDraft();
                  },
                ),

                SizedBox(height: 4.h),

                // Price Input Section
                PriceInputSection(
                  price: _price,
                  selectedCurrency: _selectedCurrency,
                  category: _selectedCategory,
                  onPriceChanged: (price) {
                    setState(() {
                      _price = price;
                    });
                    _saveDraft();
                  },
                  onCurrencyChanged: (currency) {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                    _saveDraft();
                  },
                ),

                SizedBox(height: 4.h),

                // Location Picker
                LocationPicker(
                  selectedLocation: _selectedLocation,
                  onLocationChanged: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                    _saveDraft();
                  },
                ),

                SizedBox(height: 4.h),

                // Description Field
                DescriptionField(
                  description: _description,
                  onDescriptionChanged: (description) {
                    setState(() {
                      _description = description;
                    });
                    _saveDraft();
                  },
                ),

                SizedBox(height: 6.h),

                // Post Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _showPreview,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      backgroundColor: _isFormValid()
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                    ),
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
                        : Text(
                            'Preview Listing',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
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
        ),
      ),
    );
  }
}
