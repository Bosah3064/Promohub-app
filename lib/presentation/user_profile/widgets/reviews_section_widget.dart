import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReviewsSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;
  final Map<String, dynamic> ratingBreakdown;

  const ReviewsSectionWidget({
    super.key,
    required this.reviews,
    required this.ratingBreakdown,
  });

  @override
  State<ReviewsSectionWidget> createState() => _ReviewsSectionWidgetState();
}

class _ReviewsSectionWidgetState extends State<ReviewsSectionWidget> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews & Ratings',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllReviews = !_showAllReviews;
                  });
                },
                child: Text(_showAllReviews ? 'Show Less' : 'View All'),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildRatingBreakdown(),
          SizedBox(height: 3.h),
          widget.reviews.isEmpty ? _buildEmptyReviews() : _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${widget.ratingBreakdown["averageRating"]}',
                style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return CustomIconWidget(
                          iconName: index <
                                  (widget.ratingBreakdown["averageRating"]
                                          as double)
                                      .floor()
                              ? 'star'
                              : 'star_border',
                          color: AppTheme.lightTheme.colorScheme.tertiary,
                          size: 20,
                        );
                      }),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Based on ${widget.ratingBreakdown["totalReviews"]} reviews',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...List.generate(5, (index) {
            final starCount = 5 - index;
            final percentage = (widget.ratingBreakdown["breakdown"]
                as Map<String, dynamic>)[starCount.toString()] as double;
            return _buildRatingBar(starCount, percentage);
          }),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Text(
            '$stars',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
          SizedBox(width: 1.w),
          CustomIconWidget(
            iconName: 'star',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            size: 12,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppTheme.lightTheme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.tertiary,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            '${percentage.toInt()}%',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'rate_review',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Reviews Yet',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Complete your first transaction to receive reviews',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    final reviewsToShow =
        _showAllReviews ? widget.reviews : widget.reviews.take(3).toList();

    return Column(
      children:
          reviewsToShow.map((review) => _buildReviewCard(review)).toList(),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 5.w,
                child: CustomImageWidget(
                  imageUrl: review["reviewerAvatar"] as String,
                  width: 10.w,
                  height: 10.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review["reviewerName"] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return CustomIconWidget(
                              iconName: index < (review["rating"] as int)
                                  ? 'star'
                                  : 'star_border',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 14,
                            );
                          }),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          review["date"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            review["comment"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            maxLines: _showAllReviews ? null : 3,
            overflow: _showAllReviews ? null : TextOverflow.ellipsis,
          ),
          if (review["transaction"] != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CustomImageWidget(
                      imageUrl: (review["transaction"]
                          as Map<String, dynamic>)["itemImage"] as String,
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (review["transaction"]
                              as Map<String, dynamic>)["itemName"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          (review["transaction"]
                              as Map<String, dynamic>)["price"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
