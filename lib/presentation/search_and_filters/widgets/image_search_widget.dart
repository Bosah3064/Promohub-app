import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ImageSearchWidget extends StatefulWidget {
  final Function(String)? onImageSearchResult;
  final VoidCallback? onClose;

  const ImageSearchWidget({
    super.key,
    this.onImageSearchResult,
    this.onClose,
  });

  @override
  State<ImageSearchWidget> createState() => _ImageSearchWidgetState();
}

class _ImageSearchWidgetState extends State<ImageSearchWidget>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  XFile? _capturedImage;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (await _requestCameraPermission()) {
        _cameras = await availableCameras();

        if (_cameras.isNotEmpty) {
          final camera = kIsWeb
              ? _cameras.firstWhere(
                  (c) => c.lensDirection == CameraLensDirection.front,
                  orElse: () => _cameras.first,
                )
              : _cameras.firstWhere(
                  (c) => c.lensDirection == CameraLensDirection.back,
                  orElse: () => _cameras.first,
                );

          _cameraController = CameraController(
            camera,
            kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
          );

          await _cameraController!.initialize();
          await _applySettings();

          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      _showError('Failed to initialize camera');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Flash not supported, continue without it
        }
      }
    } catch (e) {
      // Settings not supported, continue without them
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
      });
      _processImage();
    } catch (e) {
      _showError('Failed to capture photo');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        _processImage();
      }
    } catch (e) {
      _showError('Failed to pick image from gallery');
    }
  }

  Future<void> _processImage() async {
    if (_capturedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate image processing and search
    await Future.delayed(const Duration(seconds: 3));

    // Mock image search results
    final mockResults = [
      'iPhone 13 Pro Max - Similar items found',
      'Samsung Galaxy S23 - 15 matches',
      'MacBook Pro 2023 - 8 similar products',
      'Nike Air Jordan - 23 matches',
      'Sony WH-1000XM4 - 12 similar items',
      'Canon EOS R5 - 6 matches',
    ];

    final randomResult =
        mockResults[DateTime.now().millisecond % mockResults.length];

    if (widget.onImageSearchResult != null) {
      widget.onImageSearchResult!(randomResult);
    }

    _closeImageSearch();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
    _closeImageSearch();
  }

  void _closeImageSearch() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          children: [
            if (_capturedImage != null)
              _buildImagePreview()
            else if (_isCameraInitialized && _cameraController != null)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              )
            else
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Image Search',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _closeImageSearch,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom controls
            if (_capturedImage == null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Take a photo or choose from gallery',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              icon: 'photo_library',
                              label: 'Gallery',
                              onTap: _pickFromGallery,
                            ),
                            _buildCaptureButton(),
                            _buildControlButton(
                              icon: 'flip_camera_ios',
                              label: 'Flip',
                              onTap: _flipCamera,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isProcessing
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            strokeWidth: 3.0,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Analyzing image...',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Finding similar products',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        margin: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10.0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: kIsWeb
                              ? Image.network(
                                  _capturedImage!.path,
                                  fit: BoxFit.contain,
                                )
                              : Image.network(
                                  _capturedImage!.path,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
              ),
            ),
            if (!_isProcessing)
              SafeArea(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: 'refresh',
                        label: 'Retake',
                        onTap: _retakePhoto,
                      ),
                      _buildControlButton(
                        icon: 'search',
                        label: 'Search',
                        onTap: _processImage,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _capturePhoto,
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 4.0,
          ),
        ),
        child: Center(
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12.0),
          border: isPrimary
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.0,
                ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isPrimary
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : Colors.white,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: isPrimary
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _flipCamera() async {
    if (_cameras.length < 2) return;

    final currentCamera = _cameraController!.description;
    final newCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection != currentCamera.lensDirection,
      orElse: () => currentCamera,
    );

    if (newCamera != currentCamera) {
      await _cameraController!.dispose();
      _cameraController = CameraController(
        newCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      await _applySettings();
      setState(() {});
    }
  }
}
