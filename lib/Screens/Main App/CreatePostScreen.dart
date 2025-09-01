import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Providers/PostProvider.dart';
import 'package:social_media_app/Providers/UserProvider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  bool _isPublic = true;
  bool _isPosting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handlePost() async {
    // Validation: Sirf text check karo
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please write something to post.")));
      return;
    }

    setState(() { _isPosting = true; });

    final user = Provider.of<UserProvider>(context, listen: false).user!;
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    // Naya function call karo
    bool success = await postProvider.createTextPost(
      authorId: user.uid,
      authorName: user.name,
      authorProfilePic: user.profilePicUrl,
      postText: _textController.text.trim(),
      isPublic: _isPublic,
    );

    if (mounted) {
      if (success) {
        postProvider.fetchPublicPosts();
        postProvider.fetchPostsForUser(user.uid);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(postProvider.errorMessage ?? "Failed to create post.")));
        setState(() { _isPosting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Create New Post', style: TextStyle(color: Colors.white)),
        backgroundColor: CupertinoColors.activeGreen,
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _handlePost,
            child: const Text('Post', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(user!.profilePicUrl)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        autofocus: true, // Screen khulte hi keyboard aa jaye
                        maxLines: 10, // Ziada likhne ki jaga
                        decoration: const InputDecoration(
                          hintText: "What's on your mind?",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                // 'Add Photo' wala ListTile hata dia gaya hai
                ListTile(
                  leading: Icon(_isPublic ? Icons.public : Icons.lock),
                  title: Text(_isPublic ? 'Public Post' : 'Private Post (Friends Only)'),
                  trailing: Switch(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                    activeColor: CupertinoColors.activeGreen,
                  ),
                ),
              ],
            ),
          ),
          if (_isPosting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text("Posting...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}