import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Providers/PostProvider.dart';
import 'package:social_media_app/Widgets/PostCard.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchPublicPosts();
    });
  }

  Future<void> _refreshPosts() async {
    await Provider.of<PostProvider>(context, listen: false).fetchPublicPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Social App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: CupertinoColors.activeGreen,
        actions: [

        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading && postProvider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postProvider.errorMessage != null) {
            return Center(child: Text('Error: ${postProvider.errorMessage}'));
          }

          if (postProvider.posts.isEmpty) {
            return const Center(
              child: Text(
                'No posts yet. Be the first one to post!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshPosts,
            child: ListView.builder(
              itemCount: postProvider.posts.length,
              itemBuilder: (context, index) {
                final post = postProvider.posts[index];
                return PostCard(post: post);
              },
            ),
          );
        },
      ),
    );
  }
}