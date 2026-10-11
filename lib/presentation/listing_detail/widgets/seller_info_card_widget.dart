import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../theme/app_theme.dart';

class SellerInfoCardWidget extends StatefulWidget {
  final Map<String, dynamic> seller;
  final VoidCallback onViewProfile;

  const SellerInfoCardWidget({
    super.key,
    required this.seller,
    required this.onViewProfile,
  });

  @override
  State<SellerInfoCardWidget> createState() => _SellerInfoCardWidgetState();
}

class _SellerInfoCardWidgetState extends State<SellerInfoCardWidget> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final primary = theme.colorScheme.primary;

    final String name = widget.seller["name"] as String? ?? 'Official Store';
    final String sellerScore = widget.seller["sellerScore"] as String? ?? '96%';
    final String followers = widget.seller["followers"] as String? ?? '4,342';
    final String avatarUrl = widget.seller["profileImage"] as String? ?? '';
    final String shippingSpeed = widget.seller["shippingSpeed"] as String? ?? 'Excellent';
    final String qualityScore = widget.seller["qualityScore"] as String? ?? 'Excellent';
    final String customerRating = widget.seller["customerRating"] as String? ?? 'Good';
    final String cancellationRate = widget.seller["cancellationRate"] as String? ?? 'Low (0.8%)';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      padding: EdgeInsets.all(4.w),
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
          // Header Row
          Row(
            children: [
              // Store Avatar
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackAvatar(name, primary),
                          )
                        : _buildFallbackAvatar(name, primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 3.5.w),

              // Store name and followers
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.4.h),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '$sellerScore Seller Score',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '$followers Followers',
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

              // Follow Store Button
              OutlinedButton(
                onPressed: () {
                  setState(() => _isFollowing = !_isFollowing);
                },
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: BorderSide(color: _isFollowing ? Colors.grey : primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: _isFollowing ? Colors.grey.shade100 : Colors.white,
                ),
                child: Text(
                  _isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _isFollowing ? Colors.grey.shade700 : primary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
          const Divider(height: 1),
          SizedBox(height: 1.5.h),

          // Operational Performance Metrics Grid (Jumia Style)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Order Shipping',
                  shippingSpeed,
                  Colors.green.shade700,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Quality Score',
                  qualityScore,
                  Colors.green.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Customer Rating',
                  customerRating,
                  Colors.blue.shade700,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Cancellation Rate',
                  cancellationRate,
                  Colors.amber.shade800,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // View Store profile link
          Center(
            child: InkWell(
              onTap: widget.onViewProfile,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Visit Official Store',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.3.h),
        Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 13, color: statusColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar(String name, Color primary) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1) : 'S',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
      ),
    );
  }
}
