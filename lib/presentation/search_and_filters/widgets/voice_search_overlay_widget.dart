import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceSearchOverlayWidget extends StatefulWidget {
  final Function(String)? onVoiceResult;
  final VoidCallback? onClose;

  const VoiceSearchOverlayWidget({
    super.key,
    this.onVoiceResult,
    this.onClose,
  });

  @override
  State<VoiceSearchOverlayWidget> createState() =>
      _VoiceSearchOverlayWidgetState();
}

class _VoiceSearchOverlayWidgetState extends State<VoiceSearchOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  final String _recordingPath = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startRecording();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

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
    _pulseController.dispose();
    _scaleController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _requestMicrophonePermission()) {
        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'voice_search.wav',
          );
        } else {
          await _audioRecorder.start(
            const RecordConfig(),
            path: 'voice_search_recording',
          );
        }

        setState(() {
          _isRecording = true;
        });

        _pulseController.repeat(reverse: true);

        // Auto-stop after 10 seconds
        Future.delayed(const Duration(seconds: 10), () {
          if (_isRecording) {
            _stopRecording();
          }
        });
      }
    } catch (e) {
      _showError('Failed to start recording');
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      _pulseController.stop();

      // Simulate voice processing
      await Future.delayed(const Duration(seconds: 2));

      // Mock voice recognition result
      final mockResults = [
        'iPhone 13 Pro Max',
        'Samsung Galaxy S23',
        'MacBook Pro 2023',
        'Nike Air Jordan',
        'Toyota Camry 2022',
        'Apartment for rent',
      ];

      final randomResult =
          mockResults[DateTime.now().millisecond % mockResults.length];

      if (widget.onVoiceResult != null) {
        widget.onVoiceResult!(randomResult);
      }

      _closeOverlay();
    } catch (e) {
      _showError('Failed to process voice');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
    _closeOverlay();
  }

  void _closeOverlay() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 80.w,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor,
                  blurRadius: 20.0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Voice Search',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _closeOverlay,
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                _buildRecordingIndicator(),
                SizedBox(height: 4.h),
                Text(
                  _getStatusText(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                if (_isRecording)
                  ElevatedButton(
                    onPressed: _stopRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.error,
                      foregroundColor: AppTheme.lightTheme.colorScheme.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'stop',
                          color: AppTheme.lightTheme.colorScheme.onError,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text('Stop Recording'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    if (_isProcessing) {
      return Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.onSecondary,
            strokeWidth: 3.0,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: _isRecording
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording
                          ? AppTheme.lightTheme.colorScheme.error
                          : AppTheme.lightTheme.colorScheme.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 20.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _isRecording ? 'mic' : 'mic_off',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStatusText() {
    if (_isProcessing) {
      return 'Processing your voice...';
    } else if (_isRecording) {
      return 'Listening... Speak now to search for items';
    } else {
      return 'Tap the microphone to start voice search';
    }
  }
}
