import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
    required this.updatedAt
  });

  factory Comment.fromFirestore(DocumentSnapshot firestoreCommentDoc, DocumentSnapshot firestoreUserProfileDoc){
    // print('firestoreCommentDoc: ${firestoreCommentDoc.data()}');
    // print('firestoreUserProfileDoc: ${firestoreUserProfileDoc.data()}');

    Map<String, dynamic> firestoreCommentData = firestoreCommentDoc.data() as Map<String, dynamic>;
    Map<String, dynamic> firestoreUserProfileData = firestoreUserProfileDoc.data() as Map<String, dynamic>;

    return Comment(
      id: firestoreCommentDoc.id,
      postId: firestoreCommentData["postId"],
      userId: firestoreUserProfileDoc.id,
      userName: firestoreUserProfileData["userName"],
      userAvatar: firestoreUserProfileData ["avatar"],
      text: firestoreCommentData ["text"],
      createdAt: (firestoreCommentData ["createdAt"] as Timestamp).toDate(),
      updatedAt:  (firestoreCommentData ["updatedAt"] as Timestamp).toDate(),
    );
  }
}