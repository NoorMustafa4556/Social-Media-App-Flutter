import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/Providers/AuthProvider.dart';
import 'package:social_media_app/Providers/UserProvider.dart';
import 'package:social_media_app/Screens/Auth/LoginScreen.dart';

import 'package:social_media_app/Screens/Onboarding/OnboardingScreen.dart';

import '../Main App/HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      print("[SPLASH] Timer finished. Checking status...");
      _checkStatusAndNavigate();
    });
  }

  void _checkStatusAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (mounted) {
      if (!hasSeenOnboarding) {
        print("[SPLASH] Onboarding not seen. Navigating to OnboardingScreen.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        if (authProvider.user != null) {
          print("[SPLASH] User is logged in. UID: ${authProvider.user!.uid}");
          print("[SPLASH] Refreshing user data...");

          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.refreshUser(authProvider.user!);

          print("[SPLASH] User data refreshed. Navigating to HomeScreen.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          print("[SPLASH] User is not logged in. Navigating to LoginScreen.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: CupertinoColors.activeGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_work, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text('Social App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 40),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ],
        ),
      ),
    );
  }
}