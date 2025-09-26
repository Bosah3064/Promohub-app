import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  final Future<void> _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() : _initFuture = _initializeSupabase();

  static const String supabaseUrl = String.fromEnvironment(
      'https://fqbuptggiugkhztnpxjg.supabase.co',
      defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment(
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxYnVwdGdnaXVna2h6dG5weGpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3NzY3ODcsImV4cCI6MjA2OTM1Mjc4N30.PaATjQmVQCcSFJ6bJ4ILGI1g-oD7i3OHC_-Fcm8jtYQ',
      defaultValue: '');

  // Internal initialization logic
  static Future<void> _initializeSupabase() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _instance._client = Supabase.instance.client;
    _instance._isInitialized = true;
  }

  // Client getter (async)
  Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      await _initFuture;
    }
    return _client;
  }

  // Add missing currentUserId getter
  String? get currentUserId {
    return _client.auth.currentUser?.id;
  }

  // Helper method to select rows with filters and options
  Future<List<dynamic>> selectRows(
    String table, {
    String select = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      var query = _client.from(table).select(select);

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      // Fix: Don't reassign query when using order(), instead chain the operations
      if (orderBy != null && limit != null) {
        return await query.order(orderBy, ascending: ascending).limit(limit);
      } else if (orderBy != null) {
        return await query.order(orderBy, ascending: ascending);
      } else if (limit != null) {
        return await query.limit(limit);
      }

      return await query;
    } catch (error) {
      throw Exception('Select failed: $error');
    }
  }

  // Helper method to insert a row
  Future<List<dynamic>> insertRow(
      String table, Map<String, dynamic> data) async {
    try {
      final response = await _client.from(table).insert(data).select();
      return response;
    } catch (error) {
      throw Exception('Insert failed: $error');
    }
  }

  // Helper method to update a row
  Future<List<dynamic>> updateRow(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    try {
      final response =
          await _client.from(table).update(data).eq(column, value).select();
      return response;
    } catch (error) {
      throw Exception('Update failed: $error');
    }
  }

  // Helper method to check if user_profiles table exists
  Future<bool> checkUserProfilesTableExists() async {
    try {
      final client = await this.client;
      await client.from('user_profiles').select('id').limit(1);
      return true;
    } catch (e) {
      if (e
          .toString()
          .contains('relation "public.user_profiles" does not exist')) {
        return false;
      }
      // Other errors might be permission-related, assume table exists
      return true;
    }
  }

  // Helper method to verify database setup
  Future<Map<String, bool>> verifyDatabaseSetup() async {
    final client = await this.client;
    final results = <String, bool>{};

    final tables = [
      'user_profiles',
      'categories',
      'listings',
      'favorites',
      'conversations',
      'messages',
      'transactions',
      'achievements',
      'user_achievements',
      'reviews'
    ];

    for (final table in tables) {
      try {
        await client.from(table).select('*').limit(1);
        results[table] = true;
      } catch (e) {
        results[table] = false;
      }
    }

    return results;
  }

  // Add authentication service methods
  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    String? fullName,
    String? role,
  }) async {
    try {
      final client = await this.client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? email.split('@')[0],
          'role': role ?? 'buyer',
        },
      );

      if (response.user != null) {
        return {
          'user': response.user!.toJson(),
          'session': response.session?.toJson(),
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
      final client = await this.client;
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return {
          'user': response.user!.toJson(),
          'session': response.session?.toJson(),
        };
      }
      return null;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  Future<void> signOut() async {
    try {
      final client = await this.client;
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // Get current user profile with extended information
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final response = await selectRows(
        'user_profiles',
        select: '''
          *,
          user_subscriptions!inner(
            *,
            tier_id:subscription_tiers(
              id, name, max_listings, priority_support, 
              featured_listings, analytics_access
            )
          )
        ''',
        filters: {'id': userId},
      );

      return response.isNotEmpty
          ? Map<String, dynamic>.from(response.first)
          : null;
    } catch (error) {
      // If no subscription, get basic profile
      try {
        final userId = currentUserId;
        if (userId == null) return null;

        final response = await selectRows(
          'user_profiles',
          filters: {'id': userId},
        );
        return response.isNotEmpty
            ? Map<String, dynamic>.from(response.first)
            : null;
      } catch (e) {
        return null;
      }
    }
  }

  // Add statistics methods for dashboard
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final client = await this.client;

      // Get counts in parallel - Fix: Use proper Future structure
      final futures = <Future<dynamic>>[
        client.from('listings').select().eq('seller_id', userId).count(),
        client
            .from('listings')
            .select()
            .eq('seller_id', userId)
            .eq('status', 'active')
            .count(),
        client
            .from('listings')
            .select()
            .eq('seller_id', userId)
            .eq('status', 'sold')
            .count(),
        client.from('favorites').select().eq('user_id', userId).count(),
        client
            .from('transactions')
            .select()
            .eq('seller_id', userId)
            .eq('payment_status', 'completed')
            .count(),
        client.from('reviews').select('rating').eq('reviewed_user_id', userId),
      ];

      final results = await Future.wait(futures);

      final totalListings = results[0].count ?? 0;
      final activeListings = results[1].count ?? 0;
      final soldListings = results[2].count ?? 0;
      final totalFavorites = results[3].count ?? 0;
      final totalSales = results[4].count ?? 0;
      final reviews = results[5] as List<dynamic>;

      // Calculate average rating
      double avgRating = 0.0;
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<double>(
            0.0,
            (sum, review) =>
                sum + ((review['rating'] as num?)?.toDouble() ?? 0.0));
        avgRating = totalRating / reviews.length;
      }

      return {
        'total_listings': totalListings,
        'active_listings': activeListings,
        'sold_listings': soldListings,
        'total_favorites': totalFavorites,
        'total_sales': totalSales,
        'average_rating': avgRating,
        'total_reviews': reviews.length,
      };
    } catch (error) {
      throw Exception('Failed to get user statistics: $error');
    }
  }

  // Add real-time subscription method
  void subscribeToUserListings(
      String userId, Function(List<Map<String, dynamic>>) onUpdate) {
    _client
        .channel('public:listings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'listings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'seller_id',
            value: userId,
          ),
          callback: (payload) async {
            // Fetch updated listings
            try {
              final updatedListings = await selectRows(
                'listings',
                select: '''
                  *,
                  category_id:categories(id, name, icon_url)
                ''',
                filters: {'seller_id': userId},
                orderBy: 'created_at',
                ascending: false,
              );
              onUpdate(List<Map<String, dynamic>>.from(updatedListings));
            } catch (e) {
              // Handle error silently
            }
          },
        )
        .subscribe();
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
      final client = await this.client;
      var queryBuilder = client.from('listings').select('''
        *,
        seller_id:user_profiles(id, full_name, avatar_url, rating),
        category_id:categories(id, name, icon_url)
      ''').eq('status', 'active');

      // Apply filters progressively
      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      if (query != null && query.trim().isNotEmpty) {
        queryBuilder =
            queryBuilder.or('title.ilike.%$query%,description.ilike.%$query%');
      }

      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price', minPrice);
      }

      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price', maxPrice);
      }

      if (condition != null) {
        queryBuilder = queryBuilder.eq('condition', condition);
      }

      if (location != null) {
        queryBuilder = queryBuilder.ilike('location', '%$location%');
      }

      if (tags != null && tags.isNotEmpty) {
        queryBuilder = queryBuilder.overlaps('tags', tags);
      }

      // Execute query with pagination
      final response = await queryBuilder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Advanced search failed: $error');
    }
  }

  // Add missing deleteRow method
  Future<void> deleteRow(String table, String column, dynamic value) async {
    try {
      final client = await this.client;
      await client.from(table).delete().eq(column, value);
    } catch (error) {
      throw Exception('Delete failed: $error');
    }
  }
}
