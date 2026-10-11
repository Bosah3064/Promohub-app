import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../theme/app_theme.dart';

class CustomerReviewsWidget extends StatefulWidget {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> breakdown;
  final List<Map<String, dynamic>> reviews;

  const CustomerReviewsWidget({
    super.key,
    this.averageRating = 4.6,
    this.totalReviews = 588,
    required this.breakdown,
    required this.reviews,
  });

  @override
  State<CustomerReviewsWidget> createState() => _CustomerReviewsWidgetState();
}

class _CustomerReviewsWidgetState extends State<CustomerReviewsWidget> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final primary = theme.colorScheme.primary;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verified Customer Ratings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    '${widget.totalReviews} verified purchase ratings',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green.shade700, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Rating summary & distribution bar chart
          Row(
            children: [
              // Score Box
              Container(
                width: 28.w,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: primary,
                        height: 1.1,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.averageRating.floor()
                              ? Icons.star_rounded
                              : (index < widget.averageRating
                                  ? Icons.star_half_rounded
                                  : Icons.star_outline_rounded),
                          color: Colors.amber.shade700,
                          size: 16,
                        );
                      }),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${widget.totalReviews} ratings',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),

              // Star progress bars
              Expanded(
                child: Column(
                  children: [
                    _buildStarBar(5, widget.breakdown['5'] ?? 0, widget.totalReviews),
                    _buildStarBar(4, widget.breakdown['4'] ?? 0, widget.totalReviews),
                    _buildStarBar(3, widget.breakdown['3'] ?? 0, widget.totalReviews),
                    _buildStarBar(2, widget.breakdown['2'] ?? 0, widget.totalReviews),
                    _buildStarBar(1, widget.breakdown['1'] ?? 0, widget.totalReviews),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.5.h),

          // Filter tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All (${widget.totalReviews})', 'All'),
                SizedBox(width: 2.w),
                _buildFilterChip('5 ★ (${widget.breakdown['5'] ?? 0})', '5'),
                SizedBox(width: 2.w),
                _buildFilterChip('4 ★ (${widget.breakdown['4'] ?? 0})', '4'),
                SizedBox(width: 2.w),
                _buildFilterChip('With Comments', 'Comments'),
              ],
            ),
          ),

          SizedBox(height: 2.h),
          const Divider(height: 1),
          SizedBox(height: 1.5.h),

          // Customer reviews list
          ...widget.reviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildStarBar(int star, int count, int total) {
    final double pct = total > 0 ? (count / total) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(
            '$star★',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 7,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  star >= 4
                      ? Colors.amber.shade700
                      : (star >= 3 ? Colors.orange.shade600 : Colors.grey.shade400),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    final primary = AppTheme.lightTheme.colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final theme = AppTheme.lightTheme;
    final int rating = (review['rating'] as num?)?.toInt() ?? 5;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      (review['name'] as String? ?? 'U').substring(0, 1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['name'] as String? ?? 'Verified Buyer',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (review['location'] != null)
                        Text(
                          review['location'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Text(
                review['date'] as String? ?? 'Recently',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber.shade700,
                    size: 15,
                  );
                }),
              ),
              SizedBox(width: 2.w),
              if (review['verified'] == true) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 10, color: Colors.green.shade800),
                      const SizedBox(width: 3),
                      Text(
                        'Verified Purchase',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (review['title'] != null) ...[
            SizedBox(height: 0.8.h),
            Text(
              review['title'] as String,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          SizedBox(height: 0.5.h),
          Text(
            review['comment'] as String? ?? '',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
