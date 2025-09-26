import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencyPreviewWidget extends StatelessWidget {
  final String currencyCode;
  final List<Map<String, dynamic>> currencies;

  const CurrencyPreviewWidget({
    super.key,
    required this.currencyCode,
    required this.currencies,
  });

  @override
  Widget build(BuildContext context) {
    final currency = currencies.firstWhere(
      (c) => c['code'] == currencyCode,
      orElse: () => {},
    );

    if (currency.isEmpty) return const SizedBox.shrink();

    final symbol = currency['symbol'] ?? '';
    final name = currency['name'] ?? '';
    final exchangeRate =
        (currency['exchange_rate_to_usd'] as num?)?.toDouble() ?? 1.0;

    // Sample prices for preview
    final samplePrices = [10.0, 25.0, 50.0, 100.0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    symbol,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        currencyCode,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    '1 USD = ${exchangeRate.toStringAsFixed(2)} $currencyCode',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            Divider(color: Colors.grey[200]),

            SizedBox(height: 1.h),

            Text(
              'Price Preview',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),

            SizedBox(height: 1.h),

            // Sample price conversions
            Wrap(
              spacing: 3.w,
              runSpacing: 1.h,
              children: samplePrices.map((usdPrice) {
                final convertedPrice = usdPrice * exchangeRate;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '\$${usdPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      Icon(
                        Icons.arrow_downward,
                        size: 12.sp,
                        color: Colors.grey[400],
                      ),
                      Text(
                        '$symbol${convertedPrice.toStringAsFixed(currency['decimal_places'] ?? 2)}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 2.h),

            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14.sp,
                    color: Colors.orange[700],
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Exchange rates are updated regularly. Actual prices may vary based on current market rates.',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
