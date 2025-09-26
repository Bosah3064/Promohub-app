import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class PromotionOptionsWidget extends StatefulWidget {
  final String selectedPlan;
  final Function(String) onPlanChanged;

  const PromotionOptionsWidget({
    super.key,
    required this.selectedPlan,
    required this.onPlanChanged,
  });

  @override
  State<PromotionOptionsWidget> createState() => _PromotionOptionsWidgetState();
}

class _PromotionOptionsWidgetState extends State<PromotionOptionsWidget> {
  final List<Map<String, dynamic>> _promotionPlans = [
    {
      "id": "free",
      "name": "Free Listing",
      "price": "₦0",
      "duration": "30 days",
      "features": [
        "Basic listing visibility",
        "Standard search placement",
        "Message contact only",
        "30-day listing duration"
      ],
      "color": AppTheme.lightTheme.colorScheme.outline,
      "recommended": false,
    },
    {
      "id": "vip",
      "name": "VIP Listing",
      "price": "₦500",
      "duration": "7 days",
      "features": [
        "Highlighted in search results",
        "Priority placement",
        "VIP badge display",
        "3x more views",
        "Featured in category top",
        "Push notification to followers"
      ],
      "color": Color(0xFFFFD700),
      "recommended": true,
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
        "Priority in search results",
        "Enhanced listing card"
      ],
      "color": Color(0xFFFF6B35),
      "recommended": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Boost Your Listing',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Get more views and sell faster with our promotion plans',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24),

          // Promotion plans
          ..._promotionPlans.map((plan) => _buildPromotionPlan(plan)),

          SizedBox(height: 24),

          // Benefits section
          if (widget.selectedPlan != 'free') ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'trending_up',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Why Promote?',
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildBenefit('Sell 3x faster than regular listings'),
                  _buildBenefit('Reach more potential buyers'),
                  _buildBenefit('Stand out from competition'),
                  _buildBenefit('Get priority customer support'),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Payment info
          if (widget.selectedPlan != 'free' &&
              widget.selectedPlan.isNotEmpty) ...[
            Container(
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
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'payment',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Payment Information',
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Promotion Plan:',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        _getSelectedPlanName(),
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration:',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        _getSelectedPlanDuration(),
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                      Text(
                        _getSelectedPlanPrice(),
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromotionPlan(Map<String, dynamic> plan) {
    final isSelected = widget.selectedPlan == plan['id'];
    final isRecommended = plan['recommended'] as bool;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => widget.onPlanChanged(plan['id'] as String),
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
              // Header with badge
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (plan['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName:
                          plan['id'] == 'free' ? 'free_breakfast' : 'star',
                      color: plan['color'] as Color,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan['name'] as String,
                              style: AppTheme.lightTheme.textTheme.titleSmall,
                            ),
                            if (isRecommended) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'RECOMMENDED',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                  Radio<String>(
                    value: plan['id'] as String,
                    groupValue: widget.selectedPlan,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onPlanChanged(value);
                      }
                    },
                    activeColor: plan['color'] as Color,
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Features list
              ...(plan['features'] as List<String>).map(
                (feature) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: plan['color'] as Color,
                        size: 16,
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

  Widget _buildBenefit(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSelectedPlanName() {
    final plan = _promotionPlans.firstWhere(
      (p) => p['id'] == widget.selectedPlan,
      orElse: () => _promotionPlans.first,
    );
    return plan['name'] as String;
  }

  String _getSelectedPlanDuration() {
    final plan = _promotionPlans.firstWhere(
      (p) => p['id'] == widget.selectedPlan,
      orElse: () => _promotionPlans.first,
    );
    return plan['duration'] as String;
  }

  String _getSelectedPlanPrice() {
    final plan = _promotionPlans.firstWhere(
      (p) => p['id'] == widget.selectedPlan,
      orElse: () => _promotionPlans.first,
    );
    return plan['price'] as String;
  }
}
