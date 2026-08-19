import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/app_export.dart';
import '../../../../theme/app_theme.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> seller;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onMessageSeller;
  final bool isAddingToCart;

  const ActionButtonsWidget({
    super.key,
    required this.seller,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onMessageSeller,
    this.isAddingToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 3.h),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMessageSeller,
                    icon: Icon(Icons.chat_bubble_outline, color: AppTheme.primaryLight, size: 20),
                    label: Text(
                      'Chat',
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      side: BorderSide(color: AppTheme.primaryLight.withValues(alpha: 0.3), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isAddingToCart ? null : () {
                      HapticFeedback.mediumImpact();
                      onAddToCart();
                    },
                    icon: isAddingToCart 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryLight))
                      : Icon(Icons.add_shopping_cart, color: AppTheme.primaryLight, size: 20),
                    label: Text(
                      isAddingToCart ? 'Adding...' : 'Add to Cart',
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              height: 6.5.h,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  onBuyNow();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppTheme.primaryLight.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
