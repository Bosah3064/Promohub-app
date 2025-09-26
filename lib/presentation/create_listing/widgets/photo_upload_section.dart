import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoUploadSection extends StatefulWidget {
  final Function(List<XFile>) onPhotosChanged;
  final List<XFile> selectedPhotos;

  const PhotoUploadSection({
    super.key,
    required this.onPhotosChanged,
    required this.selectedPhotos,
  });

  @override
  State<PhotoUploadSection> createState() => _PhotoUploadSectionState();
}

class _PhotoUploadSectionState extends State<PhotoUploadSection> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _showCamera = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // Silent fail - camera not available
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {}

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {}
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      final updatedPhotos = List<XFile>.from(widget.selectedPhotos)..add(photo);
      widget.onPhotosChanged(updatedPhotos);
      setState(() {
        _showCamera = false;
      });
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final totalPhotos = widget.selectedPhotos.length + images.length;
        final photosToAdd = totalPhotos > 10
            ? images.take(10 - widget.selectedPhotos.length).toList()
            : images;

        final updatedPhotos = List<XFile>.from(widget.selectedPhotos)
          ..addAll(photosToAdd);
        widget.onPhotosChanged(updatedPhotos);
      }
    } catch (e) {
      // Silent fail
    }
  }

  void _removePhoto(int index) {
    final updatedPhotos = List<XFile>.from(widget.selectedPhotos)
      ..removeAt(index);
    widget.onPhotosChanged(updatedPhotos);
  }

  void _reorderPhotos(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedPhotos = List<XFile>.from(widget.selectedPhotos);
    final item = updatedPhotos.removeAt(oldIndex);
    updatedPhotos.insert(newIndex, item);
    widget.onPhotosChanged(updatedPhotos);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
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
                iconName: 'photo_camera',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Photos',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${widget.selectedPhotos.length}/10',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: widget.selectedPhotos.length >= 10
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (_showCamera && _isCameraInitialized && _cameraController != null)
            Container(
              height: 40.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    CameraPreview(_cameraController!),
                    Positioned(
                      bottom: 2.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () =>
                                setState(() => _showCamera = false),
                            icon: CustomIconWidget(
                              iconName: 'close',
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          GestureDetector(
                            onTap: _capturePhoto,
                            child: Container(
                              width: 15.w,
                              height: 15.w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _pickFromGallery,
                            icon: CustomIconWidget(
                              iconName: 'photo_library',
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            widget.selectedPhotos.isEmpty
                ? _buildEmptyPhotoState()
                : _buildPhotoGrid(),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotoState() {
    return Container(
      height: 25.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'add_photo_alternate',
            color: AppTheme.lightTheme.colorScheme.outline,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Add photos to showcase your item',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() => _showCamera = true),
                icon: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 16,
                ),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                ),
              ),
              SizedBox(width: 4.w),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: CustomIconWidget(
                  iconName: 'photo_library',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      children: [
        ReorderableWrap(
          spacing: 2.w,
          runSpacing: 2.w,
          onReorder: _reorderPhotos,
          children: [
            ...widget.selectedPhotos.asMap().entries.map((entry) {
              final index = entry.key;
              final photo = entry.value;
              return _buildPhotoThumbnail(photo, index);
            }),
            if (widget.selectedPhotos.length < 10) _buildAddPhotoButton(),
          ],
        ),
        if (widget.selectedPhotos.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            'Tap and hold to reorder photos. First photo will be the main image.',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoThumbnail(XFile photo, int index) {
    return Container(
      key: ValueKey(photo.path),
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: index == 0
            ? Border.all(color: AppTheme.lightTheme.primaryColor, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? Image.network(
                    photo.path,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                      child: CustomIconWidget(
                        iconName: 'broken_image',
                        color: AppTheme.lightTheme.colorScheme.outline,
                        size: 24,
                      ),
                    ),
                  )
                : CustomImageWidget(
                    imageUrl: photo.path,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                  ),
          ),
          if (index == 0)
            Positioned(
              top: 1.w,
              left: 1.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'MAIN',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 1.w,
            right: 1.w,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onError,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () => _showPhotoOptions(),
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add',
              color: AppTheme.lightTheme.colorScheme.outline,
              size: 24,
            ),
            Text(
              'Add',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _showCamera = true);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class ReorderableWrap extends StatefulWidget {
  final List<Widget> children;
  final Function(int, int) onReorder;
  final double spacing;
  final double runSpacing;

  const ReorderableWrap({
    super.key,
    required this.children,
    required this.onReorder,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
  });

  @override
  State<ReorderableWrap> createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: widget.children,
    );
  }
}
