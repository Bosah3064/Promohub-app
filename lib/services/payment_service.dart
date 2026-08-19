import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import './firebase_service.dart';

/// Unified Payment Service supporting M-Pesa STK Push and Stripe.
/// M-Pesa is the primary payment method for this marketplace.
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ============================================================
  // M-PESA STK PUSH (DARAJA API)
  // ============================================================

  /// Initiate an M-Pesa STK Push to the buyer's phone.
  /// This sends a payment prompt directly to the user's phone.
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required String phoneNumber,
    required double amount,
    required String orderId,
    String? accountReference,
  }) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Normalize phone number to 254XXXXXXXXX format
    final normalizedPhone = _normalizeKenyanPhone(phoneNumber);

    try {
      // 1. Create a transaction record in escrow status
      final transactionRef = await _firestore.collection('transactions').add({
        'order_id': orderId,
        'buyer_id': userId,
        'amount': amount,
        'payment_method': 'mpesa',
        'payment_status': 'pending',
        'processing_fee': amount * 0.015, // 1.5% M-Pesa fee
        'created_at': FieldValue.serverTimestamp(),
      });

      // 2. Call Firebase Cloud Function for M-Pesa STK Push
      final callable = _functions.httpsCallable('mpesaStkPush');
      final response = await callable.call({
        'phone_number': normalizedPhone,
        'amount': amount.round(), // M-Pesa only accepts whole numbers
        'account_reference': accountReference ?? 'PromoHub-${orderId.substring(0, 8)}',
        'transaction_description': 'Payment for order ${orderId.substring(0, 8)}',
        'transaction_id': transactionRef.id,
      });

      final responseData = Map<String, dynamic>.from(response.data);

      if (responseData['success'] == true) {
        // Update transaction with M-Pesa checkout request ID
        await transactionRef.update({
          'mpesa_checkout_request_id': responseData['checkout_request_id'],
          'mpesa_merchant_request_id': responseData['merchant_request_id'],
        });

        return {
          'success': true,
          'transaction_id': transactionRef.id,
          'checkout_request_id': responseData['checkout_request_id'],
          'message': 'STK Push sent to $normalizedPhone. Check your phone.',
        };
      } else {
        // Mark as failed
        await transactionRef.update({
          'payment_status': 'failed',
        });

        return {
          'success': false,
          'message': responseData['message'] ?? 'M-Pesa request failed',
        };
      }
    } catch (e) {
      debugPrint('M-Pesa STK Push error: $e');
      return {
        'success': false,
        'message': 'Could not initiate M-Pesa payment. Please try again.',
      };
    }
  }

  /// Check the status of an M-Pesa STK Push transaction.
  /// Call this after the user confirms on their phone.
  Future<Map<String, dynamic>> checkMpesaStatus(String transactionId) async {
    try {
      final transactionDoc = await _firestore.collection('transactions').doc(transactionId).get();
      final transaction = transactionDoc.data()!;

      if (transaction['payment_status'] == 'completed') {
        return {
          'success': true,
          'status': 'completed',
          'amount': transaction['amount']
        };
      } else if (transaction['payment_status'] == 'failed') {
        return {'success': false, 'status': 'failed'};
      }

      // If still pending, query the Cloud Function to check with Safaricom
      final callable = _functions.httpsCallable('mpesaQuery');
      final response = await callable.call({
        'checkout_request_id': transaction['mpesa_checkout_request_id'],
        'transaction_id': transactionId,
      });
      
      final responseData = Map<String, dynamic>.from(response.data);

      return {
        'success': responseData['result_code'] == '0',
        'status': responseData['result_code'] == '0' ? 'completed' : 'pending',
        'message': responseData['result_desc'] ?? 'Waiting for confirmation',
      };
    } catch (e) {
      return {
        'success': false,
        'status': 'error',
        'message': 'Could not check payment status'
      };
    }
  }

  /// Normalize Kenyan phone numbers to the 254XXXXXXXXX format
  String _normalizeKenyanPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+254')) {
      return cleaned.substring(1); // Remove '+'
    } else if (cleaned.startsWith('254')) {
      return cleaned;
    } else if (cleaned.startsWith('0')) {
      return '254${cleaned.substring(1)}';
    } else if (cleaned.startsWith('7') || cleaned.startsWith('1')) {
      return '254$cleaned';
    }
    return cleaned;
  }

  // ============================================================
  // STRIPE (CARD PAYMENTS)
  // ============================================================

  /// Create a Stripe payment intent for card-based payments.
  Future<Map<String, dynamic>> createStripePaymentIntent({
    required String orderId,
    required double amount,
    String currency = 'kes',
  }) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Create transaction record
    final transactionRef = await _firestore.collection('transactions').add({
      'order_id': orderId,
      'buyer_id': userId,
      'amount': amount,
      'payment_method': 'card',
      'payment_status': 'pending',
      'processing_fee': amount * 0.029, // 2.9% Stripe fee
      'created_at': FieldValue.serverTimestamp(),
    });

    try {
      final callable = _functions.httpsCallable('createPaymentIntent');
      final response = await callable.call({
        'amount': (amount * 100).round(), // Convert to cents
        'currency': currency,
        'transaction_id': transactionRef.id,
        'metadata': {
          'order_id': orderId,
          'buyer_id': userId,
        },
      });
      
      final responseData = Map<String, dynamic>.from(response.data);

      // Update transaction with Stripe payment intent ID
      await transactionRef.update({
        'stripe_payment_intent_id': responseData['payment_intent_id'],
      });

      return {
        'client_secret': responseData['client_secret'],
        'payment_intent_id': responseData['payment_intent_id'],
        'transaction_id': transactionRef.id,
      };
    } catch (e) {
      await transactionRef.update({
        'payment_status': 'failed',
      });

      throw Exception('Failed to create payment intent: $e');
    }
  }

  // ============================================================
  // COMMON
  // ============================================================

  /// Confirm a payment as completed (called by webhook or manually).
  Future<void> confirmPayment(String transactionId) async {
    await _firestore.collection('transactions').doc(transactionId).update({
      'payment_status': 'completed',
      'completed_at': FieldValue.serverTimestamp(),
    });

    // Update the order status
    final transactionDoc = await _firestore.collection('transactions').doc(transactionId).get();
    if (transactionDoc.exists) {
      final orderId = transactionDoc.data()!['order_id'];
      await _firestore.collection('orders').doc(orderId).update({'status': 'processing'});
    }
  }

  /// Get transaction history for the current user (as buyer or seller).
  Future<List<Map<String, dynamic>>> getTransactionHistory(
      String userId) async {
      
    // In Firestore, we must query transactions where the user is either the buyer or (indirectly) the seller.
    // For simplicity, we query buyer first. For a seller dashboard, a separate query on seller_id is recommended.
    final snapshot = await _firestore
        .collection('transactions')
        .where('buyer_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();
        
    List<Map<String, dynamic>> results = [];
    for (var doc in snapshot.docs) {
      var trans = {'id': doc.id, ...doc.data()};
      
      // Fetch related order
      final orderDoc = await _firestore.collection('orders').doc(trans['order_id']).get();
      if (orderDoc.exists) {
        trans['order'] = {'id': orderDoc.id, ...?orderDoc.data()};
      }
      
      // Fetch related buyer info
      final buyerDoc = await _firestore.collection('user_profiles').doc(trans['buyer_id']).get();
      if (buyerDoc.exists) {
        trans['buyer'] = {'id': buyerDoc.id, ...?buyerDoc.data()};
      }
      results.add(trans);
    }
    return results;
  }

  /// Get a single transaction by ID
  Future<Map<String, dynamic>?> getTransaction(String transactionId) async {
    final doc = await _firestore.collection('transactions').doc(transactionId).get();
    if (doc.exists) {
      return {'id': doc.id, ...?doc.data()};
    }
    return null;
  }
}
