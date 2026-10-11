import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../../theme/app_theme.dart';

class ActionButtonsWidget extends StatefulWidget {
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
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.lightTheme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 2.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quantity Selector & Chat Row
            Row(
              children: [
                // Chat Seller Button
                InkWell(
                  onTap: widget.onMessageSeller,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Chat',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Quantity Stepper (- 1 +)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.2.h),

            // Cart & Buy Now Buttons Row
            Row(
              children: [
                // Add to Cart Button
                Expanded(
                  child: SizedBox(
                    height: 5.5.h,
                    child: OutlinedButton.icon(
                      onPressed: widget.isAddingToCart
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              widget.onAddToCart();
                            },
                      icon: widget.isAddingToCart
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primary,
                              ),
                            )
                          : Icon(Icons.shopping_cart_outlined, color: primary, size: 20),
                      label: Text(
                        widget.isAddingToCart ? 'Adding...' : 'Add to Cart',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // Buy Now Button
                Expanded(
                  child: SizedBox(
                    height: 5.5.h,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        widget.onBuyNow();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
