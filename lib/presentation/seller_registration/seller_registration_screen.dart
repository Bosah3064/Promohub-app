import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  State<SellerRegistrationScreen> createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final MarketplaceService _marketplaceService = MarketplaceService();
  final FirebaseService _firebaseService = FirebaseService();

  final _shopNameController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();

  int _currentStep = 0;
  String _sellerType = 'individual';
  String _documentType = 'National ID';
  bool _isLoading = false;
  bool _agreedToTerms = false;
  File? _kycDocument;
  final ImagePicker _picker = ImagePicker();

  final List<String> _docTypes = [
    'National ID',
    'Passport',
    'Driving License',
    'Business Registration'
  ];

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _locationController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        setState(() {
          _kycDocument = File(image.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error picking image');
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      Fluttertoast.showToast(msg: 'Please agree to the Terms & Conditions');
      return;
    }
    if (_kycDocument == null) {
      Fluttertoast.showToast(msg: 'Please upload a KYC document photo');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) throw Exception('Not authenticated');

      String docUrl = 'pending_upload';
      try {
        final path = '$userId/kyc_${DateTime.now().millisecondsSinceEpoch}.jpg';
        docUrl = await _firebaseService.uploadImage(
            'kyc_documents', path, _kycDocument);
      } catch (e) {
        Fluttertoast.showToast(msg: 'Image upload failed, proceeding anyway.');
      }

      final shopData = {
        'owner_id': userId,
        'name': _shopNameController.text.trim(),
        'slug': _shopNameController.text
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
        'description': _shopDescriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'status': 'pending_verification'
      };

      final shop = await _marketplaceService.createShop(shopData);

      final kycData = {
        'shop_id': shop['id'],
        'seller_type': _sellerType,
        'document_type': _documentType,
        'document_url': docUrl,
        'id_number': _idNumberController.text.trim(),
        'status': 'pending'
      };

      await _marketplaceService.submitKYC(kycData);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryLight, AppTheme.successLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.store_outlined, color: Colors.white, size: 36),
              ),
              SizedBox(height: 3.h),
              Text('Application Submitted!',
                  style: AppTheme.lightTheme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              SizedBox(height: 1.h),
              Text(
                'Your seller application is under review. We\'ll verify your documents within 24-48 hours.',
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.textSecondaryLight),
              ),
              SizedBox(height: 1.5.h),
              _buildVerificationTimeline(),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Got It'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationTimeline() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _timelineItem('Registration', 'Completed', true),
          _timelineItem('Document Review', 'In progress', false),
          _timelineItem('Verified Seller ✓', 'Pending', false),
        ],
      ),
    );
  }

  Widget _timelineItem(String label, String status, bool done) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: done ? AppTheme.successLight : AppTheme.dividerLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? Icons.check : Icons.circle_outlined,
              color: done ? Colors.white : AppTheme.textDisabledLight,
              size: 16,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 11.sp)),
          ),
          Text(status,
              style: TextStyle(
                  fontSize: 9.sp,
                  color: done
                      ? AppTheme.successLight
                      : AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Become a Seller'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimaryLight,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submitRegistration();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      ),
                      child: _isLoading && _currentStep == 2
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_currentStep == 2
                              ? 'Submit Application'
                              : 'Continue'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Store Info
            Step(
              title: Text('Store Information',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Name, description, location'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _shopNameController,
                    decoration: InputDecoration(
                      labelText: 'Store Name',
                      hintText: 'e.g., TechWorld Kenya',
                      prefixIcon: Icon(Icons.store_outlined,
                          color: AppTheme.primaryLight),
                    ),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Store name is required' : null,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _shopDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Store Description',
                      hintText: 'What does your store sell?',
                      prefixIcon: Icon(Icons.description_outlined,
                          color: AppTheme.primaryLight),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Store Location',
                      hintText: 'e.g., Nairobi, Kenya',
                      prefixIcon: Icon(Icons.location_on_outlined,
                          color: AppTheme.primaryLight),
                    ),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Location is required' : null,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Business Phone',
                      hintText: '+254 7XX XXX XXX',
                      prefixIcon: Icon(Icons.phone_outlined,
                          color: AppTheme.primaryLight),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            // Step 2: KYC
            Step(
              title: Text('KYC Verification',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Identity & document verification'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  SizedBox(height: 1.h),
                  DropdownButtonFormField<String>(
                    initialValue: _sellerType,
                    decoration: InputDecoration(
                      labelText: 'Seller Type',
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppTheme.primaryLight),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'individual', child: Text('Individual')),
                      DropdownMenuItem(
                          value: 'business',
                          child: Text('Registered Business')),
                    ],
                    onChanged: (val) => setState(() => _sellerType = val!),
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    initialValue: _documentType,
                    decoration: InputDecoration(
                      labelText: 'Document Type',
                      prefixIcon: Icon(Icons.badge_outlined,
                          color: AppTheme.primaryLight),
                    ),
                    items: _docTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => _documentType = val!),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _idNumberController,
                    decoration: InputDecoration(
                      labelText: 'Document / ID Number',
                      prefixIcon:
                          Icon(Icons.numbers, color: AppTheme.primaryLight),
                    ),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'ID Number is required' : null,
                  ),
                  SizedBox(height: 2.h),
                  // Upload document
                  InkWell(
                    onTap: _pickDocument,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.dividerLight, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _kycDocument != null
                          ? Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(_kycDocument!,
                                      height: 15.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover),
                                ),
                                SizedBox(height: 1.h),
                                Text('Tap to change image',
                                    style: TextStyle(
                                        color: AppTheme.primaryLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp)),
                              ],
                            )
                          : Column(
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 40,
                                    color: AppTheme.primaryLight
                                        .withValues(alpha: 0.5)),
                                SizedBox(height: 1.h),
                                Text('Upload Document Photo',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp)),
                                Text('JPG, PNG up to 5MB',
                                    style: TextStyle(
                                        color: AppTheme.textSecondaryLight,
                                        fontSize: 10.sp)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            // Step 3: Terms
            Step(
              title: Text('Terms & Payout',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Agree to seller terms'),
              isActive: _currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryLight.withValues(alpha: 0.06),
                          AppTheme.primaryLight.withValues(alpha: 0.02)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seller Levels',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12.sp)),
                        SizedBox(height: 1.h),
                        _levelRow('🆕', 'New Seller',
                            'Limited to 5 listings, max KSh 50k/sale'),
                        _levelRow('✅', 'Verified Seller',
                            'Normal selling, priority support'),
                        _levelRow('⭐', 'Trusted Seller',
                            'Higher limits, featured visibility'),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppTheme.warningLight, size: 20),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'PromoHub charges 6-15% commission per sale depending on category. You\'ll start as a New Seller.',
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: AppTheme.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  CheckboxListTile(
                    value: _agreedToTerms,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                    title: Text('I agree to the Seller Terms & Conditions',
                        style: TextStyle(fontSize: 11.sp)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppTheme.primaryLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelRow(String emoji, String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 11.sp)),
                Text(desc,
                    style: TextStyle(
                        fontSize: 9.sp, color: AppTheme.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
