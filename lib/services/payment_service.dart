import 'package:dio/dio.dart';

import './supabase_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final Dio _dio = Dio();

  // Create payment intent for listing purchase
  Future<Map<String, dynamic>> createPaymentIntent({
    required String listingId,
    required double amount,
    String currency = 'usd',
  }) async {
    final client = await SupabaseService().client;
    final userId = SupabaseService().currentUserId;

    if (userId == null) throw Exception('User not authenticated');

    // Get listing details
    final listing = await client
        .from('listings')
        .select('*, seller:user_profiles!seller_id(*)')
        .eq('id', listingId)
        .single();

    if (listing['seller']['id'] == userId) {
      throw Exception('Cannot purchase your own listing');
    }

    // Create transaction record
    final transaction = await client
        .from('transactions')
        .insert({
          'listing_id': listingId,
          'buyer_id': userId,
          'seller_id': listing['seller_id'],
          'amount': amount,
          'processing_fee': amount * 0.03, // 3% processing fee
        })
        .select()
        .single();

    // Call Stripe Edge Function
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    final apiUrl = '$supabaseUrl/functions/v1/create-payment-intent';

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $anonKey',
    };

    try {
      final response = await _dio.post(apiUrl, data: {
        'amount': (amount * 100).round(), // Convert to cents
        'currency': currency,
        'transaction_id': transaction['id'],
        'listing_title': listing['title'],
        'metadata': {
          'listing_id': listingId,
          'buyer_id': userId,
          'seller_id': listing['seller_id'],
        }
      });

      // Update transaction with Stripe payment intent ID
      await client.from('transactions').update({
        'stripe_payment_intent_id': response.data['payment_intent_id'],
      }).eq('id', transaction['id']);

      return {
        'client_secret': response.data['client_secret'],
        'payment_intent_id': response.data['payment_intent_id'],
        'transaction_id': transaction['id'],
      };
    } catch (e) {
      // Clean up failed transaction
      await client
          .from('transactions')
          .update({'payment_status': 'failed'}).eq('id', transaction['id']);

      throw Exception('Failed to create payment intent: $e');
    }
  }

  // Confirm payment completion
  Future<void> confirmPayment(String transactionId) async {
    final client = await SupabaseService().client;

    await client.from('transactions').update({
      'payment_status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', transactionId);

    // Mark listing as sold
    final transaction = await client
        .from('transactions')
        .select('listing_id, seller_id')
        .eq('id', transactionId)
        .single();

    await client
        .from('listings')
        .update({'status': 'sold'}).eq('id', transaction['listing_id']);

    // Update seller stats
    await client.rpc('increment', params: {
      'table_name': 'user_profiles',
      'column_name': 'total_sales',
      'row_id': transaction['seller_id'],
      'x': 1,
    });
  }

  // Get user transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory(
      String userId) async {
    final client = await SupabaseService().client;

    return await client
        .from('transactions')
        .select('''
          *,
          listing:listings(title, images),
          buyer:user_profiles!buyer_id(full_name),
          seller:user_profiles!seller_id(full_name)
        ''')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('created_at', ascending: false);
  }
}
