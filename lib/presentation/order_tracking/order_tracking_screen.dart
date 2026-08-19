import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_export.dart';
import '../../services/firebase_service.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  String _currentStatus = 'pending_payment';
  var _trackingSubscription;
  bool _isLoading = true;
  Map<String, dynamic>? _orderData;

  final List<Map<String, dynamic>> _statusTimeline = [
    {'status': 'pending_payment', 'label': 'Order Placed', 'icon': Icons.receipt_long},
    {'status': 'processing', 'label': 'Processing', 'icon': Icons.inventory_2_outlined},
    {'status': 'shipped', 'label': 'Shipped', 'icon': Icons.local_shipping_outlined},
    {'status': 'out_for_delivery', 'label': 'Out for Delivery', 'icon': Icons.directions_bike},
    {'status': 'delivered', 'label': 'Delivered', 'icon': Icons.check_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialStatus();
    _setupRealtime();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitialStatus() async {
    try {
      final doc = await FirebaseService().firestore.collection('orders').doc(widget.orderId).get();
      if (mounted) {
        setState(() {
          _orderData = doc.exists ? doc.data() : null;
          _currentStatus = _orderData?['status'] ?? 'pending_payment';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setupRealtime() async {
    try {
      final firestore = FirebaseService().firestore;
      _trackingSubscription = firestore
          .collection('orders')
          .doc(widget.orderId)
          .snapshots()
          .listen((snapshot) {
        if (mounted && snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final newStatus = data['status'];
          if (newStatus != null && newStatus != _currentStatus) {
            setState(() {
              _currentStatus = newStatus;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order status updated: $newStatus'),
                backgroundColor: AppTheme.primaryLight,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      });
    } catch (e) {
      debugPrint('Realtime setup error: $e');
    }
  }

  int get _currentStepIndex {
    final index = _statusTimeline.indexWhere((step) => step['status'] == _currentStatus);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Track Order', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimaryLight,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID Header
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primaryVariantLight],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryLight.withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.local_shipping, color: Colors.white, size: 28),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order ID', style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                              Text(widget.orderId.toUpperCase().substring(0, 8), style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  
                  // Live Tracking Indicator
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.successLight,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppTheme.successLight, blurRadius: 8)],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text('Live Tracking Active', style: TextStyle(color: AppTheme.successLight, fontWeight: FontWeight.w600, fontSize: 11.sp)),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Timeline
                  Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppTheme.shadowLight, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      children: List.generate(_statusTimeline.length, (index) {
                        final step = _statusTimeline[index];
                        final isCompleted = index <= _currentStepIndex;
                        final isCurrent = index == _currentStepIndex;
                        
                        return _buildTimelineStep(
                          step['label'], 
                          step['icon'], 
                          isCompleted, 
                          isCurrent, 
                          isLast: index == _statusTimeline.length - 1
                        );
                      }),
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  // Help / Support
                  // Help / Support / Trust Actions
                  if (_currentStatus == 'delivered' || _currentStatus == 'completed') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showReviewBottomSheet,
                        icon: Icon(Icons.star_rate_rounded),
                        label: Text('Leave a Review'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showDisputeDialog,
                      icon: Icon(Icons.warning_amber_rounded, color: AppTheme.errorLight),
                      label: Text('Report an Issue', style: TextStyle(color: AppTheme.errorLight)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        side: BorderSide(color: AppTheme.errorLight.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimelineStep(String label, IconData icon, bool isCompleted, bool isCurrent, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.primaryLight : AppTheme.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: isCompleted ? AppTheme.primaryLight : AppTheme.dividerLight, width: 2),
              ),
              child: Icon(icon, size: 20, color: isCompleted ? Colors.white : AppTheme.textDisabledLight),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 4.h,
                color: isCompleted && !isCurrent ? AppTheme.primaryLight : AppTheme.dividerLight,
              ),
          ],
        ),
        SizedBox(width: 4.w),
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.w600 : FontWeight.w400),
                  color: isCompleted ? AppTheme.textPrimaryLight : AppTheme.textDisabledLight,
                ),
              ),
              if (isCurrent)
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Text(
                    'Current Status',
                    style: TextStyle(color: AppTheme.primaryLight, fontSize: 10.sp, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReviewBottomSheet() {
    int rating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 5.w,
              right: 5.w,
              top: 3.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rate the Seller', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 1.h),
                Text('How was your experience?', style: TextStyle(color: AppTheme.textSecondaryLight)),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () => setModalState(() => rating = index + 1),
                    );
                  }),
                ),
                SizedBox(height: 3.h),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write a review (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            setModalState(() => isSubmitting = true);
                            try {
                              await MarketplaceService().submitReview(
                                orderId: widget.orderId,
                                shopId: _orderData?['shop_id'] ?? '',
                                rating: rating,
                                comment: commentController.text.trim(),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review submitted!')));
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryLight, foregroundColor: Colors.white),
                    child: isSubmitting ? CircularProgressIndicator(color: Colors.white) : Text('Submit Review'),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDisputeDialog() {
    String selectedReason = 'item_not_received';
    final descController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Report an Issue', style: TextStyle(fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 1.h),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: const [
                      DropdownMenuItem(value: 'item_not_received', child: Text('Item not received')),
                      DropdownMenuItem(value: 'damaged_item', child: Text('Damaged item')),
                      DropdownMenuItem(value: 'wrong_item', child: Text('Wrong item sent')),
                      DropdownMenuItem(value: 'significantly_different', child: Text('Not as described')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (val) => setDialogState(() => selectedReason = val!),
                  ),
                  SizedBox(height: 2.h),
                  Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Explain the issue in detail...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondaryLight)),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (descController.text.trim().isEmpty) return;
                        setDialogState(() => isSubmitting = true);
                        try {
                          await MarketplaceService().openDispute(
                            orderId: widget.orderId,
                            reason: selectedReason,
                            description: descController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dispute opened. Support will contact you.')));
                          }
                        } catch (e) {
                          setDialogState(() => isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorLight, foregroundColor: Colors.white),
                child: isSubmitting ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
