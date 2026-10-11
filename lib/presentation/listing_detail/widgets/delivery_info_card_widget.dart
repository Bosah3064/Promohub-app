import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../theme/app_theme.dart';

class DeliveryInfoCardWidget extends StatefulWidget {
  final String location;
  final String? warranty;

  const DeliveryInfoCardWidget({
    super.key,
    this.location = 'Nairobi, Kenya',
    this.warranty = '1 Year Official Warranty',
  });

  @override
  State<DeliveryInfoCardWidget> createState() => _DeliveryInfoCardWidgetState();
}

class _DeliveryInfoCardWidgetState extends State<DeliveryInfoCardWidget> {
  int _selectedDeliveryMethod = 0; // 0 = Door, 1 = Pickup

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final primary = theme.colorScheme.primary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: PromoHub Express
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.1),
                  Colors.amber.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(
                  color: primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
                SizedBox(width: 2.5.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PromoHub Express',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'FASTEST',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Express delivery available in main cities & towns',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Location header
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: primary),
                    SizedBox(width: 1.5.w),
                    Text(
                      'Delivery to: ',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      widget.location,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // Delivery Method 1: Door Delivery
          InkWell(
            onTap: () => setState(() => _selectedDeliveryMethod = 0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<int>(
                    value: 0,
                    groupValue: _selectedDeliveryMethod,
                    onChanged: (v) => setState(() => _selectedDeliveryMethod = v ?? 0),
                    activeColor: primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Door Delivery',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'KSh 200',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          'Estimated delivery: Tomorrow, between 9AM - 5PM',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Delivery Method 2: Pickup Station
          InkWell(
            onTap: () => setState(() => _selectedDeliveryMethod = 1),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<int>(
                    value: 1,
                    groupValue: _selectedDeliveryMethod,
                    onChanged: (v) => setState(() => _selectedDeliveryMethod = v ?? 1),
                    activeColor: primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pickup Station',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'KSh 80',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          'Ready for pickup within 24 hours at nearest PromoHub station',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // Guarantees & Returns
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                _buildGuaranteeItem(
                  icon: Icons.replay_circle_filled_rounded,
                  iconColor: Colors.blue.shade700,
                  title: 'Return Policy',
                  subtitle: 'Easy 7-day return. Quick money refund.',
                ),
                SizedBox(height: 1.5.h),
                _buildGuaranteeItem(
                  icon: Icons.verified_user_rounded,
                  iconColor: Colors.green.shade700,
                  title: 'Warranty Guarantee',
                  subtitle: widget.warranty ?? '1 Year Official Warranty included.',
                ),
                SizedBox(height: 1.5.h),
                _buildGuaranteeItem(
                  icon: Icons.security_rounded,
                  iconColor: Colors.amber.shade800,
                  title: '100% Genuine Product',
                  subtitle: 'Verified by PromoHub Authentic Product Inspection.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
