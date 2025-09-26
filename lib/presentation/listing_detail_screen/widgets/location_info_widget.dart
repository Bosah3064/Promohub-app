import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class LocationInfoWidget extends StatelessWidget {
  final Map<String, dynamic> location;

  const LocationInfoWidget({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${location["area"]}, ${location["city"]}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      location["state"] as String? ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'near_me',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            location["distance"] as String? ??
                                'Distance unknown',
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),

              // Map thumbnail
              GestureDetector(
                onTap: () {
                  _openMaps(context);
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        // Mock map image - in real app, this would be a map widget
                        CustomImageWidget(
                          imageUrl:
                              "https://images.pexels.com/photos/2422915/pexels-photo-2422915.jpeg",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                        ),
                        Center(
                          child: CustomIconWidget(
                            iconName: 'location_on',
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openMaps(context),
                  icon: CustomIconWidget(
                    iconName: 'directions',
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('Get Directions'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewOnMap(context),
                  icon: CustomIconWidget(
                    iconName: 'map',
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('View on Map'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openMaps(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions in maps app...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewOnMap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening location on map...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
