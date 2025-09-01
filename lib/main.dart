import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Providers/AuthProvider.dart';
import 'package:social_media_app/Providers/PostProvider.dart';
import 'package:social_media_app/Providers/ThemeProvider.dart';
import 'package:social_media_app/Providers/UserProvider.dart';
import 'package:social_media_app/Screens/Splash/SplashScreen.dart';
import 'package:social_media_app/firebase_options.dart';

void main() async {
  // Step 1: Ensure that Flutter framework bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Initialize Firebase for your app.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Step 3: Run the application.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider makes all your providers available to the entire widget tree.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Your new theme provider
      ],
      // Consumer listens to changes in the ThemeProvider.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {

          // --- THEME DEFINITIONS ---
          final Color primaryColor = CupertinoColors.activeGreen;

          // Light Theme Configuration
          final lightTheme = ThemeData(
            brightness: Brightness.light,
            primaryColor: primaryColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Off-white background
            appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white, // Title and icons color
            ),
            cardColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          );

          // Dark Theme Configuration
          final darkTheme = ThemeData(
            brightness: Brightness.dark,
            primaryColor: primaryColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212), // Standard dark grey
            appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            cardColor: const Color(0xFF1E1E1E), // Slightly lighter grey for cards
            visualDensity: VisualDensity.adaptivePlatformDensity,
          );
          // --- END OF THEME DEFINITIONS ---

          return MaterialApp(
            title: 'Social Media App',
            debugShowCheckedModeBanner: false,

            // Apply the themes based on the provider's state
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}