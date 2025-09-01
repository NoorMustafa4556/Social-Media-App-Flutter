import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Models/UserModel.dart';
import 'package:flutter/foundation.dart';

import '../Models/CommentModel.dart';
import '../Models/PostModel.dart';

class FireStoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new user in the 'users' collection
  Future<String> createUserProfile({
    required String uid,
    required String email,
    required String name,
    required String username,
    required String profilePicUrl,
  }) async {
    String res = "Some error occurred";
    try {
      UserModel user = UserModel(
        uid: uid,
        email: email,
        name: name,
        username: username,
        profilePicUrl: profilePicUrl,
        followers: [],
        following: [],
      );

      await _firestore.collection('users').doc(uid).set(user.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
      debugPrint(err.toString());
    }
    return res;
  }
  // FireStoreService ke andar yeh function add karein
  Future<DocumentSnapshot?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  Future<QuerySnapshot> getPublicPosts() async {
    return _firestore
        .collection('posts')
        .where('isPublic', isEqualTo: true) // Sirf public posts
        .orderBy('datePublished', descending: true) // Nayi posts pehle
        .get();
  }

  Future<QuerySnapshot> getPostsForUser(String uid) async {
    return _firestore
        .collection('posts')
        .where('authorId', isEqualTo: uid) // Sirf is user ki posts
        .orderBy('datePublished', descending: true)
        .get();
  }
  // Create a new post in the 'posts' collection
  Future<String> createPost(PostModel post) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(post.postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  // FireStoreService.dart ke andar yeh function add karein

// Update user profile data in the 'users' collection
  Future<String> updateUserProfile(String uid, Map<String, dynamic> data) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('users').doc(uid).update(data);
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  // Update a post
  Future<void> updatePost(String postId, Map<String, dynamic> newData) async {
    await _firestore.collection('posts').doc(postId).update(newData);
  }
  Future<DocumentSnapshot> getPostById(String postId) async {
    return _firestore.collection('posts').doc(postId).get();
  }
  // FireStoreService.dart ke andar yeh function add karein

  Future<void> followUser(String myUid, String followUid) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(myUid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followUid)) {
        // --- Unfollow Logic ---
        // Apni following list se uski ID hatao
        await _firestore.collection('users').doc(myUid).update({
          'following': FieldValue.arrayRemove([followUid])
        });
        // Uski followers list se apni ID hatao
        await _firestore.collection('users').doc(followUid).update({
          'followers': FieldValue.arrayRemove([myUid])
        });
      } else {
        // --- Follow Logic ---
        // Apni following list main uski ID add karo
        await _firestore.collection('users').doc(myUid).update({
          'following': FieldValue.arrayUnion([followUid])
        });
        // Uski followers list main apni ID add karo
        await _firestore.collection('users').doc(followUid).update({
          'followers': FieldValue.arrayUnion([myUid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
  // FireStoreService.dart ke andar

// Fetch details for a list of user IDs
  Future<List<UserModel>> getUsersFromList(List<String> uids) async {
    if (uids.isEmpty) return [];
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: uids)
          .get();
      return querySnapshot.docs.map((doc) => UserModel.fromSnap(doc)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
  // FireStoreService.dart ke andar

// Search for users based on a query string (username)
  Future<List<UserModel>> searchUsers(String query) async {
    // Agar search box khali hai to khali list return karo
    if (query.isEmpty) {
      return [];
    }
    try {
      // Firestore main 'startsWith' jesi query is tarah likhte hain.
      // Yeh 'query' se shuru hone wale saare usernames dhoondega.
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: '${query}z') // 'z' aakhri character hai, is se range ban jati hai
          .limit(10) // Performance ke liye sirf 10 results layeinge
          .get();

      return querySnapshot.docs.map((doc) => UserModel.fromSnap(doc)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
  // FireStoreService.dart ke andar

// Like or Unlike a post
  Future<void> likePost(String postId, String myUid, List likes) async {
    try {
      if (likes.contains(myUid)) {
        // --- Unlike Logic ---
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([myUid])
        });
      } else {
        // --- Like Logic ---
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([myUid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
  // FireStoreService.dart ke andar

// --- COMMENTS RELATED FUNCTIONS ---

// Fetch all comments for a post
  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots(); // Stream use karenge taake comments real-time main update hon
  }

// Add a new comment
  Future<void> addComment(String postId, CommentModel comment) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(comment.commentId)
        .set(comment.toJson());
  }

// Delete a comment
  Future<void> deleteComment(String postId, String commentId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

}