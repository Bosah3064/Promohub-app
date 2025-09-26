import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_header_widget.dart';
import './widgets/active_sessions_widget.dart';
import './widgets/currency_selection_widget.dart';
import './widgets/language_selection_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/toggle_settings_item_widget.dart';

class SettingsAndAccountManagement extends StatefulWidget {
  const SettingsAndAccountManagement({super.key});

  @override
  State<SettingsAndAccountManagement> createState() =>
      _SettingsAndAccountManagementState();
}

class _SettingsAndAccountManagementState
    extends State<SettingsAndAccountManagement> {
  // User profile mock data
  final Map<String, dynamic> userProfile = {
    "name": "Amara Okafor",
    "email": "amara.okafor@promohub.com",
    "phone": "+234 803 123 4567",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "verificationStatus": "Verified Seller",
    "memberSince": "January 2023",
    "totalListings": 47,
    "successfulSales": 32,
  };

  // Notification preferences
  bool _newMessagesNotification = true;
  bool _priceDropsNotification = true;
  bool _listingMatchesNotification = false;
  bool _promotionalOffersNotification = true;
  bool _securityAlertsNotification = true;

  // Privacy settings
  bool _profileVisibility = true;
  bool _contactInfoDisplay = false;
  bool _locationSharingPrecision = true;
  bool _dataUsagePreferences = false;

  // App preferences
  bool _darkModeToggle = false;
  String _selectedLanguage = "en";
  String _selectedCurrency = "NGN";
  String _measurementUnits = "metric";

  // Security settings
  bool _twoFactorAuthentication = false;
  bool _biometricLogin = true;

  // Active sessions mock data
  final List<Map<String, dynamic>> activeSessions = [
    {
      "sessionId": "session_001",
      "deviceName": "iPhone 14 Pro",
      "deviceType": "mobile",
      "location": "Lagos, Nigeria",
      "browser": "PromoHub iOS App",
      "lastActive": "2 minutes ago",
      "isCurrent": true,
    },
    {
      "sessionId": "session_002",
      "deviceName": "MacBook Pro",
      "deviceType": "desktop",
      "location": "Abuja, Nigeria",
      "browser": "Safari 17.0",
      "lastActive": "3 hours ago",
      "isCurrent": false,
    },
    {
      "sessionId": "session_003",
      "deviceName": "Samsung Galaxy S23",
      "deviceType": "mobile",
      "location": "Kano, Nigeria",
      "browser": "PromoHub Android App",
      "lastActive": "1 day ago",
      "isCurrent": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showHelpDialog(context),
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 1.h),

            // Account Header
            AccountHeaderWidget(userProfile: userProfile),

            SizedBox(height: 2.h),

            // Account Section
            SettingsSectionWidget(
              title: "Account",
              children: [
                SettingsItemWidget(
                  title: "Edit Profile",
                  subtitle: "Update your personal information",
                  iconName: 'person',
                  onTap: () => _navigateToEditProfile(),
                ),
                SettingsItemWidget(
                  title: "Change Password",
                  subtitle: "Update your account password",
                  iconName: 'lock',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                SettingsItemWidget(
                  title: "Phone & Email Verification",
                  subtitle: "Verify your contact information",
                  iconName: 'verified_user',
                  onTap: () => _navigateToVerification(),
                ),
                SettingsItemWidget(
                  title: "Delete Account",
                  subtitle: "Permanently delete your account",
                  iconName: 'delete_forever',
                  onTap: () => _showDeleteAccountDialog(context),
                  showDivider: false,
                ),
              ],
            ),

            // Notifications Section
            SettingsSectionWidget(
              title: "Notifications",
              children: [
                ToggleSettingsItemWidget(
                  title: "New Messages",
                  subtitle: "Get notified about new chat messages",
                  iconName: 'message',
                  value: _newMessagesNotification,
                  onChanged: (value) =>
                      setState(() => _newMessagesNotification = value),
                ),
                ToggleSettingsItemWidget(
                  title: "Price Drops",
                  subtitle: "Alerts for price reductions on saved items",
                  iconName: 'trending_down',
                  value: _priceDropsNotification,
                  onChanged: (value) =>
                      setState(() => _priceDropsNotification = value),
                ),
                ToggleSettingsItemWidget(
                  title: "Listing Matches",
                  subtitle: "Notifications for items matching your searches",
                  iconName: 'search',
                  value: _listingMatchesNotification,
                  onChanged: (value) =>
                      setState(() => _listingMatchesNotification = value),
                ),
                ToggleSettingsItemWidget(
                  title: "Promotional Offers",
                  subtitle: "Special deals and marketplace promotions",
                  iconName: 'local_offer',
                  value: _promotionalOffersNotification,
                  onChanged: (value) =>
                      setState(() => _promotionalOffersNotification = value),
                ),
                ToggleSettingsItemWidget(
                  title: "Security Alerts",
                  subtitle: "Important account security notifications",
                  iconName: 'security',
                  value: _securityAlertsNotification,
                  onChanged: (value) =>
                      setState(() => _securityAlertsNotification = value),
                  showDivider: false,
                ),
              ],
            ),

            // Privacy Section
            SettingsSectionWidget(
              title: "Privacy",
              children: [
                ToggleSettingsItemWidget(
                  title: "Profile Visibility",
                  subtitle: "Make your profile visible to other users",
                  iconName: 'visibility',
                  value: _profileVisibility,
                  onChanged: (value) =>
                      setState(() => _profileVisibility = value),
                ),
                ToggleSettingsItemWidget(
                  title: "Contact Information Display",
                  subtitle: "Show contact details on your listings",
                  iconName: 'contact_phone',
                  value: _contactInfoDisplay,
                  onChanged: (value) =>
                      setState(() => _contactInfoDisplay = value),
                ),
                ToggleSettingsItemWidget(
                  title: "Location Sharing Precision",
                  subtitle: "Share precise location for nearby searches",
                  iconName: 'location_on',
                  value: _locationSharingPrecision,
                  onChanged: (value) =>
                      setState(() => _locationSharingPrecision = value),
                ),
                ToggleSettingsItemWidget(
                  title: "Data Usage Preferences",
                  subtitle: "Allow data collection for app improvement",
                  iconName: 'analytics',
                  value: _dataUsagePreferences,
                  onChanged: (value) =>
                      setState(() => _dataUsagePreferences = value),
                  showDivider: false,
                ),
              ],
            ),

            // App Preferences Section
            SettingsSectionWidget(
              title: "App Preferences",
              children: [
                SettingsItemWidget(
                  title: "Language",
                  subtitle: _getLanguageName(_selectedLanguage),
                  iconName: 'language',
                  onTap: () => _showLanguageSelection(context),
                ),
                SettingsItemWidget(
                  title: "Currency",
                  subtitle: _getCurrencyName(_selectedCurrency),
                  iconName: 'attach_money',
                  onTap: () => _showCurrencySelection(context),
                ),
                ToggleSettingsItemWidget(
                  title: "Dark Mode",
                  subtitle: "Switch to dark theme",
                  iconName: 'dark_mode',
                  value: _darkModeToggle,
                  onChanged: (value) => setState(() => _darkModeToggle = value),
                ),
                SettingsItemWidget(
                  title: "Measurement Units",
                  subtitle: _measurementUnits == "metric"
                      ? "Metric (km, kg)"
                      : "Imperial (mi, lb)",
                  iconName: 'straighten',
                  onTap: () => _showMeasurementUnitsDialog(context),
                  showDivider: false,
                ),
              ],
            ),

            // Security Section
            SettingsSectionWidget(
              title: "Security",
              children: [
                Container(
                  child: ActiveSessionsWidget(
                    activeSessions: activeSessions,
                    onTerminateSession: _terminateSession,
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 15.w,
                  color: AppTheme.lightTheme.dividerColor,
                ),
                ToggleSettingsItemWidget(
                  title: "Two-Factor Authentication",
                  subtitle: "Add extra security to your account",
                  iconName: 'security',
                  value: _twoFactorAuthentication,
                  onChanged: (value) =>
                      setState(() => _twoFactorAuthentication = value),
                ),
                ToggleSettingsItemWidget(
                  title: "Biometric Login",
                  subtitle: "Use fingerprint or face recognition",
                  iconName: 'fingerprint',
                  value: _biometricLogin,
                  onChanged: (value) => setState(() => _biometricLogin = value),
                ),
                SettingsItemWidget(
                  title: "Privacy Policy",
                  subtitle: "Read our privacy policy",
                  iconName: 'privacy_tip',
                  onTap: () => _navigateToPrivacyPolicy(),
                  showDivider: false,
                ),
              ],
            ),

            // Support Section
            SettingsSectionWidget(
              title: "Support",
              children: [
                SettingsItemWidget(
                  title: "Help Center",
                  subtitle: "Browse frequently asked questions",
                  iconName: 'help_center',
                  onTap: () => _navigateToHelpCenter(),
                ),
                SettingsItemWidget(
                  title: "Live Chat",
                  subtitle: "Chat with our support team",
                  iconName: 'chat',
                  onTap: () => _initiateLiveChat(),
                ),
                SettingsItemWidget(
                  title: "Submit Feedback",
                  subtitle: "Help us improve PromoHub",
                  iconName: 'feedback',
                  onTap: () => _showFeedbackDialog(context),
                ),
                SettingsItemWidget(
                  title: "FAQ",
                  subtitle: "Common questions and answers",
                  iconName: 'quiz',
                  onTap: () => _navigateToFAQ(),
                  showDivider: false,
                ),
              ],
            ),

            // About Section
            SettingsSectionWidget(
              title: "About",
              children: [
                SettingsItemWidget(
                  title: "App Version",
                  subtitle: "PromoHub v2.1.4 (Build 2024.07.29)",
                  iconName: 'info',
                  onTap: () => _showVersionInfo(context),
                ),
                SettingsItemWidget(
                  title: "Terms of Service",
                  subtitle: "Read our terms and conditions",
                  iconName: 'description',
                  onTap: () => _navigateToTermsOfService(),
                ),
                SettingsItemWidget(
                  title: "Legal Information",
                  subtitle: "Licenses and legal notices",
                  iconName: 'gavel',
                  onTap: () => _navigateToLegalInfo(),
                ),
                SettingsItemWidget(
                  title: "Export Data",
                  subtitle: "Download your account information",
                  iconName: 'download',
                  onTap: () => _showExportDataDialog(context),
                ),
                SettingsItemWidget(
                  title: "Reset to Defaults",
                  subtitle: "Restore original app settings",
                  iconName: 'restore',
                  onTap: () => _showResetDefaultsDialog(context),
                  showDivider: false,
                ),
              ],
            ),

            // Logout Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  foregroundColor: AppTheme.lightTheme.colorScheme.onError,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'logout',
                      color: AppTheme.lightTheme.colorScheme.onError,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "Logout",
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case "en":
        return "English";
      case "sw":
        return "Kiswahili";
      case "ha":
        return "Hausa";
      default:
        return "English";
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case "NGN":
        return "Nigerian Naira (₦)";
      case "KES":
        return "Kenyan Shilling (KSh)";
      case "GHS":
        return "Ghanaian Cedi (₵)";
      case "USD":
        return "US Dollar (\$)";
      case "EUR":
        return "Euro (€)";
      default:
        return "Nigerian Naira (₦)";
    }
  }

  void _navigateToEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Edit Profile feature coming soon!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Verification feature coming soon!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Privacy Policy feature coming soon!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Help Center feature coming soon!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToFAQ() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("FAQ feature coming soon!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Terms of Service feature coming soon!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToLegalInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Legal Information feature coming soon!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _initiateLiveChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Live Chat feature coming soon!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _terminateSession(String sessionId) {
    setState(() {
      activeSessions
          .removeWhere((session) => session["sessionId"] == sessionId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Session terminated successfully"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Text(
                "Select Language",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: LanguageSelectionWidget(
                currentLanguage: _selectedLanguage,
                onLanguageChanged: (language) {
                  setState(() => _selectedLanguage = language);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Language changed to ${_getLanguageName(language)}"),
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Text(
                "Select Currency",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: CurrencySelectionWidget(
                currentCurrency: _selectedCurrency,
                onCurrencyChanged: (currency) {
                  setState(() => _selectedCurrency = currency);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Currency changed to ${_getCurrencyName(currency)}"),
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Change Password",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                prefixIcon: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                prefixIcon: CustomIconWidget(
                  iconName: 'lock_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                prefixIcon: CustomIconWidget(
                  iconName: 'lock_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Password changed successfully!"),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            },
            child: Text("Change Password"),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Account",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This action cannot be undone. All your data will be permanently deleted:",
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text("• All your listings and messages",
                style: AppTheme.lightTheme.textTheme.bodySmall),
            Text("• Your profile and reviews",
                style: AppTheme.lightTheme.textTheme.bodySmall),
            Text("• Transaction history",
                style: AppTheme.lightTheme.textTheme.bodySmall),
            Text("• Saved items and searches",
                style: AppTheme.lightTheme.textTheme.bodySmall),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                labelText: "Type 'DELETE' to confirm",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Account deletion initiated. Check your email for confirmation."),
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text("Delete Account"),
          ),
        ],
      ),
    );
  }

  void _showMeasurementUnitsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Measurement Units"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text("Metric (km, kg, °C)"),
              value: "metric",
              groupValue: _measurementUnits,
              onChanged: (value) {
                setState(() => _measurementUnits = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text("Imperial (mi, lb, °F)"),
              value: "imperial",
              groupValue: _measurementUnits,
              onChanged: (value) {
                setState(() => _measurementUnits = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Need Help?"),
        content: Text(
            "Contact our support team at support@promohub.com or use the live chat feature for immediate assistance."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("PromoHub"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Version: 2.1.4"),
            Text("Build: 2024.07.29"),
            Text("Platform: Flutter 3.16.0"),
            SizedBox(height: 2.h),
            Text("© 2024 PromoHub. All rights reserved."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Submit Feedback"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Your feedback",
                hintText: "Tell us what you think about PromoHub...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                Expanded(
                  child: Text(
                    "Include app diagnostics",
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Thank you for your feedback!"),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Export Data"),
        content: Text(
            "We'll prepare your data and send a download link to your email address within 24 hours."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text("Data export request submitted. Check your email."),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            },
            child: Text("Export"),
          ),
        ],
      ),
    );
  }

  void _showResetDefaultsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reset to Defaults"),
        content: Text(
            "This will restore all app settings to their original values. Your account data will not be affected."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _newMessagesNotification = true;
                _priceDropsNotification = true;
                _listingMatchesNotification = false;
                _promotionalOffersNotification = true;
                _securityAlertsNotification = true;
                _profileVisibility = true;
                _contactInfoDisplay = false;
                _locationSharingPrecision = true;
                _dataUsagePreferences = false;
                _darkModeToggle = false;
                _selectedLanguage = "en";
                _selectedCurrency = "NGN";
                _measurementUnits = "metric";
                _twoFactorAuthentication = false;
                _biometricLogin = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Settings reset to defaults"),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            },
            child: Text("Reset"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout from PromoHub?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login-screen', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
