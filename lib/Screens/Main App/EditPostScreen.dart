import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Models/PostModel.dart';
import 'package:social_media_app/Providers/PostProvider.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _textController;
  late bool _isPublic; // Naya state variable jo privacy ko track karega
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Shuruaati values post se set karo
    _textController = TextEditingController(text: widget.post.postText);
    _isPublic = widget.post.isPublic;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post cannot be empty.')));
      return;
    }
    setState(() { _isLoading = true; });

    // --- YAHAN HAI ASAL CHANGE ---
    // Ab hum naye, updated function ko call karenge 3 values ke saath
    bool success = await Provider.of<PostProvider>(context, listen: false)
        .updatePost(
      widget.post.postId,
      _textController.text.trim(),
      _isPublic, // Nayi privacy value yahan se pass hogi
    );

    if (mounted) {
      if (success) {
        // Update successful hone ke baad 2 baar pop karo
        // Pehla pop EditScreen ko band karega
        // Doosra pop PostDetailScreen ko band karega, taake user seedha feed par aa jaye
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update post')));
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post', style: TextStyle(color: Colors.white)),
        backgroundColor: CupertinoColors.activeGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleUpdate,
            child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column( // Column use karenge taake TextField ke neeche Switch daal sakein
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: null, // Unlimited lines
                expands: true, // Poori available jaga le lo
                decoration: const InputDecoration(
                  hintText: 'Edit your post...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // --- PRIVACY CHANGE KARNE WALA NAYA WIDGET ---
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
    );
  }
}