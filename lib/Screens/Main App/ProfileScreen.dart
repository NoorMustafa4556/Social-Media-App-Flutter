import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Models/PostModel.dart';
import 'package:social_media_app/Providers/AuthProvider.dart';
import 'package:social_media_app/Providers/PostProvider.dart';
import 'package:social_media_app/Providers/ThemeProvider.dart'; // ThemeProvider ke liye import
import 'package:social_media_app/Providers/UserProvider.dart';
import 'package:social_media_app/Screens/Splash/SplashScreen.dart';


import 'EditProfileScreen.dart';
import 'FollowListScreen.dart';
import 'PostDetailScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      Provider.of<PostProvider>(context, listen: false).fetchPostsForUser(authProvider.user!.uid);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- NAYA HELPER FUNCTION YAHAN HAI: Theme Selection Dialog ---
  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light Mode'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setTheme(value);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Mode'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setTheme(value);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setTheme(value);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: CupertinoColors.activeGreen,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'settings') {
                _showThemeDialog(context); // Naya function yahan call hoga
              } else if (value == 'logout') {
                await Provider.of<AuthProvider>(context, listen: false).signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false,
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'settings', child: Text('Settings')),
              const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: NestedScrollView(
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
                        CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.profilePicUrl)),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(context.watch<PostProvider>().userPosts.length, "Posts"),
                              _buildStatColumn(user.followers.length, "Followers"),
                              _buildStatColumn(user.following.length, "Following"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: CupertinoColors.activeGreen, width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(color: CupertinoColors.activeGreen, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
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
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).textTheme.bodyLarge?.color,
              unselectedLabelColor: Colors.grey,
              indicatorColor: CupertinoColors.activeGreen,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on), text: "Public"),
                Tab(icon: Icon(Icons.lock_outline), text: "Private"),
              ],
            ),
            Expanded(
              child: Consumer<PostProvider>(
                builder: (context, postProvider, child) {
                  if (postProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final publicPosts = postProvider.userPosts.where((p) => p.isPublic).toList();
                  final privatePosts = postProvider.userPosts.where((p) => !p.isPublic).toList();
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostsGrid(publicPosts),
                      _buildPostsGrid(privatePosts),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(int num, String label) {
    return GestureDetector(
      onTap: () {
        final user = context.read<UserProvider>().user;
        if (user == null) return;
        List<String> userIds = [];
        FollowListType type;
        if (label == 'Followers') {
          userIds = user.followers.cast<String>();
          type = FollowListType.followers;
        } else if (label == 'Following') {
          userIds = user.following.cast<String>();
          type = FollowListType.following;
        } else {
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => FollowListScreen(userIds: userIds, type: type)));
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

  Widget _buildPostsGrid(List<PostModel> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text("No posts in this category."));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)));
          },
          child: Container(
            color: Theme.of(context).cardColor,
            child: (post.postImageUrl != null && post.postImageUrl!.isNotEmpty)
                ? Image.network(post.postImageUrl!, fit: BoxFit.cover)
                : Container(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  post.postText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}