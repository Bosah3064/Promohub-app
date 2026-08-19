import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './firebase_service.dart';

class MarketplaceService {
  final FirebaseService _firebaseService = FirebaseService();
  FirebaseFirestore get _firestore => _firebaseService.firestore;

  // Fetch all active categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _firebaseService.selectRows(
        'categories',
        filters: {'is_active': true},
        orderBy: 'name',
      );
      return response;
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  // Fetch listings with filters
  Future<List<Map<String, dynamic>>> getListings({
    String? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      // In Firestore, we use the advancedSearch from FirebaseService 
      // since it handles client-side search for ilike queries
      return await _firebaseService.advancedSearch(
        categoryId: categoryId,
        query: searchQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
        condition: condition,
        location: location,
        limit: limit ?? 20,
        offset: offset ?? 0,
      );
    } catch (error) {
      throw Exception('Failed to fetch listings: $error');
    }
  }

  // Get featured listings
  Future<List<Map<String, dynamic>>> getFeaturedListings(
      {int limit = 10}) async {
    try {
      final response = await _firebaseService.selectRows(
        'listings',
        filters: {'status': 'active', 'featured': true},
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
      );
      return response;
    } catch (error) {
      throw Exception('Failed to fetch featured listings: $error');
    }
  }

  // Get listings by seller ID
  Future<List<Map<String, dynamic>>> getListingsBySellerId(String sellerId) async {
    try {
      final response = await _firebaseService.selectRows(
        'listings',
        filters: {'seller_id': sellerId},
        orderBy: 'created_at',
        ascending: false,
      );
      return response;
    } catch (error) {
      throw Exception('Failed to fetch seller listings: $error');
    }
  }

  // Get listing by ID
  Future<Map<String, dynamic>?> getListing(String listingId) async {
    try {
      final response = await _firebaseService.selectRows(
        'listings',
        filters: {'id': listingId},
      );

      if (response.isNotEmpty) {
        // Increment view count
        await _incrementViewCount(listingId);
        final listing = Map<String, dynamic>.from(response.first);
        
        // Fetch seller details if needed and not fully denormalized
        final sellerDoc = await _firestore.collection('user_profiles').doc(listing['seller_id']).get();
        if (sellerDoc.exists) {
          listing['seller_id'] = {'id': sellerDoc.id, ...?sellerDoc.data()};
        }
        
        return listing;
      }
      return null;
    } catch (error) {
      throw Exception('Failed to fetch listing: $error');
    }
  }

  // Increment view count
  Future<void> _incrementViewCount(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).update({
        'views_count': FieldValue.increment(1)
      });
    } catch (error) {
      // Fail silently
    }
  }

  // Create listing
  Future<Map<String, dynamic>> createListing(Map<String, dynamic> listingData) async {
    try {
      listingData['created_at'] = FieldValue.serverTimestamp();
      listingData['updated_at'] = FieldValue.serverTimestamp();
      final response = await _firebaseService.insertRow('listings', listingData);
      return response.first;
    } catch (error) {
      throw Exception('Failed to create listing: $error');
    }
  }

  // Update listing
  Future<Map<String, dynamic>> updateListing(
      String listingId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      final response = await _firebaseService.updateRow('listings', updates, 'id', listingId);
      return response.first;
    } catch (error) {
      throw Exception('Failed to update listing: $error');
    }
  }

  // Delete listing
  Future<bool> deleteListing(String listingId) async {
    try {
      await _firebaseService.deleteRow('listings', 'id', listingId);
      return true;
    } catch (error) {
      throw Exception('Failed to delete listing: $error');
    }
  }

  // --- SHOP & KYC MANAGEMENT (PHASE 1) ---

  Future<Map<String, dynamic>?> getUserShop(String userId) async {
    try {
      final response = await _firebaseService.selectRows(
        'shops',
        filters: {'owner_id': userId},
        limit: 1,
      );
      return response.isNotEmpty ? response.first : null;
    } catch (error) {
      throw Exception('Failed to fetch user shop: $error');
    }
  }

  Future<Map<String, dynamic>> createShop(Map<String, dynamic> shopData) async {
    try {
      shopData['created_at'] = FieldValue.serverTimestamp();
      final response = await _firebaseService.insertRow('shops', shopData);
      return response.first;
    } catch (error) {
      throw Exception('Failed to create shop: $error');
    }
  }

  Future<Map<String, dynamic>> submitKYC(Map<String, dynamic> kycData) async {
    try {
      kycData['submitted_at'] = FieldValue.serverTimestamp();
      final response = await _firebaseService.insertRow('kyc_documents', kycData);
      return response.first;
    } catch (error) {
      throw Exception('Failed to submit KYC: $error');
    }
  }

  // --- CART & ORDERS MANAGEMENT (PHASE 2) ---

  Future<void> addToCart(String listingId, int quantity) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    try {
      await _firebaseService.insertRow('cart', {
        'user_id': userId,
        'listing_id': listingId,
        'quantity': quantity,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw Exception('Failed to add to cart: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    try {
      final snapshot = await _firestore.collection('cart').where('user_id', isEqualTo: userId).get();
      List<Map<String, dynamic>> cartItems = [];
      
      for (var doc in snapshot.docs) {
        var cartData = {'id': doc.id, ...doc.data()};
        // Fetch listing
        final listingDoc = await _firestore.collection('listings').doc(cartData['listing_id']).get();
        if (listingDoc.exists) {
          cartData['listing_id'] = {'id': listingDoc.id, ...?listingDoc.data()};
        }
        cartItems.add(cartData);
      }
      return cartItems;
    } catch (error) {
      throw Exception('Failed to fetch cart: $error');
    }
  }

  Future<void> removeFromCart(String cartId) async {
    try {
      await _firebaseService.deleteRow('cart', 'id', cartId);
    } catch (error) {
      throw Exception('Failed to remove from cart: $error');
    }
  }

  Future<void> updateCartQuantity(String cartId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartId);
      } else {
        await _firestore.collection('cart').doc(cartId).update({'quantity': newQuantity});
      }
    } catch (error) {
      throw Exception('Failed to update cart quantity: $error');
    }
  }

  Future<void> clearCart() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) return;
    try {
      final snapshot = await _firestore.collection('cart').where('user_id', isEqualTo: userId).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      throw Exception('Failed to clear cart: $error');
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData, List<Map<String, dynamic>> orderItems) async {
    try {
      orderData['created_at'] = FieldValue.serverTimestamp();
      final orderDoc = await _firestore.collection('orders').add(orderData);
      
      final batch = _firestore.batch();
      for (var item in orderItems) {
        final itemRef = orderDoc.collection('items').doc();
        batch.set(itemRef, item);
      }
      await batch.commit();
      
      return {'id': orderDoc.id, ...orderData};
    } catch (error) {
      throw Exception('Failed to create order: $error');
    }
  }

  // --- MONETIZATION & ADS (PHASE 5) ---

  Future<List<Map<String, dynamic>>> getSponsoredListings({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('sponsored_products')
          .where('is_active', isEqualTo: true)
          // Note: In Firestore, inequalities must be on the same field as orderby.
          // Filtering ends_at in memory
          .orderBy('tier', descending: true)
          .limit(limit * 2)
          .get();
      
      List<Map<String, dynamic>> results = [];
      final now = DateTime.now();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final endsAt = (data['ends_at'] as Timestamp).toDate();
        if (endsAt.isAfter(now)) {
          var sponsored = {'id': doc.id, ...data};
          final listingDoc = await _firestore.collection('listings').doc(data['listing_id']).get();
          if (listingDoc.exists) {
            sponsored['listing_id'] = {'id': listingDoc.id, ...?listingDoc.data()};
            results.add(sponsored);
          }
          if (results.length >= limit) break;
        }
      }
      return results;
    } catch (error) {
      return [];
    }
  }

  Future<void> recordAdImpression(String sponsoredId) async {
    try {
      await _firestore.collection('sponsored_products').doc(sponsoredId).update({
        'impressions': FieldValue.increment(1)
      });
    } catch (error) {}
  }

  Future<void> recordAdClick(String sponsoredId) async {
    try {
      await _firestore.collection('sponsored_products').doc(sponsoredId).update({
        'clicks': FieldValue.increment(1)
      });
    } catch (error) {}
  }

  // --- SELLER ORDER MANAGEMENT (PHASE 6) ---

  Future<List<Map<String, dynamic>>> getSellerOrders(String shopId, {String? status}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('orders').where('shop_id', isEqualTo: shopId);
      if (status != null && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }
      query = query.orderBy('created_at', descending: true);
      
      final snapshot = await query.get();
      List<Map<String, dynamic>> orders = [];
      
      for (var doc in snapshot.docs) {
        var order = {'id': doc.id, ...doc.data()};
        final itemsSnap = await doc.reference.collection('items').get();
        order['order_items'] = itemsSnap.docs.map((itemDoc) => {'id': itemDoc.id, ...itemDoc.data()}).toList();
        orders.add(order);
      }
      return orders;
    } catch (error) {
      debugPrint('Error fetching seller orders: $error');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (error) {
      throw Exception('Failed to update order status: $error');
    }
  }

  // --- TRUST & REVIEWS (PHASE 4) ---

  Future<void> submitReview({
    required String orderId,
    required String shopId,
    required int rating,
    String? comment,
  }) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    try {
      await _firestore.collection('reviews').add({
        'order_id': orderId,
        'reviewer_id': userId,
        'shop_id': shopId,
        'rating': rating,
        'comment': comment,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw Exception('Failed to submit review: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getShopReviews(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('shop_id', isEqualTo: shopId)
          .orderBy('created_at', descending: true)
          .get();
      
      List<Map<String, dynamic>> reviews = [];
      for (var doc in snapshot.docs) {
        var review = {'id': doc.id, ...doc.data()};
        final reviewerDoc = await _firestore.collection('user_profiles').doc(review['reviewer_id']).get();
        if (reviewerDoc.exists) {
          review['reviewer'] = reviewerDoc.data();
        }
        reviews.add(review);
      }
      return reviews;
    } catch (error) {
      debugPrint('Error fetching reviews: $error');
      return [];
    }
  }

  Future<void> openDispute({
    required String orderId,
    required String reason,
    required String description,
  }) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    try {
      await _firestore.collection('disputes').add({
        'order_id': orderId,
        'opened_by': userId,
        'reason': reason,
        'description': description,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'open',
      });
    } catch (error) {
      throw Exception('Failed to open dispute: $error');
    }
  }

  // Get user's listings
  Future<List<Map<String, dynamic>>> getUserListings(String userId,
      {String? status}) async {
    try {
      Map<String, dynamic> filters = {'seller_id': userId};
      if (status != null) {
        filters['status'] = status;
      }

      return await _firebaseService.selectRows(
        'listings',
        filters: filters,
        orderBy: 'created_at',
        ascending: false,
      );
    } catch (error) {
      throw Exception('Failed to fetch user listings: $error');
    }
  }

  // Add to favorites
  Future<Map<String, dynamic>> addToFavorites(
      String userId, String listingId) async {
    try {
      final favoriteData = {
        'user_id': userId,
        'listing_id': listingId,
        'created_at': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('favorites').add(favoriteData);
      await _incrementFavoritesCount(listingId);

      return {'id': docRef.id, ...favoriteData};
    } catch (error) {
      throw Exception('Failed to add to favorites: $error');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String userId, String listingId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: userId)
          .where('listing_id', isEqualTo: listingId)
          .get();
          
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      await _decrementFavoritesCount(listingId);
    } catch (error) {
      throw Exception('Failed to remove from favorites: $error');
    }
  }

  // Check if listing is in favorites
  Future<bool> isInFavorites(String userId, String listingId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: userId)
          .where('listing_id', isEqualTo: listingId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  // Get user's favorites
  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();
          
      List<Map<String, dynamic>> favorites = [];
      for (var doc in snapshot.docs) {
        var fav = {'id': doc.id, ...doc.data()};
        final listingDoc = await _firestore.collection('listings').doc(fav['listing_id']).get();
        if (listingDoc.exists) {
          fav['listing_id'] = {'id': listingDoc.id, ...?listingDoc.data()};
        }
        favorites.add(fav);
      }
      return favorites;
    } catch (error) {
      throw Exception('Failed to fetch user favorites: $error');
    }
  }

  // Increment favorites count
  Future<void> _incrementFavoritesCount(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).update({
        'favorites_count': FieldValue.increment(1)
      });
    } catch (error) {}
  }

  // Decrement favorites count
  Future<void> _decrementFavoritesCount(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).update({
        'favorites_count': FieldValue.increment(-1)
      });
    } catch (error) {}
  }

  // Get similar listings
  Future<List<Map<String, dynamic>>> getSimilarListings(
      String listingId, String categoryId,
      {int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('category_id', isEqualTo: categoryId)
          .where('status', isEqualTo: 'active')
          .orderBy('created_at', descending: true)
          .limit(limit + 1)
          .get();
          
      final similarListings = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .where((listing) => listing['id'] != listingId)
          .take(limit)
          .toList();

      return similarListings;
    } catch (error) {
      throw Exception('Failed to fetch similar listings: $error');
    }
  }

  // Search listings with full-text search
  Future<List<Map<String, dynamic>>> searchListings(String query,
      {int limit = 20}) async {
    return await getListings(searchQuery: query, limit: limit);
  }
}
