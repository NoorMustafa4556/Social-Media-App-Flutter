import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Models/PostModel.dart';
import 'package:social_media_app/Providers/AuthProvider.dart';
import 'package:social_media_app/Providers/PostProvider.dart';
 // Yeh screen aage banayenge
import 'package:social_media_app/Widgets/PostCard.dart';

import 'EditPostScreen.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isMyPost = authProvider.user!.uid == post.authorId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post', style: TextStyle(color: Colors.white)),
        backgroundColor: CupertinoColors.activeGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        // Sirf author ko 3-dot menu dikhao
        actions: [
          if (isMyPost)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // Edit Post Screen par jao
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(post: post)));
                } else if (value == 'delete') {
                  // Delete ka confirmation dialog dikhao
                  _showDeleteConfirmation(context, post.postId);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      // Humne jo PostCard pehle banaya tha, usko yahan reuse kar sakte hain
      body: SingleChildScrollView(
        child: PostCard(post: post),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to permanently delete this post?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Dialog band karo
              await Provider.of<PostProvider>(context, listen: false).deletePost(postId);
              if (context.mounted) {
                Navigator.of(context).pop(); // PostDetailScreen se wapis jao
              }
            },
          ),
        ],
      ),
    );
  }
}