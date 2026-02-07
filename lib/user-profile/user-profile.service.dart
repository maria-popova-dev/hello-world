import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/user-profile/user-profile.dart';
import 'package:uuid/uuid.dart';
import '../cloudinary_service.dart';

class UserProfileService {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final uuid = const Uuid();

  // 0 - Create a function;

  String generateUserName() {
    // 1 - Generate cryptographically strong random number;
    Random _random = Random.secure();

    // 2 - create a string  of random characters;
    String randomString = base64Url.encode(
        List<int>.generate(16, (_) => _random.nextInt(256)));

    // 3 - Create a hash of the randomString using SHA-256

    List<int> bytes = utf8.encode(randomString);
    Digest digest = sha256.convert(bytes);

    String shortHash = digest.toString().substring(0, 8);
    return 'user_$shortHash';
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final firestoreUserProfileDoc = await _firebaseFirestore.collection(
        "user-profiles").doc(uid).get();

    if (firestoreUserProfileDoc.exists) {
      return UserProfile.fromFirestore(firestoreUserProfileDoc);
    }
    return null;
  }

  Future<bool> createUserProfile(UserProfile userProfileData) async {
    try {
      await _firebaseFirestore.collection("user-profiles").doc(
          userProfileData.uid).set(userProfileData.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserProfile>> getUsersByUserNameSearch(String searchText) async {
    if (searchText.isEmpty) return [];

    final lowerCaseSearchText = searchText.toLowerCase();

    try {
      final querySnapshot = await _firebaseFirestore
          .collection("user-profiles")
          .orderBy("userName")
          .where("userName", isGreaterThanOrEqualTo: lowerCaseSearchText)
          .where("userName", isLessThan: '${lowerCaseSearchText}z')
          .get();

      List<DocumentSnapshot> userProfileDocs = querySnapshot.docs;
      List<UserProfile> userProfiles = userProfileDocs.map((userProfileDoc) =>
          UserProfile.fromFirestore(userProfileDoc)).toList();
      return userProfiles;
    } catch (error) {
      return [];
    }
  }


  Future<UserProfile?> updateUserProfile(UserProfile userProfileToUpdate,
      File? newUserAvatarFile) async {
    String userAvatar = userProfileToUpdate.avatar;

    try {
      if (newUserAvatarFile != null) {
        String? newUserAvatarUrl = await uploadNewUserAvatarToStorage(
            newUserAvatarFile);
        if (newUserAvatarUrl != null) {
          userAvatar = newUserAvatarUrl;
        }
      }

      Map<Object, Object?> userProfileToUpdateMap = {
        ...userProfileToUpdate.toMap(),
        "avatar": userAvatar
      };

      await _firebaseFirestore
          .collection("user-profiles")
          .doc(userProfileToUpdate.uid)
          .update(userProfileToUpdateMap);

      UserProfile updatedUserProfile = userProfileToUpdate.copyWith(
          avatar: userAvatar);

      return updatedUserProfile;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> uploadNewUserAvatarToStorage(File newUserAvatarFile) async {
     try {
    print('🖼️ Начинаю загрузку аватара на Cloudinary...');
     print('📁 Путь к файлу: ${newUserAvatarFile.path}');

     // 1. Загружаем на Cloudinary вместо Firebase
     final String? avatarUrl = await CloudinaryService.uploadAvatar(
     newUserAvatarFile.path,
     );

     if (avatarUrl != null) {
     print('✅ Аватар загружен на Cloudinary! URL: ${avatarUrl.substring(0, 50)}...');
     } else {
     print('❌ Не удалось загрузить аватар на Cloudinary');
     }

    return avatarUrl;
     } catch (e) {
     print('🔥 Ошибка при загрузке аватара: $e');
     return null;
     }
  }

  // Future<String?> uploadNewUserAvatarToStorage(File newUserAvatarFile) async {
  //   try {
  //     final String newUserAvatarFileExt = newUserAvatarFile.path
  //         .split(".")
  //         .last
  //         .toLowerCase();
  //     final String newUserAvatarFileName = '${uuid.v4()}.$newUserAvatarFileExt';
  //     final newUserAvatarFileRef = _firebaseStorage
  //         .ref()
  //         .child("user-avatars")
  //         .child(newUserAvatarFileName);
  //     final TaskSnapshot newUserAvatarFileSnapshot = await newUserAvatarFileRef
  //         .putFile(newUserAvatarFile);
  //     final String newUserAvatarUrl = await newUserAvatarFileSnapshot.ref
  //         .getDownloadURL();
  //
  //     return newUserAvatarUrl;
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

  Future<void> toggleFollowStatus({
    required String currentUserId,
    required String followedUserId,
    required bool isCurrentlyFollowing,
  }) async {
    try {
      final currentUserRef = _firebaseFirestore.collection("user-profiles").doc(currentUserId);
      final followedUserRef = _firebaseFirestore.collection("user-profiles").doc(followedUserId);

      await _firebaseFirestore.runTransaction((transaction) async{
        if(isCurrentlyFollowing){
          transaction.update(currentUserRef,{
            "following": FieldValue.arrayUnion([followedUserId]),
            "totalFollowing": FieldValue.increment(1)
          });
          transaction.update(followedUserRef,{
            "following": FieldValue.arrayUnion([followedUserId]),
            "totalFollowing": FieldValue.increment(1)
          });
        }
      });


    } catch (e) {
      print(e);
    }
  }
}