import './supabase_service.dart';

class SubscriptionService {
  final SupabaseService _supabaseService = SupabaseService();

  // Add missing getUserActiveSubscription method
  Future<Map<String, dynamic>?> getUserActiveSubscription(String userId) async {
    try {
      final response = await _supabaseService.selectRows(
        'user_subscriptions',
        select: '''
          *,
          tier_id:subscription_tiers(
            id, name, description, price, billing_cycle, features, 
            max_listings, priority_support, featured_listings, analytics_access,
            currency_id:currencies(id, code, symbol, name)
          )
        ''',
        filters: {'user_id': userId, 'status': 'active'},
        orderBy: 'created_at',
        limit: 1,
      );
      return response.isNotEmpty
          ? Map<String, dynamic>.from(response.first)
          : null;
    } catch (error) {
      throw Exception('Failed to fetch user active subscription: $error');
    }
  }

  // Add missing getSubscriptionComparison method
  Future<List<Map<String, dynamic>>> getSubscriptionComparison() async {
    try {
      final response = await _supabaseService.selectRows(
        'subscription_tiers',
        select: '''
          *,
          currency_id:currencies(id, code, symbol, name)
        ''',
        filters: {'is_active': true},
        orderBy: 'price',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch subscription comparison: $error');
    }
  }

  // Add missing getUserSubscriptionStats method
  Future<Map<String, dynamic>> getUserSubscriptionStats(String userId) async {
    try {
      final subscription = await getUserActiveSubscription(userId);
      if (subscription == null) {
        return {
          'has_active_subscription': false,
          'subscription_tier': 'free',
          'days_remaining': 0,
          'max_listings': 5,
          'current_listings': 0,
          'features': ['Basic messaging', 'Standard support'],
        };
      }

      final tierData = subscription['tier_id'] as Map<String, dynamic>;
      final currentPeriodEnd =
          DateTime.parse(subscription['current_period_end'] as String);
      final daysRemaining = currentPeriodEnd.difference(DateTime.now()).inDays;

      // Get current listings count
      final client = await _supabaseService.client;
      final currentListings = await client
          .from('listings')
          .select()
          .eq('seller_id', userId)
          .eq('status', 'active');

      return {
        'has_active_subscription': true,
        'subscription_tier': tierData['name'],
        'days_remaining': daysRemaining > 0 ? daysRemaining : 0,
        'max_listings': tierData['max_listings'] ?? -1,
        'current_listings': currentListings.length,
        'features': List<String>.from(tierData['features'] ?? []),
        'billing_cycle': tierData['billing_cycle'],
        'next_billing_date': subscription['current_period_end'],
      };
    } catch (error) {
      throw Exception('Failed to fetch user subscription stats: $error');
    }
  }

  // Fetch all active subscription tiers
  Future<List<Map<String, dynamic>>> getSubscriptionTiers() async {
    try {
      final response = await _supabaseService.selectRows(
        'subscription_tiers',
        select: '''
          *,
          currency_id:currencies(id, code, symbol, name)
        ''',
        filters: {'is_active': true},
        orderBy: 'price',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch subscription tiers: $error');
    }
  }

  // Get user's current subscription
  Future<Map<String, dynamic>?> getUserSubscription(String userId) async {
    try {
      final response = await _supabaseService.selectRows(
        'user_subscriptions',
        select: '''
          *,
          tier_id:subscription_tiers(
            id, name, description, price, billing_cycle, features, 
            max_listings, priority_support, featured_listings, analytics_access,
            currency_id:currencies(id, code, symbol, name)
          )
        ''',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        limit: 1,
      );
      return response.isNotEmpty
          ? Map<String, dynamic>.from(response.first)
          : null;
    } catch (error) {
      throw Exception('Failed to fetch user subscription: $error');
    }
  }

  // Create new subscription - update signature to match usage
  Future<Map<String, dynamic>> createSubscription({
    required String userId,
    required String planId, // Changed from tierId to planId
    required String stripeSubscriptionId,
    required String stripeCustomerId,
    required DateTime currentPeriodEnd,
  }) async {
    try {
      final subscriptionData = {
        'user_id': userId,
        'tier_id': planId, // Map planId to tier_id in database
        'status': 'active',
        'current_period_start': DateTime.now().toIso8601String(),
        'current_period_end': currentPeriodEnd.toIso8601String(),
        'stripe_subscription_id': stripeSubscriptionId,
        'stripe_customer_id': stripeCustomerId,
      };

      final response = await _supabaseService.insertRow(
          'user_subscriptions', subscriptionData);
      return Map<String, dynamic>.from(response.first);
    } catch (error) {
      throw Exception('Failed to create subscription: $error');
    }
  }

  // Update subscription status
  Future<Map<String, dynamic>> updateSubscriptionStatus(
    String subscriptionId,
    String status, {
    DateTime? currentPeriodEnd,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (currentPeriodEnd != null) {
        updates['current_period_end'] = currentPeriodEnd.toIso8601String();
      }

      final response = await _supabaseService.updateRow(
        'user_subscriptions',
        updates,
        'id',
        subscriptionId,
      );
      return Map<String, dynamic>.from(response.first);
    } catch (error) {
      throw Exception('Failed to update subscription status: $error');
    }
  }

  // Cancel subscription
  Future<Map<String, dynamic>> cancelSubscription(String subscriptionId) async {
    try {
      return await updateSubscriptionStatus(subscriptionId, 'cancelled');
    } catch (error) {
      throw Exception('Failed to cancel subscription: $error');
    }
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) return false;

      final status = subscription['status'] as String;
      final endDate =
          DateTime.parse(subscription['current_period_end'] as String);

      return status == 'active' && endDate.isAfter(DateTime.now());
    } catch (error) {
      return false;
    }
  }

  // Get subscription features for user
  Future<List<String>> getUserSubscriptionFeatures(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) {
        // Return basic/free tier features
        return [
          'Up to 5 active listings',
          'Basic messaging',
          'Standard support'
        ];
      }

      final tierData = subscription['tier_id'] as Map<String, dynamic>;
      final features = tierData['features'] as List<dynamic>;
      return features.map((feature) => feature.toString()).toList();
    } catch (error) {
      throw Exception('Failed to get user subscription features: $error');
    }
  }

  // Check if user can create more listings
  Future<bool> canCreateListing(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);

      int maxListings = 5; // Default for free tier
      if (subscription != null) {
        final tierData = subscription['tier_id'] as Map<String, dynamic>;
        maxListings = tierData['max_listings'] as int;
        if (maxListings == -1) return true; // Unlimited
      }

      // Count current active listings
      final activeListings = await _supabaseService.selectRows(
        'listings',
        filters: {'seller_id': userId, 'status': 'active'},
      );

      return activeListings.length < maxListings;
    } catch (error) {
      return false;
    }
  }

  // Get subscription tier by ID
  Future<Map<String, dynamic>?> getSubscriptionTier(String tierId) async {
    try {
      final response = await _supabaseService.selectRows(
        'subscription_tiers',
        select: '''
          *,
          currency_id:currencies(id, code, symbol, name)
        ''',
        filters: {'id': tierId},
      );
      return response.isNotEmpty
          ? Map<String, dynamic>.from(response.first)
          : null;
    } catch (error) {
      throw Exception('Failed to fetch subscription tier: $error');
    }
  }

  // Get popular subscription tier
  Future<Map<String, dynamic>?> getPopularTier() async {
    try {
      final response = await _supabaseService.selectRows(
        'subscription_tiers',
        select: '''
          *,
          currency_id:currencies(id, code, symbol, name)
        ''',
        filters: {'is_popular': true, 'is_active': true},
        limit: 1,
      );
      return response.isNotEmpty
          ? Map<String, dynamic>.from(response.first)
          : null;
    } catch (error) {
      throw Exception('Failed to fetch popular tier: $error');
    }
  }
}
