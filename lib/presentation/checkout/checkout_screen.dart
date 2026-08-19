import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../services/payment_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final PaymentService _paymentService = PaymentService();
  final FirebaseService _firebaseService = FirebaseService();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  int _selectedPaymentMethod = 0; // 0 = M-Pesa, 1 = Card
  int _selectedDeliveryOption = 0; // 0 = Doorstep, 1 = Pickup Station
  bool _isProcessing = false;
  double _orderTotal = 0;
  final double _deliveryFee = 350;

  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartForCheckout();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCartForCheckout() async {
    try {
      final items = await _marketplaceService.getCart();
      double subtotal = 0;
      for (var item in items) {
        final listing = item['listing_id'];
        if (listing is Map) {
          subtotal += (listing['price'] ?? 0) * (item['quantity'] ?? 1);
        }
      }
      if (mounted) {
        setState(() {
          _cartItems = items;
          _orderTotal = subtotal;
        });
      }
    } catch (e) {
      // Cart may be empty
    }
  }

  Future<void> _processPayment() async {
    if (_addressController.text.trim().isEmpty &&
        _selectedDeliveryOption == 0) {
      Fluttertoast.showToast(msg: 'Please enter your delivery address');
      return;
    }
    if (_phoneController.text.trim().isEmpty && _selectedPaymentMethod == 0) {
      Fluttertoast.showToast(msg: 'Please enter your M-Pesa phone number');
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) throw Exception('Not authenticated');

      // 1. Create the order
      final deliveryFee = _selectedDeliveryOption == 0 ? _deliveryFee : 0.0;
      final grandTotal = _orderTotal + deliveryFee;

      final orderData = {
        'buyer_id': userId,
        'total_amount': grandTotal,
        'delivery_fee_charged': deliveryFee,
        'delivery_method': _selectedDeliveryOption == 0 ? 'doorstep' : 'pickup',
        'delivery_address': _selectedDeliveryOption == 0
            ? _addressController.text.trim()
            : 'Nairobi CBD Pickup',
        'status': 'pending_payment',
      };

      final orderItems = _cartItems.map((item) {
        final listing = item['listing_id'] as Map<String, dynamic>? ?? {};
        return {
          'listing_id': listing['id'],
          'quantity': item['quantity'] ?? 1,
          'unit_price': listing['price'] ?? 0,
        };
      }).toList();

      final order =
          await _marketplaceService.createOrder(orderData, orderItems);
      final orderId = order['id'] as String;

      // 2. Initiate payment
      if (_selectedPaymentMethod == 0) {
        // M-Pesa STK Push
        final result = await _paymentService.initiateMpesaPayment(
          phoneNumber: _phoneController.text.trim(),
          amount: grandTotal,
          orderId: orderId,
        );

        if (result['success'] == true) {
          if (mounted) {
            setState(() => _isProcessing = false);
            _showMpesaWaitingDialog(result['transaction_id'] as String);
          }
        } else {
          throw Exception(result['message'] ?? 'M-Pesa request failed');
        }
      } else {
        // Stripe / Card
        final result = await _paymentService.createStripePaymentIntent(
          orderId: orderId,
          amount: grandTotal,
        );

        if (mounted) {
          setState(() => _isProcessing = false);
          // In production, you'd present the Stripe payment sheet here
          _showPaymentSuccessDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        Fluttertoast.showToast(msg: 'Payment failed: $e');
      }
    }
  }

  void _showMpesaWaitingDialog(String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MpesaWaitingDialog(
        transactionId: transactionId,
        paymentService: _paymentService,
        onSuccess: () {
          Navigator.of(context).pop();
          _showPaymentSuccessDialog();
        },
        onFailed: (msg) {
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: msg);
        },
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.successLight, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              SizedBox(height: 3.h),
              Text(
                'Payment Successful!',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Your order has been placed and the seller has been notified.',
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              SizedBox(height: 1.5.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        color: AppTheme.primaryLight, size: 20),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Your payment is held securely until you confirm delivery.',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pop(); // back to cart or home
                    Navigator.pushReplacementNamed(
                        context, '/marketplace-home');
                  },
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = _orderTotal + _deliveryFee;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimaryLight,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- DELIVERY ---
            _buildSectionHeader(
                'Delivery Option', Icons.local_shipping_outlined),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Expanded(
                    child: _buildDeliveryOptionCard(
                        0, Icons.home_outlined, 'Doorstep', 'KSh 350')),
                SizedBox(width: 3.w),
                Expanded(
                    child: _buildDeliveryOptionCard(1,
                        Icons.location_on_outlined, 'Pickup Station', 'FREE')),
              ],
            ),
            SizedBox(height: 2.h),
            if (_selectedDeliveryOption == 0)
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'e.g., 123 Moi Avenue, Nairobi',
                  prefixIcon: Icon(Icons.pin_drop_outlined,
                      color: AppTheme.primaryLight),
                ),
                maxLines: 2,
              ),
            if (_selectedDeliveryOption == 1)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.primaryLight.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppTheme.primaryLight),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nairobi CBD Pickup',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp)),
                          Text('Kenyatta Avenue, Nairobi',
                              style: TextStyle(
                                  color: AppTheme.textSecondaryLight,
                                  fontSize: 10.sp)),
                        ],
                      ),
                    ),
                    TextButton(onPressed: () {}, child: Text('Change')),
                  ],
                ),
              ),

            SizedBox(height: 3.h),

            // --- PAYMENT METHOD ---
            _buildSectionHeader('Payment Method', Icons.payment_outlined),
            SizedBox(height: 1.5.h),
            _buildPaymentMethodCard(
              0,
              'M-Pesa',
              'Pay via M-Pesa STK Push',
              Icons.phone_android,
              Color(0xFF00A650), // M-Pesa green
            ),
            SizedBox(height: 1.5.h),
            _buildPaymentMethodCard(
              1,
              'Card Payment',
              'Visa, Mastercard (via Paystack)',
              Icons.credit_card,
              Color(0xFF1A73E8),
            ),
            SizedBox(height: 2.h),

            if (_selectedPaymentMethod == 0)
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'M-Pesa Phone Number',
                  hintText: '07XX XXX XXX',
                  prefixIcon: Icon(Icons.phone, color: Color(0xFF00A650)),
                  prefixText: '+254 ',
                ),
                keyboardType: TextInputType.phone,
              ),

            SizedBox(height: 3.h),

            // --- ORDER SUMMARY ---
            _buildSectionHeader('Order Summary', Icons.receipt_long_outlined),
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.cardLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _summaryRow('Items (${_cartItems.length})',
                      'KSh ${_orderTotal.toStringAsFixed(0)}'),
                  SizedBox(height: 1.h),
                  _summaryRow('Delivery Fee',
                      'KSh ${(_selectedDeliveryOption == 0 ? _deliveryFee : 0).toStringAsFixed(0)}'),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    child: Divider(color: AppTheme.dividerLight),
                  ),
                  _summaryRow(
                    'Total',
                    'KSh ${(_selectedDeliveryOption == 1 ? grandTotal - _deliveryFee : grandTotal).toStringAsFixed(0)}',
                    isBold: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Buyer Protection Notice
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryLight.withValues(alpha: 0.08),
                    AppTheme.successLight.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined,
                      color: AppTheme.primaryLight, size: 22),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'PromoHub Buyer Protection: Your money is held safely until you confirm delivery.',
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // --- PAY BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 20),
                          SizedBox(width: 2.w),
                          Text(
                            _selectedPaymentMethod == 0
                                ? 'Pay with M-Pesa'
                                : 'Pay with Card',
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryLight, size: 20),
        SizedBox(width: 2.w),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOptionCard(
      int index, IconData icon, String label, String price) {
    final isSelected = _selectedDeliveryOption == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedDeliveryOption = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withValues(alpha: 0.08)
              : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppTheme.primaryLight
                    : AppTheme.textSecondaryLight,
                size: 28),
            SizedBox(height: 1.h),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                    color: isSelected
                        ? AppTheme.primaryLight
                        : AppTheme.textPrimaryLight)),
            Text(price,
                style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppTheme.primaryLight
                        : AppTheme.textSecondaryLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(int index, String title, String subtitle,
      IconData icon, Color brandColor) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPaymentMethod = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          color: isSelected
              ? brandColor.withValues(alpha: 0.06)
              : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? brandColor : AppTheme.dividerLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: brandColor, size: 24),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12.sp)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 9.sp, color: AppTheme.textSecondaryLight)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: brandColor, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isBold ? 13.sp : 11.sp,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
              color: isBold
                  ? AppTheme.textPrimaryLight
                  : AppTheme.textSecondaryLight,
            )),
        Text(value,
            style: TextStyle(
              fontSize: isBold ? 14.sp : 11.sp,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppTheme.primaryLight : AppTheme.textPrimaryLight,
            )),
      ],
    );
  }
}

class _MpesaWaitingDialog extends StatefulWidget {
  final String transactionId;
  final PaymentService paymentService;
  final VoidCallback onSuccess;
  final Function(String) onFailed;

  const _MpesaWaitingDialog({
    required this.transactionId,
    required this.paymentService,
    required this.onSuccess,
    required this.onFailed,
  });

  @override
  State<_MpesaWaitingDialog> createState() => _MpesaWaitingDialogState();
}

class _MpesaWaitingDialogState extends State<_MpesaWaitingDialog> {
  @override
  void initState() {
    super.initState();
    // Simulate polling or websocket wait in a real app
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Waiting for M-Pesa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 3.h),
          const Text(
              'Please check your phone and enter your M-Pesa PIN to complete the transaction.',
              textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onFailed('Payment cancelled.');
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
