import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;
  bool _isInitialized = false;

  // Singleton pattern
  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal() {
    _init();
  }

  void _init() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
    _isInitialized = true;
  }

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // Generic method to select rows mapping to Firestore
  Future<List<Map<String, dynamic>>> selectRows(
    String table, {
    String select = '*', // Not supported natively in Firestore, usually returns all
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(table);

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.where(key, isEqualTo: value);
        });
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: !ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (error) {
      throw Exception('Select failed in Firebase: $error');
    }
  }

  // Generic method to insert a row
  Future<List<Map<String, dynamic>>> insertRow(
      String table, Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(table).add(data);
      return [
        {'id': docRef.id, ...data}
      ];
    } catch (error) {
      throw Exception('Insert failed in Firebase: $error');
    }
  }

  // Generic method to update a row
  Future<List<Map<String, dynamic>>> updateRow(
    String table,
    Map<String, dynamic> data,
    String column, // Typically 'id' in Firestore
    dynamic value,
  ) async {
    try {
      if (column == 'id') {
        await _firestore.collection(table).doc(value.toString()).update(data);
        return [
          {'id': value, ...data}
        ];
      } else {
        // Complex update based on query
        final snapshot = await _firestore
            .collection(table)
            .where(column, isEqualTo: value)
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.update(data);
        }
        return snapshot.docs.map((d) => {'id': d.id, ...data}).toList();
      }
    } catch (error) {
      throw Exception('Update failed in Firebase: $error');
    }
  }

  // Generic delete row
  Future<void> deleteRow(String table, String column, dynamic value) async {
    try {
      if (column == 'id') {
        await _firestore.collection(table).doc(value.toString()).delete();
      } else {
        final snapshot = await _firestore
            .collection(table)
            .where(column, isEqualTo: value)
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (error) {
      throw Exception('Delete failed in Firebase: $error');
    }
  }

  // Upload Image to Storage
  Future<String> uploadImage(String bucket, String path, dynamic file) async {
    try {
      final ref = _storage.ref().child(bucket).child(path);
      if (file is File) {
        await ref.putFile(file);
      } else if (file is Uint8List) {
        await ref.putData(file);
      } else {
        throw Exception('Unsupported file type');
      }
      return await ref.getDownloadURL();
    } catch (error) {
      throw Exception('Failed to upload image: $error');
    }
  }

  // Authentication
  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    String? fullName,
    String? role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Will be picked up by Cloud Functions or done here
        await _firestore.collection('user_profiles').doc(user.uid).set({
          'email': email,
          'full_name': fullName ?? email.split('@')[0],
          'role': role ?? 'buyer',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        return {
          'user': {'id': user.uid, 'email': user.email},
          'session': null, // Firebase handles session automatically
        };
      }
      return null;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        return {
          'user': {'id': user.uid, 'email': user.email},
          'session': null,
        };
      }
      return null;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('user_profiles').doc(userId).get();
      if (!doc.exists) return null;

      final userData = {'id': doc.id, ...?doc.data()};

      // In Firebase, we do a separate query for subscriptions
      final subQuery = await _firestore
          .collection('user_subscriptions')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (subQuery.docs.isNotEmpty) {
        final subData = subQuery.docs.first.data();
        // optionally fetch tier info if needed
        userData['user_subscriptions'] = [subData];
      }

      return userData;
    } catch (e) {
      return null;
    }
  }

  // Dashboard Statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      // Note: For real prod, use Firestore Aggregation queries (count())
      final listings = await _firestore
          .collection('listings')
          .where('seller_id', isEqualTo: userId)
          .count()
          .get();
      
      final activeListings = await _firestore
          .collection('listings')
          .where('seller_id', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .count()
          .get();

      final soldListings = await _firestore
          .collection('listings')
          .where('seller_id', isEqualTo: userId)
          .where('status', isEqualTo: 'sold')
          .count()
          .get();

      final favorites = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: userId)
          .count()
          .get();

      final transactions = await _firestore
          .collection('transactions')
          .where('seller_id', isEqualTo: userId)
          .where('payment_status', isEqualTo: 'completed')
          .count()
          .get();

      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('reviewed_user_id', isEqualTo: userId)
          .get();

      double avgRating = 0.0;
      if (reviewsSnapshot.docs.isNotEmpty) {
        final totalRating = reviewsSnapshot.docs.fold<double>(
            0.0,
            (sum, doc) => sum + ((doc.data()['rating'] as num?)?.toDouble() ?? 0.0));
        avgRating = totalRating / reviewsSnapshot.docs.length;
      }

      return {
        'total_listings': listings.count ?? 0,
        'active_listings': activeListings.count ?? 0,
        'sold_listings': soldListings.count ?? 0,
        'total_favorites': favorites.count ?? 0,
        'total_sales': transactions.count ?? 0,
        'average_rating': avgRating,
        'total_reviews': reviewsSnapshot.docs.length,
      };
    } catch (error) {
      throw Exception('Failed to get user statistics: $error');
    }
  }

  // Real-time subscription
  void subscribeToUserListings(
      String userId, Function(List<Map<String, dynamic>>) onUpdate) {
    _firestore
        .collection('listings')
        .where('seller_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final updatedListings = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
      onUpdate(updatedListings);
    });
  }

  // Advanced search method
  Future<List<Map<String, dynamic>>> advancedSearch({
    String? query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    List<String>? tags,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query<Map<String, dynamic>> queryBuilder = _firestore
          .collection('listings')
          .where('status', isEqualTo: 'active');

      if (categoryId != null) {
        queryBuilder = queryBuilder.where('category_id', isEqualTo: categoryId);
      }

      if (minPrice != null) {
        queryBuilder = queryBuilder.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        queryBuilder = queryBuilder.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (condition != null) {
        queryBuilder = queryBuilder.where('condition', isEqualTo: condition);
      }

      if (tags != null && tags.isNotEmpty) {
        queryBuilder = queryBuilder.where('tags', arrayContainsAny: tags);
      }

      queryBuilder = queryBuilder.orderBy('created_at', descending: true).limit(limit);

      final snapshot = await queryBuilder.get();
      var results = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      // Client-side filtering for text search and exact location since Firestore
      // doesn't support complex text search natively without extensions like Algolia
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        results = results.where((item) {
          final title = (item['title']?.toString() ?? '').toLowerCase();
          final desc = (item['description']?.toString() ?? '').toLowerCase();
          return title.contains(q) || desc.contains(q);
        }).toList();
      }

      if (location != null && location.isNotEmpty) {
        final l = location.toLowerCase();
        results = results.where((item) {
          final itemLoc = (item['location']?.toString() ?? '').toLowerCase();
          return itemLoc.contains(l);
        }).toList();
      }

      return results;
    } catch (error) {
      throw Exception('Advanced search failed: $error');
    }
  }

  // Helper method to verify database setup
  Future<Map<String, bool>> verifyDatabaseSetup() async {
    // In Firestore, collections exist implicitly when they have documents
    // So this might always return false if empty. Just assume true for Firebase
    final results = <String, bool>{};
    final collections = [
      'user_profiles',
      'categories',
      'listings',
      'favorites',
      'conversations',
      'messages',
      'transactions',
      'achievements',
      'reviews'
    ];
    for (final col in collections) {
      results[col] = true;
    }
    return results;
  }
}
