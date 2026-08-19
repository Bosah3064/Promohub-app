import 'package:cloud_firestore/cloud_firestore.dart';
import './firebase_service.dart';

class LocationCurrencyService {
  final FirebaseService _firebaseService = FirebaseService();
  FirebaseFirestore get _firestore => _firebaseService.firestore;

  Future<List<Map<String, dynamic>>> getAllCountries() async {
    return getCountries();
  }

  Future<List<Map<String, dynamic>>> getAllCurrencies() async {
    return getCurrencies();
  }

  // Fetch all active currencies
  Future<List<Map<String, dynamic>>> getCurrencies() async {
    try {
      final snapshot = await _firestore
          .collection('currencies')
          .where('status', isEqualTo: 'active')
          .orderBy('code')
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (error) {
      throw Exception('Failed to fetch currencies: $error');
    }
  }

  // Fetch all active locations
  Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      final snapshot = await _firestore
          .collection('locations')
          .where('status', isEqualTo: 'active')
          .orderBy('country_name')
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (error) {
      throw Exception('Failed to fetch locations: $error');
    }
  }

  // Get locations by country
  Future<List<Map<String, dynamic>>> getLocationsByCountry(
      String countryCode) async {
    try {
      final snapshot = await _firestore
          .collection('locations')
          .where('country_code', isEqualTo: countryCode)
          .where('status', isEqualTo: 'active')
          .orderBy('city_name')
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (error) {
      throw Exception('Failed to fetch locations by country: $error');
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_preferences')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      var prefs = {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};

      if (prefs['preferred_currency_id'] != null) {
        final currencyDoc = await _firestore.collection('currencies').doc(prefs['preferred_currency_id']).get();
        if (currencyDoc.exists) {
          prefs['preferred_currency_id'] = {'id': currencyDoc.id, ...?currencyDoc.data()};
        }
      }

      if (prefs['preferred_location_id'] != null) {
        final locationDoc = await _firestore.collection('locations').doc(prefs['preferred_location_id']).get();
        if (locationDoc.exists) {
          prefs['preferred_location_id'] = {'id': locationDoc.id, ...?locationDoc.data()};
        }
      }

      return prefs;
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

      updates['updated_at'] = FieldValue.serverTimestamp();

      final snapshot = await _firestore
          .collection('user_preferences')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update(updates);
        final doc = await snapshot.docs.first.reference.get();
        return {'id': doc.id, ...?doc.data()};
      } else {
        updates['user_id'] = userId;
        updates['created_at'] = FieldValue.serverTimestamp();
        final docRef = await _firestore.collection('user_preferences').add(updates);
        return {'id': docRef.id, ...updates};
      }
    } catch (error) {
      throw Exception('Failed to update user preferences: $error');
    }
  }

  // Get base currency
  Future<Map<String, dynamic>?> getBaseCurrency() async {
    try {
      final snapshot = await _firestore
          .collection('currencies')
          .where('is_base', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
          
      if (snapshot.docs.isNotEmpty) {
        return {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};
      }
      return null;
    } catch (error) {
      throw Exception('Failed to fetch base currency: $error');
    }
  }

  // Convert price between currencies
  Future<double> convertPrice(
      double amount, String fromCurrencyId, String toCurrencyId) async {
    try {
      if (fromCurrencyId == toCurrencyId) return amount;

      final fromDoc = await _firestore.collection('currencies').doc(fromCurrencyId).get();
      final toDoc = await _firestore.collection('currencies').doc(toCurrencyId).get();

      if (!fromDoc.exists || !toDoc.exists) {
        throw Exception('Currency not found');
      }

      final fromRate = (fromDoc.data()!['exchange_rate'] as num).toDouble();
      final toRate = (toDoc.data()!['exchange_rate'] as num).toDouble();

      final baseAmount = amount / fromRate;
      return baseAmount * toRate;
    } catch (error) {
      throw Exception('Failed to convert price: $error');
    }
  }

  // Get countries list
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final snapshot = await _firestore
          .collection('locations')
          .where('status', isEqualTo: 'active')
          .orderBy('country_name')
          .get();

      final Map<String, Map<String, dynamic>> uniqueCountries = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final countryCode = data['country_code'] as String;
        if (!uniqueCountries.containsKey(countryCode)) {
          uniqueCountries[countryCode] = {
            'country_code': countryCode,
            'country_name': data['country_name'],
          };
        }
      }

      return uniqueCountries.values.toList();
    } catch (error) {
      throw Exception('Failed to fetch countries: $error');
    }
  }
}
