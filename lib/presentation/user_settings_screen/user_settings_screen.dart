import 'package:flutter/material.dart';

import '../../core/app_export.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasUnsavedChanges = false;
  bool _isPhoneVerified = false;
  bool _isSaving = false;
  bool _showVerificationCode = false;

  // Form controllers
  final TextEditingController _nameController =
      TextEditingController(text: 'Ahmed Okafor');
  final TextEditingController _emailController =
      TextEditingController(text: 'ahmed.okafor@example.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '+234 801 234 5678');
  final TextEditingController _verificationCodeController =
      TextEditingController();

  // Contact preferences
  bool _allowCalls = true;
  bool _allowMessages = true;
  String _preferredContactMethod = 'Both';

  // Location preferences
  final String _currentLocation = 'Lagos, Nigeria';
  double _searchRadius = 10.0;
  bool _notifyNewListingsInArea = true;

  // Privacy settings
  bool _profileVisibleToAll = true;
  bool _shareContactWithBuyers = true;

  @override
  void initState() {
    super.initState();
    // Add listeners to detect form changes
    _nameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _verifyPhone() {
    // If already showing verification code field, validate the code
    if (_showVerificationCode) {
      if (_verificationCodeController.text.trim() == '123456') {
        setState(() {
          _isPhoneVerified = true;
          _showVerificationCode = false;
          _hasUnsavedChanges = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number verified successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid verification code. Try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
      _verificationCodeController.clear();
    } else {
      // Send verification code (simulate with fixed code 123456)
      setState(() {
        _showVerificationCode = true;
        // In a real app, the verification code would be sent via SMS
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Verification code sent to your phone. For demo, use: 123456'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Discard'),
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
          title: Text('Settings'),
          elevation: 1,
          actions: [
            if (_hasUnsavedChanges)
              Container(
                margin: EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '• Unsaved',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSectionCard(
                title: 'Personal Information',
                icon: 'person',
                isExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            child: ClipOval(
                              child: CustomImageWidget(
                                imageUrl:
                                    'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Show image picker
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: AppTheme.lightTheme
                                                  .colorScheme.outline,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            'Change Profile Photo',
                                            style: AppTheme.lightTheme.textTheme
                                                .titleLarge,
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildImageSourceOption(
                                                'Camera',
                                                'photo_camera',
                                                () => Navigator.pop(context),
                                              ),
                                              _buildImageSourceOption(
                                                'Gallery',
                                                'photo_library',
                                                () => Navigator.pop(context),
                                              ),
                                              _buildImageSourceOption(
                                                'Remove',
                                                'delete',
                                                () => Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: CustomIconWidget(
                                  iconName: 'photo_camera',
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Full Name',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12),
                          child: CustomIconWidget(
                            iconName: 'person',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Email Address',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12),
                          child: CustomIconWidget(
                            iconName: 'email',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                title: 'Contact Details',
                icon: 'contact_phone',
                isExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(12),
                                child: CustomIconWidget(
                                  iconName: 'phone',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              suffixIcon: _isPhoneVerified
                                  ? Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CustomIconWidget(
                                        iconName: 'verified',
                                        color: AppTheme
                                            .lightTheme.colorScheme.secondary,
                                        size: 20,
                                      ),
                                    )
                                  : null,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        if (!_isPhoneVerified)
                          ElevatedButton(
                            onPressed: _verifyPhone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.secondary,
                            ),
                            child: Text(_showVerificationCode
                                ? 'Verify'
                                : 'Verify Phone'),
                          ),
                      ],
                    ),
                    if (_showVerificationCode) ...[
                      SizedBox(height: 16),
                      Text(
                        'Verification Code',
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _verificationCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          hintText: 'Enter 6-digit code',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: CustomIconWidget(
                              iconName: 'pin',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          counterText: '',
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showVerificationCode = false;
                              });
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Resend code (in real app)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Code resent. For demo, use: 123456'),
                                ),
                              );
                            },
                            child: Text('Resend Code'),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 24),
                    Text(
                      'Contact Preferences',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    _buildSwitchOption(
                      title: 'Allow Calls',
                      subtitle: 'Buyers can call you directly',
                      value: _allowCalls,
                      onChanged: (value) {
                        setState(() {
                          _allowCalls = value;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    _buildSwitchOption(
                      title: 'Allow Messages',
                      subtitle: 'Buyers can send you messages',
                      value: _allowMessages,
                      onChanged: (value) {
                        setState(() {
                          _allowMessages = value;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Preferred Contact Method',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _preferredContactMethod,
                          isExpanded: true,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            DropdownMenuItem(
                                value: 'Both',
                                child: Text('Both Calls & Messages')),
                            DropdownMenuItem(
                                value: 'Calls', child: Text('Calls Only')),
                            DropdownMenuItem(
                                value: 'Messages',
                                child: Text('Messages Only')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _preferredContactMethod = value;
                                _hasUnsavedChanges = true;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                title: 'Location Preferences',
                icon: 'location_on',
                isExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // Show location picker
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(12),
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
                              child: Text(_currentLocation),
                            ),
                            CustomIconWidget(
                              iconName: 'edit',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Search Radius: ${_searchRadius.toInt()} km',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    Slider(
                      value: _searchRadius,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_searchRadius.toInt()} km',
                      onChanged: (value) {
                        setState(() {
                          _searchRadius = value;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildSwitchOption(
                      title: 'Notify for New Listings',
                      subtitle:
                          'Get notifications for new listings in your area',
                      value: _notifyNewListingsInArea,
                      onChanged: (value) {
                        setState(() {
                          _notifyNewListingsInArea = value;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                title: 'Privacy Controls',
                icon: 'privacy_tip',
                isExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSwitchOption(
                      title: 'Profile Visibility',
                      subtitle: 'Make your profile visible to all users',
                      value: _profileVisibleToAll,
                      onChanged: (value) {
                        setState(() {
                          _profileVisibleToAll = value;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildSwitchOption(
                      title: 'Share Contact Information',
                      subtitle:
                          'Allow buyers to see your contact details when you interact',
                      value: _shareContactWithBuyers,
                      onChanged: (value) {
                        setState(() {
                          _shareContactWithBuyers = value;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildSectionCard(
                title: 'Account Security',
                icon: 'security',
                isExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to change password screen
                      },
                      icon: CustomIconWidget(
                        iconName: 'lock',
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text('Change Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to two-factor authentication setup
                      },
                      icon: CustomIconWidget(
                        iconName: 'two_factor_authentication',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      label: Text('Setup Two-Factor Authentication'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: _hasUnsavedChanges
            ? Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text('Save Changes'),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String icon,
    required Widget child,
    bool isExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        leading: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [child],
      ),
    );
  }

  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
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
          activeColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      ],
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
}
