import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class PhotoUploadWidget extends StatefulWidget {
  final List<String> selectedImages;
  final Function(List<String>) onImagesChanged;

  const PhotoUploadWidget({
    super.key,
    required this.selectedImages,
    required this.onImagesChanged,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  final List<String> _mockImages = [
    "https://images.pexels.com/photos/90946/pexels-photo-90946.jpeg",
    "https://images.pexels.com/photos/276517/pexels-photo-276517.jpeg",
    "https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg",
    "https://images.pexels.com/photos/7974/pexels-photo.jpg",
    "https://images.pexels.com/photos/163064/play-stone-network-networked-interactive-163064.jpeg",
  ];

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
                  _buildImageSourceOption(
                    'Mock Images',
                    'image',
                    () {
                      Navigator.pop(context);
                      _showMockImagePicker();
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
    if (widget.selectedImages.length < 10) {
      final newImages = List<String>.from(widget.selectedImages);
      newImages.add(_mockImages[newImages.length % _mockImages.length]);
      widget.onImagesChanged(newImages);

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
    if (widget.selectedImages.length < 10) {
      final newImages = List<String>.from(widget.selectedImages);
      newImages.add(_mockImages[newImages.length % _mockImages.length]);
      widget.onImagesChanged(newImages);

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

  void _showMockImagePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Mock Images'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _mockImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (widget.selectedImages.length < 10) {
                      final newImages =
                          List<String>.from(widget.selectedImages);
                      newImages.add(_mockImages[index]);
                      widget.onImagesChanged(newImages);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Maximum 10 photos allowed'),
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageWidget(
                        imageUrl: _mockImages[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _removeImage(int index) {
    final newImages = List<String>.from(widget.selectedImages);
    newImages.removeAt(index);
    widget.onImagesChanged(newImages);
  }

  void _reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final newImages = List<String>.from(widget.selectedImages);
    final item = newImages.removeAt(oldIndex);
    newImages.insert(newIndex, item);
    widget.onImagesChanged(newImages);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Photos',
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
          widget.selectedImages.isEmpty
              ? _buildEmptyState()
              : _buildPhotoGrid(),

          SizedBox(height: 24),

          // Add photo button
          if (widget.selectedImages.length < 10)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: CustomIconWidget(
                  iconName: 'add_photo_alternate',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: Text('Add Photos'),
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
      itemCount: widget.selectedImages.length,
      itemBuilder: (context, index) {
        return Container(
          key: ValueKey(widget.selectedImages[index]),
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
                          imageUrl: widget.selectedImages[index],
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
