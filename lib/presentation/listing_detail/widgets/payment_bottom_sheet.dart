import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../services/payment_service.dart';
import '../../../widgets/custom_error_widget.dart';

class PaymentBottomSheet extends StatefulWidget {
  final Map<String, dynamic> listing;
  final VoidCallback? onPaymentSuccess;

  const PaymentBottomSheet({
    super.key,
    required this.listing,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  bool _isProcessing = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(widget.listing['price'].toString()) ?? 0.0;
    final processingFee = price * 0.03; // 3% processing fee
    final total = price + processingFee;

    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(5.w))),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 12.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(1.w)))),
              SizedBox(height: 3.h),
              Row(children: [
                Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.w),
                        image: widget.listing['images'] != null &&
                                (widget.listing['images'] as List).isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                    (widget.listing['images'] as List).first),
                                fit: BoxFit.cover)
                            : null),
                    child: widget.listing['images'] == null ||
                            (widget.listing['images'] as List).isEmpty
                        ? Icon(Icons.image, color: Colors.grey[400], size: 8.w)
                        : null),
                SizedBox(width: 3.w),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(widget.listing['title'] ?? 'Unknown Item',
                          style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 0.5.h),
                      Text(
                          'Sold by ${widget.listing['seller']?['full_name'] ?? 'Unknown'}',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp, color: Colors.grey[600])),
                    ])),
              ]),
              SizedBox(height: 3.h),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 2.h),
              Text('Payment Summary',
                  style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              SizedBox(height: 2.h),
              _buildPriceRow('Item Price', '\$${price.toStringAsFixed(2)}'),
              SizedBox(height: 1.h),
              _buildPriceRow('Processing Fee (3%)',
                  '\$${processingFee.toStringAsFixed(2)}'),
              SizedBox(height: 1.h),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 1.h),
              _buildPriceRow('Total', '\$${total.toStringAsFixed(2)}',
                  isTotal: true),
              if (_error != null) ...[
                SizedBox(height: 2.h),
                CustomErrorWidget(
                  message: 'sorry ',
                ),
              ],
              SizedBox(height: 3.h),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed:
                            _isProcessing ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.w))),
                        child: Text('Cancel',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600)))),
                SizedBox(width: 3.w),
                Expanded(
                    flex: 2,
                    child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.w))),
                        child: _isProcessing
                            ? SizedBox(
                                height: 4.w,
                                width: 4.w,
                                child: const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Pay \$${total.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)))),
              ]),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 2.h),
            ]));
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black87 : Colors.grey[600])),
      Text(amount,
          style: GoogleFonts.inter(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.black87 : Colors.black87)),
    ]);
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final price = double.tryParse(widget.listing['price'].toString()) ?? 0.0;
      final processingFee = price * 0.03;
      final total = price + processingFee;

      // Create payment intent
      final paymentData = await PaymentService()
          .createPaymentIntent(listingId: widget.listing['id'], amount: total);

      // In a real app, you would integrate with Stripe's mobile SDK here
      // For demo purposes, we'll simulate payment completion
      await Future.delayed(const Duration(seconds: 2));

      // Confirm payment
      await PaymentService().confirmPayment(paymentData['transaction_id']);

      if (mounted) {
        Navigator.pop(context);
        widget.onPaymentSuccess?.call();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Payment successful! You have purchased ${widget.listing['title']}',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
