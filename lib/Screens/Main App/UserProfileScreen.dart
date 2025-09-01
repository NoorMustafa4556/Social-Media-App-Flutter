import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Models/PostModel.dart';
import 'package:social_media_app/Models/UserModel.dart';
import 'package:social_media_app/Providers/UserProvider.dart';

import '../../Services/FireStoreServices.dart';
import '../Misc/ImageViewScreen.dart';
import 'FollowListScreen.dart';
import 'PostDetailScreen.dart';


class UserProfileScreen extends StatefulWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FireStoreService _fireStoreService = FireStoreService();
  UserModel? _user;
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDoc = await _fireStoreService.getUserDetails(widget.uid);
      if (userDoc != null && userDoc.exists) {
        _user = UserModel.fromSnap(userDoc);
      }
      final postsSnapshot = await _fireStoreService.getPostsForUser(widget.uid);
      _posts = postsSnapshot.docs.map((doc) => PostModel.fromSnap(doc)).toList();
    } catch (e) {
      print(e);
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null) return const Scaffold(body: Center(child: Text("User not found.")));

    final myUserProvider = context.watch<UserProvider>();
    final myUser = myUserProvider.user!;
    final bool isFollowing = myUser.following.contains(widget.uid);

    final publicPosts = _posts.where((p) => p.isPublic).toList();
    final privatePosts = _posts.where((p) => !p.isPublic).toList();
    final canSeePrivatePosts = isFollowing;
    final String heroTag = 'user-profile-pic-${_user!.uid}';
    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.username, style: const TextStyle(color: Colors.white)),
        backgroundColor: CupertinoColors.activeGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageViewScreen(
                                    imageUrl: _user!.profilePicUrl,
                                    heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: heroTag,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(_user!.profilePicUrl),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(_posts.length, "Posts"),
                                _buildStatColumn(_user!.followers.length, "Followers"),
                                _buildStatColumn(_user!.following.length, "Following"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(_user!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            myUserProvider.followUser(widget.uid);
                            setState(() {
                              if (isFollowing) _user!.followers.remove(myUser.uid);
                              else _user!.followers.add(myUser.uid);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? Colors.red : CupertinoColors.activeGreen,
                            foregroundColor: isFollowing ? Colors.white : Colors.white,
                          ),
                          child: Text(isFollowing ? "Unfollow" : "Follow"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Column(
            children: [
              const TabBar(
                indicatorColor: CupertinoColors.activeGreen,
                labelColor: Colors.black,
                tabs: [Tab(text: "Public"), Tab(text: "Private")],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPostsGrid(publicPosts),
                    canSeePrivatePosts
                        ? _buildPostsGrid(privatePosts)
                        : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Follow this user to see their private posts.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- YEH FUNCTION AB NAVIGATION HANDLE KAREGA ---
  Widget _buildStatColumn(int num, String label) {
    return GestureDetector(
      onTap: () {
        if (_user == null) return;

        List<String> userIds = [];
        FollowListType type;

        if (label == 'Followers') {
          userIds = _user!.followers.cast<String>();
          type = FollowListType.followers;
        } else if (label == 'Following') {
          userIds = _user!.following.cast<String>();
          type = FollowListType.following;
        } else {
          return; // 'Posts' par click ho to kuch na karo
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FollowListScreen(userIds: userIds, type: type),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(num.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  // Helper widget jo posts ka grid banata hai
  Widget _buildPostsGrid(List<PostModel> posts) {
    if (posts.isEmpty) return const Center(child: Text("No posts in this category."));
    return GridView.builder(
      padding: const EdgeInsets.all(2.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(post: post))),
          child: (post.postImageUrl != null && post.postImageUrl!.isNotEmpty)
              ? Image.network(post.postImageUrl!, fit: BoxFit.cover)
              : Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey.shade200,
              child: Center(child: Text(post.postText, overflow: TextOverflow.ellipsis, maxLines: 4))
          ),
        );
      },
    );
  }
}