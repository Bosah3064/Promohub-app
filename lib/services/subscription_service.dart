import 'package:cloud_firestore/cloud_firestore.dart';
import './firebase_service.dart';

class SubscriptionService {
  final FirebaseService _firebaseService = FirebaseService();
  FirebaseFirestore get _firestore => _firebaseService.firestore;

  Future<Map<String, dynamic>?> getUserActiveSubscription(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_subscriptions')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      var subData = {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};

      // Fetch tier info
      final tierDoc = await _firestore.collection('subscription_tiers').doc(subData['tier_id']).get();
      if (tierDoc.exists) {
        var tierData = {'id': tierDoc.id, ...?tierDoc.data()};
        
        // Fetch currency info
        if (tierData['currency_id'] != null) {
          final currencyDoc = await _firestore.collection('currencies').doc(tierData['currency_id']).get();
          if (currencyDoc.exists) {
            tierData['currency_id'] = {'id': currencyDoc.id, ...?currencyDoc.data()};
          }
        }
        subData['tier_id'] = tierData;
      }

      return subData;
    } catch (error) {
      throw Exception('Failed to fetch user active subscription: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getSubscriptionComparison() async {
    return getSubscriptionTiers();
  }

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
      final currentPeriodEnd = (subscription['current_period_end'] is String)
          ? DateTime.parse(subscription['current_period_end'])
          : (subscription['current_period_end'] as Timestamp).toDate();
      final daysRemaining = currentPeriodEnd.difference(DateTime.now()).inDays;

      // Get current listings count
      final snapshot = await _firestore
          .collection('listings')
          .where('seller_id', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .count()
          .get();

      return {
        'has_active_subscription': true,
        'subscription_tier': tierData['name'],
        'days_remaining': daysRemaining > 0 ? daysRemaining : 0,
        'max_listings': tierData['max_listings'] ?? -1,
        'current_listings': snapshot.count ?? 0,
        'features': List<String>.from(tierData['features'] ?? []),
        'billing_cycle': tierData['billing_cycle'],
        'next_billing_date': subscription['current_period_end'],
      };
    } catch (error) {
      throw Exception('Failed to fetch user subscription stats: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getSubscriptionTiers() async {
    try {
      final snapshot = await _firestore
          .collection('subscription_tiers')
          .where('is_active', isEqualTo: true)
          .orderBy('price')
          .get();

      List<Map<String, dynamic>> tiers = [];
      for (var doc in snapshot.docs) {
        var tier = {'id': doc.id, ...doc.data()};
        if (tier['currency_id'] != null) {
          final currencyDoc = await _firestore.collection('currencies').doc(tier['currency_id']).get();
          if (currencyDoc.exists) {
            tier['currency_id'] = {'id': currencyDoc.id, ...?currencyDoc.data()};
          }
        }
        tiers.add(tier);
      }
      return tiers;
    } catch (error) {
      throw Exception('Failed to fetch subscription tiers: $error');
    }
  }

  Future<Map<String, dynamic>?> getUserSubscription(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_subscriptions')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      var subData = {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};

      // Fetch tier info
      final tierDoc = await _firestore.collection('subscription_tiers').doc(subData['tier_id']).get();
      if (tierDoc.exists) {
        var tierData = {'id': tierDoc.id, ...?tierDoc.data()};
        if (tierData['currency_id'] != null) {
          final currencyDoc = await _firestore.collection('currencies').doc(tierData['currency_id']).get();
          if (currencyDoc.exists) {
            tierData['currency_id'] = {'id': currencyDoc.id, ...?currencyDoc.data()};
          }
        }
        subData['tier_id'] = tierData;
      }

      return subData;
    } catch (error) {
      throw Exception('Failed to fetch user subscription: $error');
    }
  }

  Future<Map<String, dynamic>> createSubscription({
    required String userId,
    required String planId,
    required String stripeSubscriptionId,
    required String stripeCustomerId,
    required DateTime currentPeriodEnd,
  }) async {
    try {
      final subscriptionData = {
        'user_id': userId,
        'tier_id': planId,
        'status': 'active',
        'current_period_start': FieldValue.serverTimestamp(),
        'current_period_end': currentPeriodEnd.toIso8601String(),
        'stripe_subscription_id': stripeSubscriptionId,
        'stripe_customer_id': stripeCustomerId,
        'created_at': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('user_subscriptions').add(subscriptionData);
      return {'id': docRef.id, ...subscriptionData};
    } catch (error) {
      throw Exception('Failed to create subscription: $error');
    }
  }

  Future<Map<String, dynamic>> updateSubscriptionStatus(
    String subscriptionId,
    String status, {
    DateTime? currentPeriodEnd,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (currentPeriodEnd != null) {
        updates['current_period_end'] = currentPeriodEnd.toIso8601String();
      }

      await _firestore.collection('user_subscriptions').doc(subscriptionId).update(updates);
      final doc = await _firestore.collection('user_subscriptions').doc(subscriptionId).get();
      return {'id': doc.id, ...?doc.data()};
    } catch (error) {
      throw Exception('Failed to update subscription status: $error');
    }
  }

  Future<Map<String, dynamic>> cancelSubscription(String subscriptionId) async {
    return await updateSubscriptionStatus(subscriptionId, 'cancelled');
  }

  Future<bool> hasActiveSubscription(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) return false;

      final status = subscription['status'] as String;
      final endDate = (subscription['current_period_end'] is String)
          ? DateTime.parse(subscription['current_period_end'])
          : (subscription['current_period_end'] as Timestamp).toDate();

      return status == 'active' && endDate.isAfter(DateTime.now());
    } catch (error) {
      return false;
    }
  }

  Future<List<String>> getUserSubscriptionFeatures(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) {
        return [
          'Up to 5 active listings',
          'Basic messaging',
          'Standard support'
        ];
      }

      final tierData = subscription['tier_id'] as Map<String, dynamic>;
      final features = tierData['features'] as List<dynamic>? ?? [];
      return features.map((feature) => feature.toString()).toList();
    } catch (error) {
      throw Exception('Failed to get user subscription features: $error');
    }
  }

  Future<bool> canCreateListing(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);

      int maxListings = 5;
      if (subscription != null) {
        final tierData = subscription['tier_id'] as Map<String, dynamic>;
        maxListings = tierData['max_listings'] as int? ?? 5;
        if (maxListings == -1) return true; // Unlimited
      }

      final snapshot = await _firestore
          .collection('listings')
          .where('seller_id', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .count()
          .get();

      return (snapshot.count ?? 0) < maxListings;
    } catch (error) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSubscriptionTier(String tierId) async {
    try {
      final doc = await _firestore.collection('subscription_tiers').doc(tierId).get();
      if (!doc.exists) return null;

      var tierData = {'id': doc.id, ...?doc.data()};
      if (tierData['currency_id'] != null) {
        final currencyDoc = await _firestore.collection('currencies').doc(tierData['currency_id']).get();
        if (currencyDoc.exists) {
          tierData['currency_id'] = {'id': currencyDoc.id, ...?currencyDoc.data()};
        }
      }
      return tierData;
    } catch (error) {
      throw Exception('Failed to fetch subscription tier: $error');
    }
  }

  Future<Map<String, dynamic>?> getPopularTier() async {
    try {
      final snapshot = await _firestore
          .collection('subscription_tiers')
          .where('is_active', isEqualTo: true)
          .where('is_popular', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      var tierData = {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};
      if (tierData['currency_id'] != null) {
        final currencyDoc = await _firestore.collection('currencies').doc(tierData['currency_id']).get();
        if (currencyDoc.exists) {
          tierData['currency_id'] = {'id': currencyDoc.id, ...?currencyDoc.data()};
        }
      }
      return tierData;
    } catch (error) {
      throw Exception('Failed to fetch popular tier: $error');
    }
  }
}
