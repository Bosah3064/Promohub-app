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
import '../presentation/seller_registration/seller_registration_screen.dart';
import '../presentation/shop_profile/shop_profile_screen.dart';
import '../presentation/cart/cart_screen.dart';
import '../presentation/checkout/checkout_screen.dart';
import '../presentation/seller_dashboard/seller_dashboard_screen.dart';
import '../presentation/seller_orders/seller_orders_screen.dart';
import '../presentation/seller_orders/seller_order_detail_screen.dart';
import '../presentation/order_tracking/order_tracking_screen.dart';
import '../presentation/forgot_password_screen/forgot_password_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String forgotPassword = '/forgot-password';
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
  static const String settingsAndAccountManagement = '/settings-and-account-management';
  static const String subscriptionManagement = '/subscription-management';
  static const String locationCurrencySettings = '/location-currency-settings';
  static const String sellerRegistration = '/seller-registration';
  static const String shopProfile = '/shop-profile';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String sellerDashboard = '/seller-dashboard';
  static const String sellerOrders = '/seller-orders';
  static const String sellerOrderDetail = '/seller-order-detail';
  static const String orderTracking = '/order-tracking';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
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
    settingsAndAccountManagement: (context) => const SettingsAndAccountManagement(),
    subscriptionManagement: (context) => const SubscriptionManagement(),
    locationCurrencySettings: (context) => const LocationCurrencySettings(),
    sellerRegistration: (context) => const SellerRegistrationScreen(),
    shopProfile: (context) {
      final shopId = ModalRoute.of(context)?.settings.arguments as String? ?? 'default';
      return ShopProfileScreen(shopId: shopId);
    },
    cart: (context) => const CartScreen(),
    checkout: (context) => const CheckoutScreen(),
    sellerDashboard: (context) {
      final shopId = ModalRoute.of(context)?.settings.arguments as String? ?? 'default';
      return SellerDashboardScreen(shopId: shopId);
    },
    sellerOrders: (context) {
      final shopId = ModalRoute.of(context)?.settings.arguments as String? ?? 'default';
      return SellerOrdersScreen(shopId: shopId);
    },
    sellerOrderDetail: (context) {
      final order = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      return SellerOrderDetailScreen(order: order);
    },
    orderTracking: (context) {
      final orderId = ModalRoute.of(context)?.settings.arguments as String? ?? 'default_order';
      return OrderTrackingScreen(orderId: orderId);
    },
  };
}
