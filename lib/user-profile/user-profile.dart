import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/user-profile/user-profile.enums.dart';

import '../home/media.dart';

class UserProfile {

  final String uid;
  final String email;
  final String userName;
  final String avatar;
  final String? bio;
  final String? firstName;
  final String? lastName;
  final Gender? gender;
  final String? phoneNumber;
  final String? website;
  final int? totalPosts;
  final int? totalFollowers;
  final int? totalFollowing;
  final List<String> followers;
  final List<String> following;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.userName,
    required this.avatar,
    this.bio,
    this.firstName,
    this.lastName,
    this.gender,
    this.phoneNumber,
    this.website,
    this.totalPosts,
    this.totalFollowers,
    this.totalFollowing,
    this.followers = const [],
    this.following = const [],
    this.createdAt,
    this.updatedAt
  });

  factory UserProfile.fromFirebaseUser(User firebaseUser){
    return UserProfile(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        userName: firebaseUser.displayName!,
        avatar: firebaseUser.photoURL!);
  }

  //method to update specific fields

  UserProfile copyWith({
    String? email,
    String? userName,
    String? avatar,
    String? bio,
    String? firstName,
    String? lastName,
    Gender? gender,
    String? phoneNumber,
    String? website,
    int? totalPosts,
    int? totalFollowers,
    int? totalFollowing,
    List<String>? followers,
    List<String>? following,
    DateTime? createdAt,
    DateTime? updatedAt,
}) {
    return UserProfile(
    uid: this.uid,
    email: email ?? this.email,
    userName: userName ?? this.userName,
    avatar: avatar?? this.avatar,
    bio: bio ?? this.bio,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    gender: gender?? this.gender,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    website: website?? this.website,
    totalPosts: totalPosts ?? this.totalPosts ?? 0,
    totalFollowers: totalFollowers ?? this.totalFollowers ?? 0,
    totalFollowing: totalFollowing ?? this.totalFollowing ?? 0,
    followers: followers ?? this.followers,
    following: following ?? this.following,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
        );
  }

  factory UserProfile.fromFirestore( DocumentSnapshot firestoreUserProfileDoc){
    Map<String, dynamic> firestoreUserProfileData = firestoreUserProfileDoc.data() as Map<String, dynamic>;

    return UserProfile(
        uid: firestoreUserProfileDoc.id,
        email: firestoreUserProfileData["email"],
        userName: firestoreUserProfileData["userName"],
        avatar: firestoreUserProfileData["avatar"],
        bio: firestoreUserProfileData["bio"] ?? "",
        firstName: firestoreUserProfileData["firstName"] ?? "",
        lastName: firestoreUserProfileData["lastName"] ?? "",
        gender: firestoreUserProfileData["gender"]=="female" ? Gender.female : Gender.male,
        phoneNumber: firestoreUserProfileData["phoneNumber"],
        website: firestoreUserProfileData["website"] ??"",
        totalPosts: firestoreUserProfileData["totalPosts"],
        totalFollowers: firestoreUserProfileData["totalFollowers"],
        totalFollowing: firestoreUserProfileData["totalFollowing"],
        followers: List<String>.from(firestoreUserProfileData["followers"] ?? []),
        following: List<String>.from(firestoreUserProfileData["following"] ?? []),
        createdAt: (firestoreUserProfileData ["createdAt"] as Timestamp).toDate(),
        updatedAt: (firestoreUserProfileData ["updatedAt"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap(){
    return{
    "uid": uid,
    "email": email,
    "userName": userName,
    "avatar": avatar,
    "bio": bio ?? "",
    "firstName": firstName ?? "",
    "lastName": lastName ?? "",
    "gender": gender?.toString(),
    "phoneNumber": phoneNumber,
    "website": website ??"",
    "totalPosts":totalPosts ?? 0,
    "totalFollowers":totalFollowers ?? 0,
    "totalFollowing": totalFollowing ?? 0,
    "followers": followers,
    "following": following,
    "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    "updatedAt": updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}

class UserPostMedia {
  final String userId;
  final  Media media;
  final int mediaIndex;

  UserPostMedia({
    required this.userId,
    required this.media,
    required this.mediaIndex
});
}