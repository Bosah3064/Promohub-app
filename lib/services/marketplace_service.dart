import './supabase_service.dart';

class MarketplaceService {
  final SupabaseService _supabaseService = SupabaseService();

  // Fetch all active categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabaseService.selectRows(
        'categories',
        filters: {'is_active': true},
        orderBy: 'name',
      );
      return List<Map<String, dynamic>>.from(response);
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
      final client = await _supabaseService.client;
      var query = client.from('listings').select('''
            *,
            seller_id:user_profiles(id, full_name, avatar_url, rating),
            category_id:categories(id, name, icon_url)
          ''').eq('status', 'active');

      // Apply filters
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (condition != null) {
        query = query.eq('condition', condition);
      }

      if (location != null) {
        query = query.ilike('location', '%$location%');
      }

      // Apply ordering, limit and offset in single chain
      final response = await query
          .order('created_at', ascending: false)
          .range(offset!, offset + limit! - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch listings: $error');
    }
  }

  // Get featured listings
  Future<List<Map<String, dynamic>>> getFeaturedListings(
      {int limit = 10}) async {
    try {
      final response = await _supabaseService.selectRows(
        'listings',
        select: '''
          *,
          seller_id:user_profiles(id, full_name, avatar_url, rating),
          category_id:categories(id, name, icon_url)
        ''',
        filters: {'status': 'active', 'featured': true},
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch featured listings: $error');
    }
  }

  // Get listing by ID
  Future<Map<String, dynamic>?> getListing(String listingId) async {
    try {
      final response = await _supabaseService.selectRows(
        'listings',
        select: '''
          *,
          seller_id:user_profiles(id, full_name, avatar_url, rating, phone, location),
          category_id:categories(id, name, icon_url)
        ''',
        filters: {'id': listingId},
      );

      if (response.isNotEmpty) {
        // Increment view count
        await _incrementViewCount(listingId);
        return Map<String, dynamic>.from(response.first);
      }
      return null;
    } catch (error) {
      throw Exception('Failed to fetch listing: $error');
    }
  }

  // Increment view count
  Future<void> _incrementViewCount(String listingId) async {
    try {
      final client = await _supabaseService.client;
      await client
          .rpc('increment_view_count', params: {'listing_id': listingId});
    } catch (error) {
      // Fail silently for view count increment
    }
  }

  // Create new listing
  Future<Map<String, dynamic>> createListing({
    required String sellerId,
    required String categoryId,
    required String title,
    required String description,
    required double price,
    required String condition,
    String? location,
    List<String>? images,
    List<String>? tags,
    bool isNegotiable = true,
  }) async {
    try {
      final listingData = {
        'seller_id': sellerId,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'price': price,
        'condition': condition,
        'location': location,
        'images': images ?? [],
        'tags': tags ?? [],
        'is_negotiable': isNegotiable,
        'status': 'active',
      };

      final response =
          await _supabaseService.insertRow('listings', listingData);
      return Map<String, dynamic>.from(response.first);
    } catch (error) {
      throw Exception('Failed to create listing: $error');
    }
  }

  // Update listing
  Future<Map<String, dynamic>> updateListing(
      String listingId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      final response = await _supabaseService.updateRow(
          'listings', updates, 'id', listingId);
      return Map<String, dynamic>.from(response.first);
    } catch (error) {
      throw Exception('Failed to update listing: $error');
    }
  }

  // Delete listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _supabaseService.deleteRow('listings', 'id', listingId);
    } catch (error) {
      throw Exception('Failed to delete listing: $error');
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

      final response = await _supabaseService.selectRows(
        'listings',
        select: '''
          *,
          category_id:categories(id, name, icon_url)
        ''',
        filters: filters,
        orderBy: 'created_at',
        ascending: false,
      );
      return List<Map<String, dynamic>>.from(response);
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
      };

      final response =
          await _supabaseService.insertRow('favorites', favoriteData);

      // Increment favorites count
      await _incrementFavoritesCount(listingId);

      return Map<String, dynamic>.from(response.first);
    } catch (error) {
      throw Exception('Failed to add to favorites: $error');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String userId, String listingId) async {
    try {
      final client = await _supabaseService.client;
      await client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);

      // Decrement favorites count
      await _decrementFavoritesCount(listingId);
    } catch (error) {
      throw Exception('Failed to remove from favorites: $error');
    }
  }

  // Check if listing is in favorites
  Future<bool> isInFavorites(String userId, String listingId) async {
    try {
      final response = await _supabaseService.selectRows(
        'favorites',
        filters: {'user_id': userId, 'listing_id': listingId},
      );
      return response.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  // Get user's favorites
  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    try {
      final response = await _supabaseService.selectRows(
        'favorites',
        select: '''
          *,
          listing_id:listings(
            *,
            seller_id:user_profiles(id, full_name, avatar_url, rating),
            category_id:categories(id, name, icon_url)
          )
        ''',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch user favorites: $error');
    }
  }

  // Increment favorites count
  Future<void> _incrementFavoritesCount(String listingId) async {
    try {
      final client = await _supabaseService.client;
      await client
          .rpc('increment_favorites_count', params: {'listing_id': listingId});
    } catch (error) {
      // Fail silently
    }
  }

  // Decrement favorites count
  Future<void> _decrementFavoritesCount(String listingId) async {
    try {
      final client = await _supabaseService.client;
      await client
          .rpc('decrement_favorites_count', params: {'listing_id': listingId});
    } catch (error) {
      // Fail silently
    }
  }

  // Get similar listings
  Future<List<Map<String, dynamic>>> getSimilarListings(
      String listingId, String categoryId,
      {int limit = 5}) async {
    try {
      final response = await _supabaseService.selectRows(
        'listings',
        select: '''
          *,
          seller_id:user_profiles(id, full_name, avatar_url, rating),
          category_id:categories(id, name, icon_url)
        ''',
        filters: {'category_id': categoryId, 'status': 'active'},
        orderBy: 'created_at',
        ascending: false,
        limit: limit + 1, // Get one extra to exclude current listing
      );

      // Filter out current listing
      final similarListings = List<Map<String, dynamic>>.from(response)
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
    try {
      if (query.trim().isEmpty) return [];

      final client = await _supabaseService.client;
      final response = await client
          .from('listings')
          .select('''
            *,
            seller_id:user_profiles(id, full_name, avatar_url, rating),
            category_id:categories(id, name, icon_url)
          ''')
          .eq('status', 'active')
          .or('title.ilike.%$query%,description.ilike.%$query%,tags.cs.{$query}')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search listings: $error');
    }
  }
}
