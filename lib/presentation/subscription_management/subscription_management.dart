import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/subscription_service.dart';
import '../../services/supabase_service.dart';
import './widgets/current_subscription_widget.dart';
import './widgets/subscription_features_widget.dart';
import './widgets/subscription_plan_card.dart';
import './widgets/upgrade_benefits_widget.dart';

class SubscriptionManagement extends StatefulWidget {
  const SubscriptionManagement({super.key});

  @override
  State<SubscriptionManagement> createState() => _SubscriptionManagementState();
}

class _SubscriptionManagementState extends State<SubscriptionManagement> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  String? _currentUserId;
  bool _isLoading = true;

  Map<String, dynamic>? _currentSubscription;
  List<Map<String, dynamic>> _subscriptionPlans = [];
  Map<String, dynamic>? _subscriptionStats;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    try {
      setState(() => _isLoading = true);

      // Fix: Use getter instead of method call
      _currentUserId = SupabaseService().currentUserId;

      if (_currentUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fix: Use correct method names and handle Future.wait properly
      final results = await Future.wait([
        _subscriptionService.getUserActiveSubscription(_currentUserId!),
        _subscriptionService.getSubscriptionComparison(),
        _subscriptionService.getUserSubscriptionStats(_currentUserId!),
      ]);

      setState(() {
        _currentSubscription = results[0] as Map<String, dynamic>?;
        _subscriptionPlans = results[1] as List<Map<String, dynamic>>;
        _subscriptionStats = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load subscription data: $error'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  Future<void> _upgradeSubscription(Map<String, dynamic> plan) async {
    try {
      await _subscriptionService.createSubscription(
          userId: _currentUserId!,
          planId: plan['id'], // Fix: Use planId parameter name
          stripeSubscriptionId:
              'stripe_sub_${DateTime.now().millisecondsSinceEpoch}',
          stripeCustomerId:
              'stripe_cust_${DateTime.now().millisecondsSinceEpoch}',
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)));

      await _loadSubscriptionData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Successfully upgraded to ${plan['name']}!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to upgrade subscription: $error'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  Future<void> _cancelSubscription() async {
    if (_currentSubscription == null) return;

    try {
      await _subscriptionService
          .cancelSubscription(_currentSubscription!['id']);
      await _loadSubscriptionData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Subscription cancelled successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to cancel subscription: $error'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
            title: Text("Subscription Management",
                style: AppTheme.lightTheme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24))),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _currentUserId == null
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Text('Please log in to manage your subscription',
                            style: AppTheme.lightTheme.textTheme.titleMedium),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/login-screen'),
                            child: const Text('Login')),
                      ]))
                : RefreshIndicator(
                    onRefresh: _loadSubscriptionData,
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(children: [
                          SizedBox(height: 2.h),

                          // Current Subscription Widget
                          if (_currentSubscription != null)
                            CurrentSubscriptionWidget(
                              subscriptionStats: _subscriptionStats!,
                              onManage: _cancelSubscription,
                            ),

                          SizedBox(height: 3.h),

                          // Subscription Plans
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text("Available Plans",
                                  style: AppTheme
                                      .lightTheme.textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w600))),

                          SizedBox(height: 2.h),

                          // Plan Cards
                          ..._subscriptionPlans.map((plan) => Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 1.h),
                              child: SubscriptionPlanCard(
                                  plan: plan,
                                  isCurrentPlan:
                                      _currentSubscription?['tier_id']?['id'] ==
                                          plan['id'],
                                  onUpgrade: () =>
                                      _upgradeSubscription(plan)))),

                          SizedBox(height: 3.h),

                          // Subscription Features
                          if (_subscriptionStats != null)
                            SubscriptionFeaturesWidget(
                              plans: _subscriptionPlans,
                            ),

                          SizedBox(height: 3.h),

                          // Upgrade Benefits
                          UpgradeBenefitsWidget(
                            currentTier: _currentSubscription?['tier_id']
                                    ?['name'] ??
                                'Free',
                          ),

                          SizedBox(height: 4.h),
                        ]))));
  }
}
