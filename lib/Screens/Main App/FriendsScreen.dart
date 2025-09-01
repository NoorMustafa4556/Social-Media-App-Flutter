import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Models/UserModel.dart';
import 'package:social_media_app/Providers/UserProvider.dart';


import '../../Services/FireStoreServices.dart';
import 'UserProfileScreen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // Yeh FutureBuilder ko data provide karega
  late Future<List<UserModel>> _followingFuture;
  final FireStoreService _fireStoreService = FireStoreService();

  @override
  void initState() {
    super.initState();
    // initState main hi data fetch karne ka process shuru kar dein
    _loadFollowingUsers();
  }

  void _loadFollowingUsers() {
    // Provider se apni following list get karein
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final followingIds = userProvider.user?.following.cast<String>() ?? [];

    // FireStoreService ko call karke un IDs ke against user details fetch karein
    _followingFuture = _fireStoreService.getUsersFromList(followingIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Following', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: CupertinoColors.activeGreen,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _followingFuture,
        builder: (context, snapshot) {
          // Jab tak data load ho raha hai, loader dikhayein
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Agar koi error aa jaye ya list khali ho
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'You are not following anyone yet.\nExplore and connect with others!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            );
          }

          // Agar data successfully load ho jaye
          final followingUsers = snapshot.data!;

          return ListView.builder(
            itemCount: followingUsers.length,
            itemBuilder: (context, index) {
              final user = followingUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(user.profilePicUrl),
                ),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('@${user.username}'),
                onTap: () {
                  // User ke naam par click karne se uski profile par navigate karein
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfileScreen(uid: user.uid)),
                  );
                },
                // Yahan aap aik 'Unfollow' button bhi add kar sakte hain
              );
            },
          );
        },
      ),
    );
  }
}