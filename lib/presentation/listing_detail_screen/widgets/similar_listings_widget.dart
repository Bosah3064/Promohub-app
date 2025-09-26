import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class SimilarListingsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> listings;

  const SimilarListingsWidget({
    super.key,
    required this.listings,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Similar listings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening similar listings...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return SimilarListingCard(
                listing: listings[index],
                onTap: () => _navigateToListing(context, listings[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToListing(BuildContext context, Map<String, dynamic> listing) {
    // In a real app, this would navigate to the listing detail with the new listing data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${listing["title"]}...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class SimilarListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onTap;

  const SimilarListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 12),
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
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CustomImageWidget(
                imageUrl: listing["image"] as String,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      listing["title"] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),

                    // Price
                    Text(
                      listing["price"] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    Spacer(),

                    // Condition and Distance
                    Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing["condition"] as String,
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              size: 12,
                            ),
                            SizedBox(width: 2),
                            Text(
                              listing["distance"] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
