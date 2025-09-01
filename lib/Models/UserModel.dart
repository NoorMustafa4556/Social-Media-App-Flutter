import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  String name;
  String username;
  String profilePicUrl;
  final List followers;
  final List following;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.username,
    required this.profilePicUrl,
    required this.followers,
    required this.following,
  });

  // Function to convert UserModel to a Map (JSON) for Firestore
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'name': name,
    'username': username,
    'profilePicUrl': profilePicUrl,
    'followers': followers,
    'following': following,
  };

  // Factory method to create a UserModel from a Firestore DocumentSnapshot
  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot['uid'],
      email: snapshot['email'],
      name: snapshot['name'],
      username: snapshot['username'],
      profilePicUrl: snapshot['profilePicUrl'],
      followers: snapshot['followers'],
      following: snapshot['following'],
    );
  }
}