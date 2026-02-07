import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/home/media.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final List <Media> media;
  final String caption;
  final int likes;
  final int shares;
  final int comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? location;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.media,
    required this.caption,
    required this.likes,
    required this.shares,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
    this.location,
  });

  factory Post.fromFirestore(DocumentSnapshot firestorePostDoc, DocumentSnapshot firestoreUserProfileDoc) {

    Map<String, dynamic> firestorePostData = firestorePostDoc.data() as Map<String, dynamic>;
    Map<String, dynamic> firestoreUserProfileData = firestoreUserProfileDoc.data() as Map<String, dynamic>;

    List<Media> media = (firestorePostData["media"] as List).map((media) => Media.fromMap(media as Map<String, dynamic>)).toList();


    return Post(
      id: firestorePostDoc.id,
      userId: firestoreUserProfileDoc.id,
      userName: firestoreUserProfileData["userName"],
      userAvatar: firestoreUserProfileData["avatar"],
      media: media,
      caption: firestorePostData["caption"],
      likes: firestorePostData["Likes"],
      shares: firestorePostData["shares"],
      comments: firestorePostData["comments"],
      createdAt: (firestorePostData["createdAt"] as Timestamp).toDate(),
      updatedAt: (firestorePostData["updatedAt"] as Timestamp).toDate(),
      location: firestorePostData["location"] != null
        ? Map<String, dynamic>.from(firestorePostData["location"])
        : null,
    );
  }
}

class NewPostMedia {
  final File file;
  final MediaType mediaType;

  NewPostMedia({
    required this.file,
    required this.mediaType
  });
}

class CreatePost {
  final DocumentReference createdBy;
  final List<Media> media;
  final String caption;
  final int likes;
  final int shares;
  final int comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? location;

  CreatePost({
    required this.createdBy,
    required this.media,
    required this.caption,
    required this.likes,
    required this.shares,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
    this.location,
  });

  Map<String, dynamic> toMap() => {
    "createdBy": createdBy,
    "media": media.map((mediaItem) => (mediaItem.toMap())).toList(),
    "caption": caption,
    "Likes": likes,
    "shares": shares,
    "comments": comments,
    "createdAt": Timestamp.fromDate(createdAt),
    "updatedAt": Timestamp.fromDate(updatedAt),
    "location": location,
  };
}
class PostVideo {
  final Post post;
  final List<Media> videoMedia;

  PostVideo ({
    required this.post, required this.videoMedia
});
}


