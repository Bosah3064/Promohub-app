import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  final MarketplaceService _marketplaceService = MarketplaceService();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _loadCart();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    try {
      final items = await _marketplaceService.getCart();
      if (mounted) {
        setState(() {
          _cartItems = items;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeController.forward();
      }
    }
  }

  double get _subtotal {
    double total = 0;
    for (var item in _cartItems) {
      final listing = item['listing_id'];
      if (listing is Map) {
        total += (listing['price'] ?? 0) * (item['quantity'] ?? 1);
      }
    }
    return total;
  }

  double get _deliveryFee => _cartItems.isEmpty ? 0 : 350.0;

  Future<void> _removeItem(String cartId) async {
    HapticFeedback.lightImpact();
    try {
      await _marketplaceService.removeFromCart(cartId);
      setState(() {
        _cartItems.removeWhere((item) => item['id'] == cartId);
      });
      Fluttertoast.showToast(msg: 'Item removed');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error removing item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Cart', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimaryLight,
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: () async {
                try {
                  await _marketplaceService.clearCart();
                  setState(() => _cartItems.clear());
                  Fluttertoast.showToast(msg: 'Cart cleared');
                } catch (e) {
                  Fluttertoast.showToast(msg: 'Error clearing cart');
                }
              },
              child: Text('Clear All', style: TextStyle(color: AppTheme.secondaryLight)),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : _cartItems.isEmpty
              ? _buildEmptyCart()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildCartContent(),
                ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          height: 12.h,
          decoration: BoxDecoration(
            color: AppTheme.dividerLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryLight.withValues(alpha: 0.1),
                  AppTheme.secondaryLight.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: AppTheme.primaryLight.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Your cart is empty',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Browse the marketplace and add items\nyou love to your cart',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/marketplace-home'),
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Explore Marketplace'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_cartItems[index], index);
            },
          ),
        ),
        _buildCheckoutBar(),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final listing = item['listing_id'];
    final String title = listing is Map ? (listing['title'] ?? 'Product') : 'Product';
    final double price = listing is Map ? (listing['price']?.toDouble() ?? 0) : 0;
    final int quantity = item['quantity'] ?? 1;
    final shop = listing is Map ? listing['shop_id'] : null;
    final String shopName = shop is Map ? (shop['name'] ?? '') : '';
    final images = listing is Map ? (listing['images'] as List?) : null;
    final String? imageUrl = images != null && images.isNotEmpty ? images.first : null;

    return Dismissible(
      key: Key(item['id'] ?? 'cart_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.only(right: 5.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.errorLight.withValues(alpha: 0.7), AppTheme.errorLight],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _removeItem(item['id']),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.backgroundLight,
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Icon(Icons.image_outlined, color: AppTheme.textDisabledLight, size: 30)
                  : null,
            ),
            SizedBox(width: 3.w),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shopName.isNotEmpty)
                    Text(
                      shopName,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  SizedBox(height: 0.5.h),
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KSh ${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.dividerLight),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        _quantityButton(Icons.remove, () async {
                          final newQty = quantity - 1;
                          try {
                            await _marketplaceService.updateCartQuantity(item['id'], newQty);
                            if (newQty <= 0) {
                              setState(() => _cartItems.removeAt(_cartItems.indexOf(item)));
                            } else {
                              setState(() => item['quantity'] = newQty);
                            }
                          } catch (e) {
                            Fluttertoast.showToast(msg: 'Error updating quantity');
                          }
                        }),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Text('$quantity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp)),
                            ),
                            _quantityButton(Icons.add, () async {
                              final newQty = quantity + 1;
                              try {
                                await _marketplaceService.updateCartQuantity(item['id'], newQty);
                                setState(() => item['quantity'] = newQty);
                              } catch (e) {
                                Fluttertoast.showToast(msg: 'Error updating quantity');
                              }
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(1.5.w),
        child: Icon(icon, size: 16, color: AppTheme.textSecondaryLight),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Order summary
          _summaryRow('Subtotal', 'KSh ${_subtotal.toStringAsFixed(0)}'),
          SizedBox(height: 1.h),
          _summaryRow('Delivery Fee', 'KSh ${_deliveryFee.toStringAsFixed(0)}'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            child: Divider(color: AppTheme.dividerLight),
          ),
          _summaryRow(
            'Total',
            'KSh ${(_subtotal + _deliveryFee).toStringAsFixed(0)}',
            isBold: true,
          ),
          SizedBox(height: 2.h),
          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 6.5.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/checkout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 18),
                  SizedBox(width: 2.w),
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13.sp : 11.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
            color: isBold ? AppTheme.textPrimaryLight : AppTheme.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14.sp : 11.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? AppTheme.primaryLight : AppTheme.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
