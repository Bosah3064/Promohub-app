import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this for environment variables

import './core/app_export.dart';
import './services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with better error handling
  try {
    await SupabaseService().client; // Ensure client is initialized
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
    // Consider showing an error screen or retry mechanism in production
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          title: 'PromoHub',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme, // Add if you have dark theme
          themeMode: ThemeMode.system, // Or ThemeMode.light/dark
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splashScreen,
          routes: AppRoutes.routes,
          // Add error handler for better debugging
          onGenerateRoute: (settings) {
            debugPrint('Route not found: ${settings.name}');
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('Route ${settings.name} not found'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
