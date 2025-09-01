import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Models/PostModel.dart';
import 'package:social_media_app/Models/UserModel.dart';
import 'package:social_media_app/Providers/PostProvider.dart';
import 'package:social_media_app/Providers/UserProvider.dart';

import '../Screens/Main App/CommentsScreen.dart';
import '../Screens/Main App/EditPostScreen.dart';
import '../Screens/Main App/UserProfileScreen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final myUser = context.watch<UserProvider>().user!;

    // Check karo ke post original hai ya re-shared, aur uske hisab se UI dikhao
    if (post.isReshare) {
      return _buildResharedPostCard(context, myUser);
    } else {
      return _buildOriginalPostCard(context, myUser);
    }
  }

  // --- WIDGET FOR ORIGINAL POSTS ---
  Widget _buildOriginalPostCard(BuildContext context, UserModel myUser) {
    final bool isLiked = post.likes.contains(myUser.uid);
    final int likeCount = post.likes.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(context, post),
            const SizedBox(height: 15),
            Text(post.postText, style: const TextStyle(fontSize: 16)),
            // ... (Image display ka logic wese hi hai)
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                  label: 'Like ($likeCount)',
                  color: isLiked ? CupertinoColors.activeGreen : Colors.grey.shade700,
                  onTap: () => context.read<PostProvider>().likePost(post.postId, myUser.uid, post.likes),
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsScreen(postId: post.postId))),
                ),
                _buildActionButton(
                  icon: Icons.repeat, // Share icon ab 'repeat' hai
                  label: 'Share',
                  onTap: () {
                    // Naya re-share function call karo
                    context.read<PostProvider>().resharePost(post, myUser.uid, myUser.name, myUser.profilePicUrl);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET FOR RE-SHARED POSTS ---
  Widget _buildResharedPostCard(BuildContext context, UserModel myUser) {
    final originalInfo = post.originalPostInfo!;
    final bool isLiked = post.likes.contains(myUser.uid);
    final int likeCount = post.likes.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Re-sharer ki info + 3-dot menu
            Row(
              children: [
                Icon(Icons.repeat, color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 5),
                Expanded(child: Text("${post.authorName} shared this")),
                _buildThreeDotMenu(context, post, myUser.uid),
              ],
            ),
            const Divider(),
            // Original Post ka content aik box ke andar
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostHeader(context, originalInfo),
                  const SizedBox(height: 10),
                  Text(originalInfo.originalPostText, style: const TextStyle(fontSize: 16)),
                  // ... (Original post ki image yahan aa sakti hai)
                ],
              ),
            ),
            const Divider(),
            // Re-shared post par sirf like aur comment ho sakta hai
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                  label: 'Like ($likeCount)',
                  color: isLiked ? CupertinoColors.activeGreen : Colors.grey.shade700,
                  onTap: () => context.read<PostProvider>().likePost(post.postId, myUser.uid, post.likes),
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsScreen(postId: post.postId))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper widget for post header (original ya re-shared post ke liye)
  Widget _buildPostHeader(BuildContext context, dynamic postOrInfo) {
    final myUid = context.read<UserProvider>().user!.uid;
    // Data get karo, chahe PostModel se ya OriginalPostInfo se
    final String authorId = postOrInfo is PostModel ? postOrInfo.authorId : postOrInfo.originalAuthorId;
    final String authorName = postOrInfo is PostModel ? postOrInfo.authorName : postOrInfo.originalAuthorName;
    final String authorProfilePic = postOrInfo is PostModel ? postOrInfo.authorProfilePic : postOrInfo.originalAuthorProfilePic;
    final DateTime datePublished = postOrInfo is PostModel ? postOrInfo.datePublished : postOrInfo.originalDatePublished;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (authorId != myUid) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(uid: authorId)));
              }
            },
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(authorProfilePic), radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat.yMMMd().add_jm().format(datePublished),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 3-dot menu sirf original post par dikhao
        if (postOrInfo is PostModel) _buildThreeDotMenu(context, postOrInfo, myUid),
      ],
    );
  }

  // Helper widget for 3-dot menu
  Widget _buildThreeDotMenu(BuildContext context, PostModel post, String myUid) {
    // Menu sirf tab dikhao jab user author ho
    if (post.authorId != myUid) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz),
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(post: post)));
        } else if (value == 'delete' || value == 'undo_share') {
          context.read<PostProvider>().deletePost(post.postId);
        }
      },
      itemBuilder: (BuildContext context) {
        // Agar post re-shared hai to "Undo Share" ka option do
        if (post.isReshare) {
          return [const PopupMenuItem(value: 'undo_share', child: Text('Undo Share'))];
        }
        // Agar original post hai to "Edit" aur "Delete" ke options do
        return [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ];
      },
    );
  }

  // Helper widget for action buttons
  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    final defaultColor = Colors.grey.shade700;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: color ?? defaultColor),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color ?? defaultColor)),
          ],
        ),
      ),
    );
  }
}