import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class AdvancedOptionsWidget extends StatefulWidget {
  final int listingDuration;
  final bool allowCalls;
  final bool allowDelivery;
  final bool allowPickup;
  final Function(int) onDurationChanged;
  final Function(bool) onCallsChanged;
  final Function(bool) onDeliveryChanged;
  final Function(bool) onPickupChanged;

  const AdvancedOptionsWidget({
    super.key,
    required this.listingDuration,
    required this.allowCalls,
    required this.allowDelivery,
    required this.allowPickup,
    required this.onDurationChanged,
    required this.onCallsChanged,
    required this.onDeliveryChanged,
    required this.onPickupChanged,
  });

  @override
  State<AdvancedOptionsWidget> createState() => _AdvancedOptionsWidgetState();
}

class _AdvancedOptionsWidgetState extends State<AdvancedOptionsWidget> {
  bool _showPromotionOptions = false;
  String _selectedPromotionPlan = '';

  final List<Map<String, dynamic>> _promotionPlans = [
    {
      "id": "vip",
      "name": "VIP Listing",
      "price": "₦500",
      "duration": "7 days",
      "features": [
        "Highlighted in search results",
        "Priority placement",
        "VIP badge",
        "3x more views"
      ],
      "color": Color(0xFFFFD700),
    },
    {
      "id": "top_ad",
      "name": "Top Ad",
      "price": "₦300",
      "duration": "3 days",
      "features": [
        "Appears at top of category",
        "Featured badge",
        "2x more visibility",
        "Priority in search"
      ],
      "color": Color(0xFFFF6B35),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Options',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 24),

          // Listing Duration
          _buildSectionCard(
            title: 'Listing Duration',
            icon: 'schedule',
            child: Column(
              children: [
                Text(
                  'How long should your listing be active?',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDurationOption(7, '7 Days'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildDurationOption(15, '15 Days'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildDurationOption(30, '30 Days'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Contact Preferences
          _buildSectionCard(
            title: 'Contact Preferences',
            icon: 'contact_phone',
            child: Column(
              children: [
                _buildSwitchOption(
                  title: 'Allow Phone Calls',
                  subtitle: 'Buyers can call you directly',
                  value: widget.allowCalls,
                  onChanged: widget.onCallsChanged,
                  icon: 'phone',
                ),
                Divider(height: 24),
                Text(
                  'Messages are always enabled for all listings',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Delivery Options
          _buildSectionCard(
            title: 'Delivery Options',
            icon: 'local_shipping',
            child: Column(
              children: [
                _buildSwitchOption(
                  title: 'Pickup Available',
                  subtitle: 'Buyers can collect from your location',
                  value: widget.allowPickup,
                  onChanged: widget.onPickupChanged,
                  icon: 'location_on',
                ),
                Divider(height: 24),
                _buildSwitchOption(
                  title: 'Delivery Available',
                  subtitle: 'You can deliver to buyers',
                  value: widget.allowDelivery,
                  onChanged: widget.onDeliveryChanged,
                  icon: 'delivery_dining',
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Promotion Options
          _buildSectionCard(
            title: 'Boost Your Listing',
            icon: 'trending_up',
            child: Column(
              children: [
                Text(
                  'Get more views and sell faster with promotion',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showPromotionOptions = !_showPromotionOptions;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName:
                          _showPromotionOptions ? 'expand_less' : 'expand_more',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    label: Text(_showPromotionOptions
                        ? 'Hide Options'
                        : 'View Promotion Plans'),
                  ),
                ),
                if (_showPromotionOptions) ...[
                  SizedBox(height: 16),
                  ..._promotionPlans.map((plan) => _buildPromotionPlan(plan)),
                ],
              ],
            ),
          ),

          SizedBox(height: 24),

          // Preview Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showPreview,
              icon: CustomIconWidget(
                iconName: 'preview',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              label: Text('Preview Listing'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDurationOption(int days, String label) {
    final isSelected = widget.listingDuration == days;
    return GestureDetector(
      onTap: () => widget.onDurationChanged(days),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primaryContainer
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required String icon,
  }) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: value
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPromotionPlan(Map<String, dynamic> plan) {
    final isSelected = _selectedPromotionPlan == plan['id'];
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPromotionPlan = isSelected ? '' : plan['id'] as String;
          });
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (plan['color'] as Color).withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? plan['color'] as Color
                  : AppTheme.lightTheme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (plan['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'star',
                      color: plan['color'] as Color,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['name'] as String,
                          style: AppTheme.lightTheme.textTheme.titleSmall,
                        ),
                        Text(
                          '${plan['price']} for ${plan['duration']}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: plan['color'] as Color,
                      size: 20,
                    ),
                ],
              ),
              SizedBox(height: 12),
              ...(plan['features'] as List<String>).map(
                (feature) => Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'check',
                        color: plan['color'] as Color,
                        size: 14,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Listing Preview',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This is how your listing will appear to buyers',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'preview',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Listing Preview',
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close Preview'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
