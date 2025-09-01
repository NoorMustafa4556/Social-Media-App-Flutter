import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 // Nayi screen ko import karein

import 'CreatePostScreen.dart';
import 'FriendsScreen.dart';
import 'HomeFeed.dart';
import 'ProfileScreen.dart';
import 'SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Hamari main screens ki list (ab 4 pages honge)
  static const List<Widget> _pages = <Widget>[
    HomeFeed(),      // Index 0
    FriendsScreen(), // Index 1
    SearchScreen(),  // Index 2 (Naya page)
    ProfileScreen(), // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: CupertinoColors.activeGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Home Button
            _buildNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, index: 0),

            // Friends Button
            _buildNavItem(icon: Icons.people_outline, selectedIcon: Icons.people, index: 1),

            // FAB ke liye jaga
            const SizedBox(width: 40),

            // Search Button
            _buildNavItem(icon: Icons.search_outlined, selectedIcon: Icons.search, index: 2),

            // Profile Button
            _buildNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, index: 3),
          ],
        ),
      ),
    );
  }

  // Code ko saaf rakhne ke liye helper widget
  Widget _buildNavItem({required IconData icon, required IconData selectedIcon, required int index}) {
    return IconButton(
      icon: Icon(
        _selectedIndex == index ? selectedIcon : icon,
        color: _selectedIndex == index ? CupertinoColors.activeGreen : Colors.grey,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}