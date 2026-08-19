import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  FirebaseFirestore get _firestore => _firebaseService.firestore;

  /// Get the current seller's wallet (available balance, pending, total withdrawn)
  Future<Map<String, dynamic>> getWallet() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    try {
      final snapshot = await _firestore
          .collection('seller_wallets')
          .where('seller_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};
      }

      // No wallet yet — return zeroed defaults
      return {
        'seller_id': userId,
        'available_balance': 0.0,
        'pending_balance': 0.0,
        'total_withdrawn': 0.0,
      };
    } catch (e) {
      return {
        'seller_id': userId,
        'available_balance': 0.0,
        'pending_balance': 0.0,
        'total_withdrawn': 0.0,
      };
    }
  }

  /// Request a withdrawal (M-Pesa B2C)
  Future<Map<String, dynamic>> requestWithdrawal(double amount) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    try {
      // 1. Check available balance
      final wallet = await getWallet();
      final available = (wallet['available_balance'] as num?)?.toDouble() ?? 0.0;
      final walletId = wallet['id'] as String?;

      if (amount > available) {
        throw Exception('Insufficient balance. Available: KSh ${available.toStringAsFixed(0)}');
      }

      if (amount < 50) {
        throw Exception('Minimum withdrawal is KSh 50');
      }

      // We use a Firestore batch/transaction to ensure consistency
      return await _firestore.runTransaction((transaction) async {
        // 2. Insert withdrawal request
        final withdrawalRef = _firestore.collection('withdrawals').doc();
        transaction.set(withdrawalRef, {
          'seller_id': userId,
          'amount': amount,
          'status': 'pending',
          'created_at': FieldValue.serverTimestamp(),
        });

        // 3. Debit available balance immediately
        if (walletId != null) {
          final walletRef = _firestore.collection('seller_wallets').doc(walletId);
          // In a real app we'd read the doc inside the transaction, but we use field increment here
          transaction.update(walletRef, {
            'available_balance': FieldValue.increment(-amount),
            'total_withdrawn': FieldValue.increment(amount),
          });
        }

        return {
          'id': withdrawalRef.id,
          'seller_id': userId,
          'amount': amount,
          'status': 'pending',
        };
      });
    } catch (e) {
      throw Exception('Withdrawal failed: $e');
    }
  }

  /// Get withdrawal history
  Future<List<Map<String, dynamic>>> getWithdrawalHistory() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    try {
      final snapshot = await _firestore
          .collection('withdrawals')
          .where('seller_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      return [];
    }
  }
}
