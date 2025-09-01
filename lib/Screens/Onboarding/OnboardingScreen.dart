import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/Screens/Auth/LoginScreen.dart';
import 'package:social_media_app/Widgets/OnboardingClipper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {'image': 'assets/images/Onboarding.jpg', 'title': "Let's connect\nwith each other", 'description': 'Find your friends and make new ones. Share your life moments with a community that cares.'},
    {'image': 'assets/images/Onboarding.jpg', 'title': 'Share Your World', 'description': 'Post your moments and choose who gets to see them with our privacy settings.'},
    {'image': 'assets/images/Onboarding.jpg', 'title': 'Discover & Follow', 'description': 'Follow interesting creators and find content that inspires you.'},
  ];

  void _onGetStarted() async {
    // ---- YEH AHEM HISSA HAI ----
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      print("[ONBOARDING] 'hasSeenOnboarding' set to true.");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print("Error saving onboarding status: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ... baaki ka UI ka code wese hi rahega jese pehle tha ...
  // Main sirf build method ka structure de raha hoon taake aapko yaqeen ho jaye
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: screenHeight * 0.6,
            child: Image.asset('assets/images/Onboarding.jpg', fit: BoxFit.cover),
          ),
          Positioned(
            top: screenHeight * 0.53, left: 0, right: 0, bottom: 0,
            child: ClipPath(
              clipper: OnboardingClipper(),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (int page) { setState(() { _currentPage = page; }); },
                        itemBuilder: (context, index) {
                          return OnboardingPageContent(title: _pages[index]['title']!, description: _pages[index]['description']!);
                        },
                      ),
                    ),
                    // ... Baaki ka UI (dots, button) wese hi ...
                    // Get Started Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              _onGetStarted(); // <-- YEH FUNCTION CALL HOGA
                            } else {
                              _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                            }
                          },
                          // ... button ki styling ...
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CupertinoColors.activeGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final String title, description;
  const OnboardingPageContent({super.key, required this.title, required this.description});
  // ... iska UI wese hi ...
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 20),
          Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}