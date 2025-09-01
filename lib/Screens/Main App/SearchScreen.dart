import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/Models/UserModel.dart';

import '../../Services/FireStoreServices.dart';
import 'UserProfileScreen.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FireStoreService _fireStoreService = FireStoreService();
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  // _hasSearched ki ab zaroorat nahi kyunke search foran shuru ho jayegi

  // --- NAYA FUNCTION JO LIVE SEARCH HANDLE KAREGA ---
  void _onSearchChanged(String query) async {
    // Agar user search box ko khali kar de
    if (query.trim().isEmpty) {
      // To results ko bhi foran khali kardo
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
      return;
    }

    // Loader dikhayein
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Firestore se results fetch karein
    final results = await _fireStoreService.searchUsers(query.trim());

    // Agar widget abhi bhi screen par hai, to state update karein
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false, // Agar yeh alag tab hai to back button nahi chahiye
        backgroundColor: CupertinoColors.activeGreen,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search for users...',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            // Search box khali karne ke liye 'X' ka button
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                // Clear karne par search ko bhi clear kardo
                _onSearchChanged('');
              },
            )
                : null,
          ),
          // --- ASAL CHANGE YAHAN HAI ---
          // onSubmitted ki jagah onChanged use karein
          onChanged: _onSearchChanged,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Agar search box khali hai aur koi search nahi ho rahi
    if (_searchController.text.trim().isEmpty) {
      return const Center(child: Text('Search for users by their username.', style: TextStyle(color: Colors.grey)));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Agar search ho chuki hai lekin koi result nahi mila
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No users found.', style: TextStyle(color: Colors.grey)));
    }

    // Results ko list main dikhayein
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(user.profilePicUrl)),
          title: Text(user.name),
          subtitle: Text('@${user.username}'),
          onTap: () {
            // Keyboard ko hide karo doosri screen par jane se pehle
            FocusScope.of(context).unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfileScreen(uid: user.uid)),
            );
          },
        );
      },
    );
  }
}