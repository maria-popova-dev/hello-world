import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/home/media.dart';
import 'package:instagram_clone/posts/post.dart';
import 'package:uuid/uuid.dart';
import '../cloudinary_service.dart';

class PostService{
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final uuid = const Uuid();

  Stream<List<Post>> getPosts() {
    return
      _firebaseFirestore
          .collection("posts")
          .orderBy("createdAt", descending: true)
          .snapshots().asyncMap((snapshot) async {
        List<Post> posts = [];

        for(QueryDocumentSnapshot<Map<String, dynamic>> firestorePostDoc in snapshot.docs) {
          DocumentReference userProfileRef = firestorePostDoc["createdBy"];
          DocumentSnapshot firestoreUserProfileDoc = await userProfileRef.get();
          posts.add(Post.fromFirestore(firestorePostDoc, firestoreUserProfileDoc));
        }
        return posts;
      });
  }



  Stream<List<Post>> getPostsByUserId(String userId) {
    final userRef = _firebaseFirestore.collection("user-profiles").doc(userId);
    return
      _firebaseFirestore
        .collection("posts")
        .where("createdBy", isEqualTo:userRef)
        .orderBy("createdAt", descending: true)
        .snapshots().asyncMap((snapshot) async {
          List<Post> posts = [];
          
      for(QueryDocumentSnapshot<Map<String, dynamic>> firestorePostDoc in snapshot.docs){
        DocumentReference userProfileRef = firestorePostDoc["createdBy"];
        DocumentSnapshot firestoreUserProfileDoc = await userProfileRef.get();
        posts.add(Post.fromFirestore(firestorePostDoc, firestoreUserProfileDoc));
      }
      return posts;
    });
  }
// ЗАМЕНЯЕМ метод _uploadPostMedia:
  Future<Media?> _uploadPostMedia(NewPostMedia newPostMedia) async {
   try {
    print("📤 Загружаю медиа через Cloudinary...");
     String? mediaUrl;
     // Определяем тип и загружаем
     if (newPostMedia.mediaType == MediaType.image) {
     mediaUrl = await CloudinaryService.uploadImage(newPostMedia.file.path);
     } else if (newPostMedia.mediaType == MediaType.video) {
     mediaUrl = await CloudinaryService.uploadVideo(newPostMedia.file.path);
     } else {
     print("❌ Неизвестный тип медиа");
     return null;
     }
     // Проверяем результат
     if (mediaUrl == null || mediaUrl.isEmpty) {
     print("❌ Не удалось загрузить медиа");
     return null;
     }
     print("✅ Медиа загружено! Ссылка: ${mediaUrl.substring(0, 50)}...");
     return Media(
     value: mediaUrl, // НОВАЯ ссылка от Cloudinary!
     type: newPostMedia.mediaType,
     );
     } catch (e) {
     print("❌ Ошибка: $e");
     return null;
     }
  }
  // Future<Media?> _uploadPostMedia(NewPostMedia newPostMedia) async {
  //   try {
  //     final String newPostMediaFileExt = newPostMedia.file.path.split(".").last.toLowerCase();
  //     final String newPostMediaFileName = '${uuid.v4()}.$newPostMediaFileExt';
  //     final newPostMediaRef = _firebaseStorage.ref().child("post-media").child(newPostMediaFileName);
  //     final TaskSnapshot newPostMediaUploadSnapshot = await newPostMediaRef.putFile(newPostMedia.file);
  //     final String newPostMediaFileUrl = await newPostMediaUploadSnapshot.ref.getDownloadURL();
  //     return Media(
  //       value: newPostMediaFileUrl,
  //       type: newPostMedia.mediaType,
  //     );
  //   } catch (e) {
  //     print("❌ Ошибка при загрузке: $e");
  //     return null;
  //   }
  // }


  Future<DocumentReference?> createPost({
    required String userId,
    required String caption,
    required List <NewPostMedia> newPostMediaList,
    Map <String, dynamic>? location,
  }) async {

    print("===начало createPost===");
    print("Полученная локация: $location");

    try {
  // Upload all Media to Storage
      final newMediaList = await Future.wait(
          newPostMediaList.map((newPostMedia) => _uploadPostMedia(newPostMedia))
      );


      final nonNullNewMediaList = newMediaList.whereType<Media>().toList();

      if (nonNullNewMediaList.isEmpty) {
        print("⚠️ Отмена: не удалось загрузить медиа.");
        return null;
      }

      final userRef = _firebaseFirestore.collection("user-profiles").doc(userId);

      final postData = CreatePost(
          createdBy: userRef,
          media: nonNullNewMediaList,
          caption: caption,
          likes: 0,
          shares: 0,
          comments: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          location: location,
      );

      print('postData.toMap(): ${postData.toMap()}');

      DocumentReference postDocumentReference = await _firebaseFirestore.collection("posts").add(postData.toMap());
      return postDocumentReference;
    } catch(error) {
      return null;
    }
  }

  Future<void> updatePost(String postId, Map<String, dynamic> updateData) async {
    try {
      final dataToUpdate = Map<String, dynamic>.from(updateData);
      dataToUpdate["updatedAt"] = Timestamp.now();

      await  _firebaseFirestore.collection("posts").doc(postId).update(dataToUpdate);
    } catch(error) {
      print('Error updating post: $error');
      return;
    }
  }

  Future<void> incrementLikes(String postId) async {
    await updatePost(postId, {
      "Likes": FieldValue.increment(1)
    });
  }

  Future<void> incrementComments(String postId) async {
    await updatePost(postId, {
      "comments": FieldValue.increment(1)
    });
  }

  Future<void> incrementShares(String postId) async {
    await updatePost(postId, {
      "shares": FieldValue.increment(1)
    });
  }
}






















