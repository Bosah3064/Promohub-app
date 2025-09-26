import './supabase_service.dart';

class LocationCurrencyService {
  final SupabaseService _supabaseService = SupabaseService();

  // Add missing getAllCountries method
  Future<List<Map<String, dynamic>>> getAllCountries() async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('locations')
          .select('country_code, country_name')
          .eq('status', 'active')
          .order('country_name');

      // Remove duplicates based on country_code
      final Map<String, Map<String, dynamic>> uniqueCountries = {};
      for (final location in response) {
        final countryCode = location['country_code'] as String;
        if (!uniqueCountries.containsKey(countryCode)) {
          uniqueCountries[countryCode] = {
            'country_code': countryCode,
            'country_name': location['country_name'],
          };
        }
      }

      return uniqueCountries.values.toList();
    } catch (error) {
      throw Exception('Failed to fetch all countries: $error');
    }
  }

  // Add missing getAllCurrencies method
  Future<List<Map<String, dynamic>>> getAllCurrencies() async {
    try {
      final response = await _supabaseService.selectRows(
        'currencies',
        filters: {'status': 'active'},
        orderBy: 'code',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch all currencies: $error');
    }
  }

  // Fetch all active currencies
  Future<List<Map<String, dynamic>>> getCurrencies() async {
    try {
      final response = await _supabaseService.selectRows(
        'currencies',
        filters: {'status': 'active'},
        orderBy: 'code',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch currencies: $error');
    }
  }

  // Fetch all active locations
  Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      final response = await _supabaseService.selectRows(
        'locations',
        filters: {'status': 'active'},
        orderBy: 'country_name',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch locations: $error');
    }
  }

  // Get locations by country
  Future<List<Map<String, dynamic>>> getLocationsByCountry(
      String countryCode) async {
    try {
      final response = await _supabaseService.selectRows(
        'locations',
        filters: {'country_code': countryCode, 'status': 'active'},
        orderBy: 'city_name',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch locations by country: $error');
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final response = await _supabaseService.selectRows(
        'user_preferences',
        select: '''
          *,
          preferred_currency_id:currencies(id, code, name, symbol),
          preferred_location_id:locations(id, country_name, city_name)
        ''',
        filters: {'user_id': userId},
      );
      return response.isNotEmpty
          ? Map<String, dynamic>.from(response.first)
          : null;
    } catch (error) {
      throw Exception('Failed to fetch user preferences: $error');
    }
  }

  // Update user preferences
  Future<Map<String, dynamic>> updateUserPreferences(
    String userId, {
    String? currencyId,
    String? locationId,
    String? languageCode,
    String? theme,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (currencyId != null) updates['preferred_currency_id'] = currencyId;
      if (locationId != null) updates['preferred_location_id'] = locationId;
      if (languageCode != null) updates['language_code'] = languageCode;
      if (theme != null) updates['theme'] = theme;
      if (notificationsEnabled != null) {
        updates['notifications_enabled'] = notificationsEnabled;
      }
      if (emailNotifications != null) {
        updates['email_notifications'] = emailNotifications;
      }
      if (pushNotifications != null) {
        updates['push_notifications'] = pushNotifications;
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      // Try to update existing preferences
      final existingPrefs = await getUserPreferences(userId);

      if (existingPrefs != null) {
        final response = await _supabaseService.updateRow(
          'user_preferences',
          updates,
          'user_id',
          userId,
        );
        return Map<String, dynamic>.from(response.first);
      } else {
        // Create new preferences if none exist
        updates['user_id'] = userId;
        final response =
            await _supabaseService.insertRow('user_preferences', updates);
        return Map<String, dynamic>.from(response.first);
      }
    } catch (error) {
      throw Exception('Failed to update user preferences: $error');
    }
  }

  // Get base currency (for conversion calculations)
  Future<Map<String, dynamic>?> getBaseCurrency() async {
    try {
      final response = await _supabaseService.selectRows(
        'currencies',
        filters: {'is_base': true, 'status': 'active'},
      );
      return response.isNotEmpty
          ? Map<String, dynamic>.from(response.first)
          : null;
    } catch (error) {
      throw Exception('Failed to fetch base currency: $error');
    }
  }

  // Convert price between currencies
  Future<double> convertPrice(
      double amount, String fromCurrencyId, String toCurrencyId) async {
    try {
      if (fromCurrencyId == toCurrencyId) return amount;

      final fromCurrency = await _supabaseService
          .selectRows('currencies', filters: {'id': fromCurrencyId});

      final toCurrency = await _supabaseService
          .selectRows('currencies', filters: {'id': toCurrencyId});

      if (fromCurrency.isEmpty || toCurrency.isEmpty) {
        throw Exception('Currency not found');
      }

      final fromRate = fromCurrency.first['exchange_rate'] as double;
      final toRate = toCurrency.first['exchange_rate'] as double;

      // Convert to base currency first, then to target currency
      final baseAmount = amount / fromRate;
      return baseAmount * toRate;
    } catch (error) {
      throw Exception('Failed to convert price: $error');
    }
  }

  // Get countries list (unique countries from locations)
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('locations')
          .select('country_code, country_name')
          .eq('status', 'active')
          .order('country_name');

      // Remove duplicates based on country_code
      final Map<String, Map<String, dynamic>> uniqueCountries = {};
      for (final location in response) {
        final countryCode = location['country_code'] as String;
        if (!uniqueCountries.containsKey(countryCode)) {
          uniqueCountries[countryCode] = {
            'country_code': countryCode,
            'country_name': location['country_name'],
          };
        }
      }

      return uniqueCountries.values.toList();
    } catch (error) {
      throw Exception('Failed to fetch countries: $error');
    }
  }
}
