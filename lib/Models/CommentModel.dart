import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String authorId;
  final String authorName;
  final String authorProfilePic;
  final String text;
  final DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.authorId,
    required this.authorName,
    required this.authorProfilePic,
    required this.text,
    required this.timestamp,
  });

  factory CommentModel.fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return CommentModel(
      commentId: data['commentId'],
      authorId: data['authorId'],
      authorName: data['authorName'],
      authorProfilePic: data['authorProfilePic'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'commentId': commentId,
    'authorId': authorId,
    'authorName': authorName,
    'authorProfilePic': authorProfilePic,
    'text': text,
    'timestamp': timestamp,
  };
}