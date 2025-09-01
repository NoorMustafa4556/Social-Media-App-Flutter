import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:social_media_app/Models/CommentModel.dart';
import 'package:social_media_app/Providers/UserProvider.dart';
import 'package:timeago/timeago.dart' as timeago;


import 'package:uuid/uuid.dart';

import '../../Services/FireStoreServices.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  final FireStoreService _fireStoreService = FireStoreService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final user = context.read<UserProvider>().user!;
    String commentId = const Uuid().v1();

    CommentModel newComment = CommentModel(
      commentId: commentId,
      authorId: user.uid,
      authorName: user.name,
      authorProfilePic: user.profilePicUrl,
      text: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    await _fireStoreService.addComment(widget.postId, newComment);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments', style: TextStyle(color: Colors.white)),
        backgroundColor: CupertinoColors.activeGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fireStoreService.getComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final comment = CommentModel.fromSnap(snapshot.data!.docs[index]);
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(comment.authorProfilePic)),
                      title: Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(comment.text),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(timeago.format(comment.timestamp), style: const TextStyle(fontSize: 10)),
                          if (comment.authorId == user.uid) // Sirf comment ke author ko delete icon dikhao
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _fireStoreService.deleteComment(widget.postId, comment.commentId),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Comment Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(user.profilePicUrl)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: 'Write a comment...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: CupertinoColors.activeGreen),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}