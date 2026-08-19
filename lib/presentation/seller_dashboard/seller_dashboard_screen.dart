import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../services/firebase_service.dart';
import '../../services/wallet_service.dart';
import '../../theme/app_theme.dart';

class SellerDashboardScreen extends StatefulWidget {
  final String shopId;
  const SellerDashboardScreen({super.key, required this.shopId});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final WalletService _walletService = WalletService();
  bool _isLoading = true;
  Map<String, dynamic>? _shopDetails;
  Map<String, dynamic> _walletData = {};
  
  // Real-time listener for orders
  var _orderSubscription;
  List<Map<String, dynamic>> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _setupRealtime();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    try {
      // Load wallet data and orders in parallel
      final results = await Future.wait([
        _walletService.getWallet(),
        _marketplaceService.getSellerOrders(widget.shopId),
      ]);

      final wallet = results[0] as Map<String, dynamic>;
      final orders = results[1] as List<Map<String, dynamic>>;

      final activeCount = orders.where((o) => !['completed', 'cancelled', 'refunded'].contains(o['status'])).length;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _walletData = wallet;
          _shopDetails = {
            'name': 'My Shop',
            'balance': (wallet['available_balance'] as num?)?.toDouble() ?? 0.0,
            'pending': (wallet['pending_balance'] as num?)?.toDouble() ?? 0.0,
            'activeOrders': activeCount,
            'totalSales': orders.length,
          };
          _recentOrders = orders.take(5).map((o) {
            return {
              'id': 'ORD-${(o['id'] as String).substring(0, 4).toUpperCase()}',
              'amount': 'KSh ${o['total_amount']}',
              'status': o['status'] ?? 'pending',
              'time': _formatTime(o['created_at']),
            };
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return 'Recently';
    try {
      final dt = DateTime.parse(createdAt.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 5) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Recently';
    }
  }

  Future<void> _setupRealtime() async {
    try {
      final firestore = FirebaseService().firestore;
      _orderSubscription = firestore
          .collection('orders')
          .where('shop_id', isEqualTo: widget.shopId)
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          _handleOrderUpdate(change);
        }
      });
    } catch (e) {
      debugPrint('Failed to set up realtime: $e');
    }
  }

  void _handleOrderUpdate(DocumentChange change) {
    if (!mounted) return;
    
    setState(() {
      if (change.type == DocumentChangeType.added) {
        final newOrder = change.doc.data() as Map<String, dynamic>;
        final newOrderId = change.doc.id;
        _recentOrders.insert(0, {
          'id': 'ORD-${newOrderId.substring(0, 4).toUpperCase()}',
          'amount': 'KSh ${newOrder['total_amount']}',
          'status': newOrder['status'],
          'time': 'Just now'
        });
        
        // Update stats
        if (_shopDetails != null) {
          _shopDetails!['activeOrders'] = (_shopDetails!['activeOrders'] as int) + 1;
          _shopDetails!['pending'] = (_shopDetails!['pending'] as double) + ((newOrder['total_amount'] as num?)?.toDouble() ?? 0.0);
        }
      } else if (change.type == DocumentChangeType.modified) {
        final updatedOrder = change.doc.data() as Map<String, dynamic>;
        final updatedOrderId = change.doc.id;
        final shortId = 'ORD-${updatedOrderId.substring(0, 4).toUpperCase()}';
        
        final index = _recentOrders.indexWhere((o) => o['id'] == shortId);
        if (index != -1) {
          _recentOrders[index]['status'] = updatedOrder['status'];
        }
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dashboard updated: Order ${change.type.name}'),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Seller Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimaryLight,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & Wallet Card
                    _buildWalletCard(),
                    SizedBox(height: 3.h),
                    
                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Active Orders', '${_shopDetails?['activeOrders'] ?? 0}', Icons.shopping_bag_outlined, AppTheme.secondaryLight)),
                        SizedBox(width: 3.w),
                        Expanded(child: _buildStatCard('Total Sales', '${_shopDetails?['totalSales'] ?? 0}', Icons.bar_chart_rounded, AppTheme.primaryLight)),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    
                    // Sales Chart placeholder
                    _buildSectionHeader('Weekly Sales'),
                    SizedBox(height: 1.5.h),
                    _buildChartCard(),
                    
                    SizedBox(height: 3.h),
                    
                    // Payouts & Statements
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Payouts & Statements'),
                        TextButton(
                          onPressed: () {},
                          child: Text('View All', style: TextStyle(color: AppTheme.secondaryLight)),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    _buildPayoutsCard(),
                    
                    SizedBox(height: 3.h),
                    
                    // Recent Orders
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Recent Orders'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/seller-orders', arguments: widget.shopId);
                          },
                          child: Text('View All', style: TextStyle(color: AppTheme.primaryLight)),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    ..._recentOrders.map((order) => _buildOrderTile(
                      order['id'] as String,
                      order['amount'] as String,
                      order['status'] as String,
                      order['time'] as String,
                    )),
                    
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryLight, AppTheme.primaryVariantLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryLight.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w500)),
              GestureDetector(
                onTap: _showWithdrawBottomSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                  child: Text('Withdraw', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'KSh ${_shopDetails?['balance']?.toStringAsFixed(0) ?? 0}',
            style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(Icons.pending_actions, color: Colors.white70, size: 16),
              SizedBox(width: 1.w),
              Text('KSh ${_shopDetails?['pending']?.toStringAsFixed(0) ?? 0} clearing soon', 
                style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 2.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryLight)),
          Text(title, style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondaryLight, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryLight),
    );
  }

  Widget _buildPayoutsCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.shadowLight, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance_wallet_outlined, color: AppTheme.successLight),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next Payout (Est.)', style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondaryLight)),
                    Text('KSh 12,450', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryLight)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Status', style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondaryLight)),
                  Text('Processing', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppTheme.secondaryLight)),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Divider(color: AppTheme.dividerLight),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pending Commissions Deduction:', style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondaryLight)),
              Text('KSh 850', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.errorLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 22.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.shadowLight, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 1.5),
                FlSpot(2, 1.4),
                FlSpot(3, 3.4),
                FlSpot(4, 2),
                FlSpot(5, 2.2),
                FlSpot(6, 1.8),
              ],
              isCurved: true,
              color: AppTheme.primaryLight,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(String id, String amount, String status, String time) {
    Color statusColor;
    switch(status) {
      case 'pending': statusColor = AppTheme.warningLight; break;
      case 'shipped': statusColor = AppTheme.secondaryLight; break;
      case 'delivered': statusColor = AppTheme.successLight; break;
      default: statusColor = AppTheme.textSecondaryLight;
    }

    return GestureDetector(
      onTap: () {
        final dummyOrder = {
          'id': id,
          'status': status,
          'buyer': {
            'full_name': 'Buyer for $id',
            'phone_number': '+254700000000',
          },
          'delivery_method': 'doorstep',
          'total_amount': amount.replaceAll(RegExp(r'[^0-9.]'), ''),
          'order_items': [],
        };
        Navigator.pushNamed(context, '/seller-order-detail', arguments: dummyOrder);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerLight),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.receipt_long_outlined, color: AppTheme.primaryLight),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(id, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.sp)),
                  Text(time, style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 9.sp)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.sp, color: AppTheme.primaryLight)),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 8.sp, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawBottomSheet() {
    final amountController = TextEditingController();
    final available = (_walletData['available_balance'] as num?)?.toDouble() ?? 0.0;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: 5.w, right: 5.w, top: 3.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 3.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 12.w, height: 0.5.h,
                    decoration: BoxDecoration(color: AppTheme.dividerLight, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text('Withdraw to M-Pesa', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 0.5.h),
                Text('Available: KSh ${available.toStringAsFixed(0)}', style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondaryLight)),
                SizedBox(height: 2.5.h),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Amount (KSh)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryLight, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                // Quick amount buttons
                Row(
                  children: [500, 1000, 5000].map((amt) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: OutlinedButton(
                          onPressed: () => amountController.text = amt.toString(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('KSh $amt', style: TextStyle(fontSize: 10.sp)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 2.5.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.5.h,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : () async {
                      final amount = double.tryParse(amountController.text) ?? 0;
                      if (amount <= 0) {
                        Fluttertoast.showToast(msg: 'Enter a valid amount');
                        return;
                      }
                      setSheetState(() => isProcessing = true);
                      try {
                        await _walletService.requestWithdrawal(amount);
                        if (ctx.mounted) Navigator.pop(ctx);
                        Fluttertoast.showToast(msg: 'Withdrawal of KSh ${amount.toStringAsFixed(0)} initiated!');
                        HapticFeedback.heavyImpact();
                        _loadDashboard(); // Refresh balances
                      } catch (e) {
                        setSheetState(() => isProcessing = false);
                        Fluttertoast.showToast(msg: e.toString().replaceAll('Exception: ', ''));
                      }
                    },
                    icon: isProcessing
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                    label: Text(isProcessing ? 'Processing...' : 'Withdraw via M-Pesa',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
