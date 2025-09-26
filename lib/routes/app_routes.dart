import 'package:flutter/material.dart';

import '../presentation/create_listing/create_listing.dart';
import '../presentation/favorites_and_saved_items/favorites_and_saved_items.dart';
import '../presentation/listing_detail/listing_detail.dart';
import '../presentation/location_currency_settings/location_currency_settings.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/marketplace_home/marketplace_home.dart';
import '../presentation/messages_and_chat/messages_and_chat.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/search_and_filters/search_and_filters.dart';
import '../presentation/settings_and_account_management/settings_and_account_management.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/subscription_management/subscription_management.dart';
import '../presentation/user_profile/user_profile.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String onboardingFlow = '/onboarding-flow';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String marketplaceHome = '/marketplace-home';
  static const String listingDetail = '/listing-detail';
  static const String messagesAndChat = '/messages-and-chat';
  static const String userProfile = '/user-profile';
  static const String createListing = '/create-listing';
  static const String searchAndFilters = '/search-and-filters';
  static const String favoritesAndSavedItems = '/favorites-and-saved-items';
  static const String settingsAndAccountManagement =
      '/settings-and-account-management';
  static const String subscriptionManagement = '/subscription-management';
  static const String locationCurrencySettings = '/location-currency-settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    registrationScreen: (context) => const RegistrationScreen(),
    marketplaceHome: (context) => MarketplaceHome(),
    listingDetail: (context) => const ListingDetail(),
    messagesAndChat: (context) => const MessagesAndChat(),
    userProfile: (context) => const UserProfile(),
    createListing: (context) => const CreateListing(),
    searchAndFilters: (context) => const SearchAndFilters(),
    favoritesAndSavedItems: (context) => const FavoritesAndSavedItems(),
    settingsAndAccountManagement: (context) =>
        const SettingsAndAccountManagement(),
    subscriptionManagement: (context) => const SubscriptionManagement(),
    locationCurrencySettings: (context) => const LocationCurrencySettings(),
    // TODO: Add your other routes here
  };
}
