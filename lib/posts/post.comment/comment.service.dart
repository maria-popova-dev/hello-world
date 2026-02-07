import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/posts/post.service.dart';

import 'comment.dart';

class CommentService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final PostService _postService = PostService();

  Stream<List<Comment>> getPostComments(String postId){
    return
      _firebaseFirestore
          .collection("comments")
          .orderBy("createdAt", descending:  true)
          .snapshots().asyncMap((snapshot) async {
        List<Comment> comments = [];

        for(QueryDocumentSnapshot<Map<String, dynamic>> firestoreCommentDoc in snapshot.docs){
          DocumentReference userProfileRef = firestoreCommentDoc["userId"];
          DocumentSnapshot firestoreUserProfileDoc = await userProfileRef.get();
          comments.add(Comment.fromFirestore(firestoreCommentDoc, firestoreUserProfileDoc));
        }
        return comments;
      });
  }

  Future<void> addComment (String postId, String userId, String text) async {
    try {
      final commentBatch = _firebaseFirestore.batch();

      final commentRef = _firebaseFirestore.collection("comments").doc();
      commentBatch.set(commentRef,
      {
        "postId": postId,
        "userId": _firebaseFirestore.collection("user-profiles").doc(userId),
        "text": text,
        "createdAt": Timestamp.now(),
        "updatedAt": Timestamp.now(),
      });

      commentBatch.commit();
      
      _postService.incrementComments(postId);

    } catch (error) {
      print("ERROR");
      return;
    }
  }
}