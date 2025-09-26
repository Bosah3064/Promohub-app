import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ProductInfoWidget extends StatefulWidget {
  final Map<String, dynamic> listing;

  const ProductInfoWidget({
    super.key,
    required this.listing,
  });

  @override
  State<ProductInfoWidget> createState() => _ProductInfoWidgetState();
}

class _ProductInfoWidgetState extends State<ProductInfoWidget> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    String description = widget.listing["description"] as String? ?? '';
    bool isLongDescription = description.length > 200;
    String displayDescription = _isDescriptionExpanded || !isLongDescription
        ? description
        : '${description.substring(0, 200)}...';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.listing["title"] as String? ?? 'No title',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 12),

          // Price section
          Row(
            children: [
              Text(
                widget.listing["price"] as String? ?? '₦0',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (widget.listing["originalPrice"] != null) ...[
                SizedBox(width: 12),
                Text(
                  widget.listing["originalPrice"] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
              Spacer(),
              if (widget.listing["isPromoted"] == true)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: Colors.orange,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Promoted',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),

          // Condition and Category
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.listing["condition"] as String? ?? 'Unknown',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.listing["category"] as String? ?? 'Uncategorized',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Tags
          if (widget.listing["tags"] != null) ...[
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (widget.listing["tags"] as List).map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag.toString().replaceAll('-', ' '),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          SizedBox(height: 16),

          // Description
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 8),
          Text(
            displayDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
          if (isLongDescription) ...[
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(
                _isDescriptionExpanded ? 'Read Less' : 'Read More',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          SizedBox(height: 16),

          // Stats
          Row(
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'visibility',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${widget.listing["views"]} views',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(width: 16),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'favorite_border',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${widget.listing["likes"]} likes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Spacer(),
              Text(
                'Posted ${_getTimeAgo(widget.listing["postedDate"] as String? ?? '')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(String dateString) {
    if (dateString.isEmpty) return 'recently';

    try {
      DateTime postedDate = DateTime.parse(dateString);
      Duration difference = DateTime.now().difference(postedDate);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'just now';
      }
    } catch (e) {
      return 'recently';
    }
  }
}
