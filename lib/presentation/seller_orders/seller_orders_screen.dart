import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';

class SellerOrdersScreen extends StatefulWidget {
  final String shopId;

  const SellerOrdersScreen({super.key, required this.shopId});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> with SingleTickerProviderStateMixin {
  final MarketplaceService _marketplaceService = MarketplaceService();
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  final List<String> _tabs = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _fetchOrders();
    }
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final status = _tabController.index == 0 ? 'all' : _tabs[_tabController.index].toLowerCase();
      final orders = await _marketplaceService.getSellerOrders(widget.shopId, status: status);
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
      }
    }
  }

  /// Determine the next valid status transition
  String? _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'pending_payment':
      case 'paid':
        return 'processing';
      case 'processing':
        return 'shipped';
      case 'shipped':
        return 'delivered';
      case 'delivered':
        return 'completed';
      default:
        return null;
    }
  }

  String _getActionLabel(String currentStatus) {
    switch (currentStatus) {
      case 'pending_payment':
      case 'paid':
        return 'Accept Order';
      case 'processing':
        return 'Mark Shipped';
      case 'shipped':
        return 'Mark Delivered';
      case 'delivered':
        return 'Complete';
      default:
        return '';
    }
  }

  IconData _getActionIcon(String currentStatus) {
    switch (currentStatus) {
      case 'pending_payment':
      case 'paid':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.local_shipping_outlined;
      case 'shipped':
        return Icons.inventory_outlined;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.check;
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      HapticFeedback.mediumImpact();
      await _marketplaceService.updateOrderStatus(orderId, newStatus);
      Fluttertoast.showToast(msg: 'Order updated to ${newStatus.replaceAll("_", " ").toUpperCase()}');
      _fetchOrders();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Manage Orders', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryLight,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryLight,
          unselectedLabelColor: AppTheme.textSecondaryLight,
          indicatorColor: AppTheme.primaryLight,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchOrders,
                  child: ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.dividerLight),
          SizedBox(height: 2.h),
          Text(
            'No orders found',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryLight),
          ),
          SizedBox(height: 1.h),
          Text(
            'You don\'t have any orders in this category yet.',
            style: TextStyle(color: AppTheme.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final buyer = order['buyer'] as Map<String, dynamic>? ?? {};
    final status = order['status'] as String? ?? 'unknown';
    final nextStatus = _getNextStatus(status);
    
    Color statusColor;
    switch(status) {
      case 'pending_payment':
      case 'paid': 
        statusColor = AppTheme.warningLight; 
        break;
      case 'processing':
      case 'shipped': 
        statusColor = AppTheme.secondaryLight; 
        break;
      case 'delivered': 
      case 'completed':
        statusColor = AppTheme.successLight; 
        break;
      default: 
        statusColor = AppTheme.textSecondaryLight;
    }

    final orderId = order['id']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.shadowLight, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(color: statusColor, fontSize: 9.sp, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            child: Divider(color: AppTheme.dividerLight),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: buyer['avatar_url'] != null ? NetworkImage(buyer['avatar_url']) : null,
                backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
                child: buyer['avatar_url'] == null ? Icon(Icons.person, color: AppTheme.primaryLight) : null,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(buyer['full_name'] ?? 'Guest Buyer', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(order['delivery_method'] == 'pickup' ? 'Pickup Station' : 'Doorstep Delivery', 
                      style: TextStyle(fontSize: 9.sp, color: AppTheme.textSecondaryLight)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('KSh ${order['total_amount']}', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryLight, fontSize: 13.sp)),
                  Text('${order['order_items']?.length ?? 0} items', style: TextStyle(fontSize: 9.sp, color: AppTheme.textSecondaryLight)),
                ],
              ),
            ],
          ),

          // Action buttons for sellers to advance the order
          if (nextStatus != null) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                // Cancel button (only if not yet shipped)
                if (!['shipped', 'delivered', 'completed'].contains(status))
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => _updateOrderStatus(orderId, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorLight,
                        side: BorderSide(color: AppTheme.errorLight.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (!['shipped', 'delivered', 'completed'].contains(status))
                  SizedBox(width: 2.w),

                // Primary action button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(orderId, nextStatus),
                    icon: Icon(_getActionIcon(status), size: 18),
                    label: Text(_getActionLabel(status), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
