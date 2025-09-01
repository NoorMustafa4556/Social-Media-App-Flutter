import 'package:cloud_firestore/cloud_firestore.dart';

// Yeh class original post ki info save karegi jab koi usay re-share karega
class OriginalPostInfo {
  final String originalAuthorId;
  final String originalAuthorName;
  final String originalAuthorProfilePic;
  final String originalPostText;
  final String? originalPostImageUrl;
  final DateTime originalDatePublished;

  OriginalPostInfo({
    required this.originalAuthorId,
    required this.originalAuthorName,
    required this.originalAuthorProfilePic,
    required this.originalPostText,
    this.originalPostImageUrl,
    required this.originalDatePublished,
  });

  // Data ko Firestore main save karne ke liye Map (JSON) main convert karna
  Map<String, dynamic> toJson() => {
    'originalAuthorId': originalAuthorId,
    'originalAuthorName': originalAuthorName,
    'originalAuthorProfilePic': originalAuthorProfilePic,
    'originalPostText': originalPostText,
    'originalPostImageUrl': originalPostImageUrl,
    'originalDatePublished': originalDatePublished,
  };

  // Firestore se data read karke object banane ke liye
  factory OriginalPostInfo.fromJson(Map<String, dynamic> json) {
    return OriginalPostInfo(
      originalAuthorId: json['originalAuthorId'],
      originalAuthorName: json['originalAuthorName'],
      originalAuthorProfilePic: json['originalAuthorProfilePic'],
      originalPostText: json['originalPostText'],
      originalPostImageUrl: json['originalPostImageUrl'],
      originalDatePublished: (json['originalDatePublished'] as Timestamp).toDate(),
    );
  }
}


// --- Main Post Model Class ---
class PostModel {
  String postId;
  String authorId; // Post create karne wala (original ya re-sharer)
  String authorName;
  String authorProfilePic;
  String postText; // Re-share ke waqt yeh khali ho sakta hai
  String? postImageUrl; // Re-share ke waqt yeh hamesha null hoga
  DateTime datePublished;
  List likes;
  bool isPublic;

  // --- NAYI FIELDS ---
  bool isReshare; // Yeh batayega ke post re-shared hai ya nahi
  OriginalPostInfo? originalPostInfo; // Agar re-shared hai to original post ki details

  PostModel({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorProfilePic,
    required this.postText,
    this.postImageUrl,
    required this.datePublished,
    required this.likes,
    required this.isPublic,
    this.isReshare = false, // By default har post original hai
    this.originalPostInfo,
  });

  // Data ko Firestore main save karne ke liye
  Map<String, dynamic> toJson() => {
    'postId': postId,
    'authorId': authorId,
    'authorName': authorName,
    'authorProfilePic': authorProfilePic,
    'postText': postText,
    'postImageUrl': postImageUrl,
    'datePublished': datePublished,
    'likes': likes,
    'isPublic': isPublic,
    'isReshare': isReshare,
    'originalPostInfo': originalPostInfo?.toJson(), // Agar null nahi to JSON main convert karo
  };

  // Firestore se data read karke PostModel object banane ke liye
  static PostModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return PostModel(
      postId: snapshot['postId'],
      authorId: snapshot['authorId'],
      authorName: snapshot['authorName'],
      authorProfilePic: snapshot['authorProfilePic'],
      postText: snapshot['postText'],
      postImageUrl: snapshot['postImageUrl'],
      datePublished: (snapshot['datePublished'] as Timestamp).toDate(),
      likes: snapshot['likes'],
      isPublic: snapshot['isPublic'],
      // Agar 'isReshare' field Firestore main nahi hai (purani posts), to usay 'false' maan lo
      isReshare: snapshot['isReshare'] ?? false,
      // Agar 'originalPostInfo' field hai to usko object main convert karo, warna null rehne do
      originalPostInfo: snapshot['originalPostInfo'] != null
          ? OriginalPostInfo.fromJson(snapshot['originalPostInfo'])
          : null,
    );
  }
}