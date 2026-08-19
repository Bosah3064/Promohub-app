import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const SellerOrderDetailScreen({super.key, required this.order});

  @override
  State<SellerOrderDetailScreen> createState() => _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  late Map<String, dynamic> _order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _marketplaceService.updateOrderStatus(_order['id'], newStatus);
      setState(() {
        _order['status'] = newStatus;
        _isUpdating = false;
      });
      Fluttertoast.showToast(msg: 'Order status updated successfully');
    } catch (e) {
      setState(() => _isUpdating = false);
      Fluttertoast.showToast(msg: 'Failed to update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyer = _order['buyer'] as Map<String, dynamic>? ?? {};
    final items = _order['order_items'] as List<dynamic>? ?? [];
    final currentStatus = _order['status'] as String? ?? 'unknown';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Order Details', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryLight,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Update Order Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp)),
                  SizedBox(height: 1.h),
                  Text('Notify the buyer about their order progress.', style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 10.sp)),
                  SizedBox(height: 2.h),
                  if (_isUpdating)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 2.w,
                      children: [
                        _buildStatusChip('processing', currentStatus),
                        _buildStatusChip('shipped', currentStatus),
                        _buildStatusChip('delivered', currentStatus),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // Buyer Info
            Text('Buyer Information', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: buyer['avatar_url'] != null ? NetworkImage(buyer['avatar_url']) : null,
                    backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
                    child: buyer['avatar_url'] == null ? Icon(Icons.person, color: AppTheme.primaryLight) : null,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(buyer['full_name'] ?? 'Guest Buyer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp)),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: AppTheme.textSecondaryLight),
                            SizedBox(width: 1.w),
                            Text(buyer['phone_number'] ?? 'No phone provided', style: TextStyle(color: AppTheme.textSecondaryLight)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.message, color: AppTheme.primaryLight),
                    onPressed: () {
                      // TODO: Navigate to chat
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // Delivery Details
            Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.all(4.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Method: ${_order['delivery_method'] == 'pickup' ? 'Pickup Station' : 'Doorstep'}', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 1.h),
                  Text('Address:', style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 10.sp)),
                  Text(_order['delivery_address'] ?? 'No address provided', style: TextStyle(fontSize: 11.sp)),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // Order Items
            Text('Ordered Items', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
            SizedBox(height: 1.5.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final listing = item['listing'] as Map<String, dynamic>? ?? {};
                final image = (listing['images'] as List?)?.isNotEmpty == true ? listing['images'][0] : null;

                return Container(
                  margin: EdgeInsets.only(bottom: 1.5.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.dividerLight,
                          image: image != null ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover) : null,
                        ),
                        child: image == null ? Icon(Icons.image, color: Colors.white) : null,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing['title'] ?? 'Unknown Item', style: TextStyle(fontWeight: FontWeight.w600), maxLines: 2),
                            Text('Qty: ${item['quantity']}', style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 10.sp)),
                          ],
                        ),
                      ),
                      Text('KSh ${item['unit_price']}', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryLight)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, String currentStatus) {
    final isSelected = status == currentStatus;
    return ChoiceChip(
      label: Text(status.toUpperCase()),
      selected: isSelected,
      onSelected: (selected) {
        if (selected && !isSelected) {
          _updateStatus(status);
        }
      },
      selectedColor: AppTheme.primaryLight.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondaryLight,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
      ),
    );
  }
}
