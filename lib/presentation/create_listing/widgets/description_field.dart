import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DescriptionField extends StatefulWidget {
  final String? description;
  final Function(String) onDescriptionChanged;

  const DescriptionField({
    super.key,
    this.description,
    required this.onDescriptionChanged,
  });

  @override
  State<DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<DescriptionField> {
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showFormatting = false;
  int _characterCount = 0;
  static const int _maxCharacters = 2000;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.description ?? '';
    _characterCount = _descriptionController.text.length;
    _descriptionController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _descriptionController.text.length;
    });
    widget.onDescriptionChanged(_descriptionController.text);
  }

  void _insertText(String text) {
    final currentText = _descriptionController.text;
    final selection = _descriptionController.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );

    _descriptionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length,
      ),
    );
  }

  void _addBulletPoint() {
    final currentText = _descriptionController.text;
    final selection = _descriptionController.selection;

    String bulletText = '• ';
    if (selection.start > 0 && currentText[selection.start - 1] != '\n') {
      bulletText = '\n• ';
    }

    _insertText(bulletText);
  }

  void _addNumberedPoint() {
    final currentText = _descriptionController.text;
    final selection = _descriptionController.selection;

    // Count existing numbered points
    final beforeCursor = currentText.substring(0, selection.start);
    final numberedPoints =
        RegExp(r'^\d+\.\s', multiLine: true).allMatches(beforeCursor).length;

    String numberedText = '${numberedPoints + 1}. ';
    if (selection.start > 0 && currentText[selection.start - 1] != '\n') {
      numberedText = '\n${numberedPoints + 1}. ';
    }

    _insertText(numberedText);
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
                iconName: 'description',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Description',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _showFormatting = !_showFormatting),
                icon: CustomIconWidget(
                  iconName:
                      _showFormatting ? 'expand_less' : 'format_list_bulleted',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                label: Text(
                  'Format',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                ),
              ),
            ],
          ),
          if (_showFormatting) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formatting Options',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addBulletPoint,
                          icon: CustomIconWidget(
                            iconName: 'fiber_manual_record',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 12,
                          ),
                          label: const Text('Bullet'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            textStyle:
                                AppTheme.lightTheme.textTheme.labelMedium,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _addNumberedPoint,
                          icon: CustomIconWidget(
                            iconName: 'format_list_numbered',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 16,
                          ),
                          label: const Text('Number'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            textStyle:
                                AppTheme.lightTheme.textTheme.labelMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 2.h),
          TextFormField(
            controller: _descriptionController,
            focusNode: _focusNode,
            maxLines: 8,
            maxLength: _maxCharacters,
            decoration: InputDecoration(
              hintText:
                  'Describe your item in detail...\n\nInclude:\n• Condition and age\n• Key features\n• Reason for selling\n• Any defects or issues',
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
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info_outline',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Be honest and detailed to attract serious buyers',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                '$_characterCount/$_maxCharacters',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _characterCount > _maxCharacters * 0.9
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
