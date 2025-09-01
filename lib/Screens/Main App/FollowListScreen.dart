import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/Models/UserModel.dart';


import '../../Services/FireStoreServices.dart';
import 'UserProfileScreen.dart';

enum FollowListType { followers, following }

class FollowListScreen extends StatefulWidget {
  final List<String> userIds;
  final FollowListType type;

  const FollowListScreen({super.key, required this.userIds, required this.type});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  final FireStoreService _fireStoreService = FireStoreService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fireStoreService.getUsersFromList(widget.userIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == FollowListType.followers ? 'Followers' : 'Following',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: CupertinoColors.activeGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                    'No users to display.',
                    style: TextStyle(color: Colors.grey.shade600)
                )
            );
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePicUrl),
                ),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('@${user.username}'),
                onTap: () {
                  // User ki profile par navigate karo
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfileScreen(uid: user.uid)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}