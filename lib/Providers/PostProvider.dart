import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Models/PostModel.dart';
import 'package:uuid/uuid.dart';


import '../Services/FireStoreServices.dart';

class PostProvider with ChangeNotifier {
  final FireStoreService _fireStoreService = FireStoreService();

  List<PostModel> _posts = [];
  List<PostModel> _userPosts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  List<PostModel> get posts => _posts;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Data Fetching Functions ---

  /// Fetches all public posts for the home feed.
  Future<void> fetchPublicPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _fireStoreService.getPublicPosts();
      _posts = snapshot.docs.map((doc) => PostModel.fromSnap(doc)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all posts for a specific user (for their profile screen).
  Future<void> fetchPostsForUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _fireStoreService.getPostsForUser(uid);
      _userPosts = snapshot.docs.map((doc) => PostModel.fromSnap(doc)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Post Action Functions ---

  /// Creates a new text-only post and saves it to Firestore.
  Future<bool> createTextPost({
    required String authorId,
    required String authorName,
    required String authorProfilePic,
    required String postText,
    required bool isPublic,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      String postId = const Uuid().v1();
      PostModel newPost = PostModel(
        postId: postId, authorId: authorId, authorName: authorName,
        authorProfilePic: authorProfilePic, postText: postText,
        datePublished: DateTime.now(), likes: [], isPublic: isPublic,
      );
      String res = await _fireStoreService.createPost(newPost);
      if (res == "success") return true;
      _errorMessage = res;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Likes or unlikes a post.
  Future<void> likePost(String postId, String myUid, List likes) async {
    try {
      // Optimistic update for instant UI feedback
      final postIndex = _posts.indexWhere((p) => p.postId == postId);
      if (postIndex != -1) {
        if (_posts[postIndex].likes.contains(myUid)) _posts[postIndex].likes.remove(myUid);
        else _posts[postIndex].likes.add(myUid);
      }
      final userPostIndex = _userPosts.indexWhere((p) => p.postId == postId);
      if (userPostIndex != -1) {
        if (_userPosts[userPostIndex].likes.contains(myUid)) _userPosts[userPostIndex].likes.remove(myUid);
        else _userPosts[userPostIndex].likes.add(myUid);
      }
      notifyListeners();

      // Backend update
      await _fireStoreService.likePost(postId, myUid, likes);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Updates an existing post's text and privacy.
  Future<bool> updatePost(String postId, String newText, bool newIsPublic) async {
    try {
      Map<String, dynamic> newData = {'postText': newText, 'isPublic': newIsPublic};
      await _fireStoreService.updatePost(postId, newData);

      // Local state update
      final postIndex = _posts.indexWhere((p) => p.postId == postId);
      if (postIndex != -1) {
        _posts[postIndex].postText = newText;
        _posts[postIndex].isPublic = newIsPublic;
      }
      final userPostIndex = _userPosts.indexWhere((p) => p.postId == postId);
      if (userPostIndex != -1) {
        _userPosts[userPostIndex].postText = newText;
        _userPosts[userPostIndex].isPublic = newIsPublic;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Deletes a post from Firestore and local lists.
  Future<void> deletePost(String postId) async {
    try {
      await _fireStoreService.deletePost(postId);
      _posts.removeWhere((post) => post.postId == postId);
      _userPosts.removeWhere((post) => post.postId == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // --- NAYA RE-SHARE FUNCTION ---
  /// Creates a new 're-shared' post that points to an original post.
  Future<bool> resharePost(PostModel originalPost, String myUid, String myName, String myProfilePic) async {
    _isLoading = true;
    notifyListeners();
    try {
      String newPostId = const Uuid().v1();

      OriginalPostInfo info = OriginalPostInfo(
        originalAuthorId: originalPost.authorId,
        originalAuthorName: originalPost.authorName,
        originalAuthorProfilePic: originalPost.authorProfilePic,
        originalPostText: originalPost.postText,
        originalPostImageUrl: originalPost.postImageUrl,
        originalDatePublished: originalPost.datePublished,
      );

      PostModel resharedPost = PostModel(
        postId: newPostId,
        authorId: myUid,
        authorName: myName,
        authorProfilePic: myProfilePic,
        postText: '',
        datePublished: DateTime.now(),
        likes: [],
        isPublic: true,
        isReshare: true,
        originalPostInfo: info,
      );

      String res = await _fireStoreService.createPost(resharedPost);

      if (res == "success") {
        await fetchPublicPosts();
        await fetchPostsForUser(myUid);
        return true;
      }
      _errorMessage = res;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}