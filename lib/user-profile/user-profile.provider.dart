import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/auth/auth.service.dart';
import 'package:instagram_clone/user-profile/user-profile.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user-profile.dart';


class UserProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserProfileService _userProfileService = UserProfileService();

  UserProfile? _userProfile;
  late SharedPreferences _sharedPreferences;
  String hasSignedUpBeforeStatusKey = "has-signed-up-before";
  String _email = "";
  bool _hasSignedUpBefore = false;

  StreamSubscription<User?>? _authStateSubscription;

  String get email => _email;
  UserProfile? get userProfile => _userProfile;
  bool get hasSignedUpBefore => _hasSignedUpBefore;

  UserProfileProvider() {
    _initializeSharedPreferences();
    _initializeAuthStateListener();
  }

  void _initializeAuthStateListener() {
    _authStateSubscription =
        _authService.firebaseUser.listen((User? firebaseUser) async {
          if (firebaseUser != null) {
            try {
              _userProfile =
              await _userProfileService.getUserProfile(firebaseUser.uid);
            } catch (error) {
              // Handle errors
            }
          } else {
            _userProfile = null;
          }
          notifyListeners();
        });
  }

  Future<void> _initializeSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _loadHasSignedUpBeforeStatus();
  }

  Future<void> setHasSignedUpBefore() async {
    await _sharedPreferences.setBool(hasSignedUpBeforeStatusKey, true);
    notifyListeners();
  }

  Future<void> _loadHasSignedUpBeforeStatus() async {
    final bool hasSignedUpBeforeStatus = _sharedPreferences.getBool(
        hasSignedUpBeforeStatusKey) ?? false;
    _hasSignedUpBefore = hasSignedUpBeforeStatus;
    notifyListeners();
  }

  Stream<UserProfile?> get userProfileStream => _authService.firebaseUser.map((firebaseUser) => firebaseUser != null ? UserProfile(uid: firebaseUser.uid,
          email: firebaseUser.email!,
          userName: firebaseUser.displayName!,
          avatar: firebaseUser.photoURL!
  )  : null);

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setUserProfile(UserProfile userProfile) {
    _userProfile = userProfile;
    notifyListeners();
  }

  Future<AuthServiceResponse<UserProfile>> signupWithEmailAndPassword(String password) async {
    final authServiceResponse = await _authService.signupWithEmailAndPassword(_email, password);
    User ? firebaseUser = authServiceResponse.data;

    if (firebaseUser != null) {
      String defaultUserName = _userProfileService.generateUserName();
      String avatarName = firebaseUser.email!.substring(0, 3);
      String randomAvatar = 'https://ui-avatars.com/api/?background=random&name=$avatarName';
      User? updatedFirebaseUser = await _authService.updateAuthCurrentUser(defaultUserName, randomAvatar);

      setHasSignedUpBefore();
      _userProfile = UserProfile.fromFirebaseUser(updatedFirebaseUser ?? firebaseUser);

      await _userProfileService.createUserProfile(_userProfile!.copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now()));

      notifyListeners();

      return AuthServiceResponse(data: _userProfile);
    }
    return AuthServiceResponse(errorMessage: authServiceResponse.errorMessage);
  }

  Future<AuthServiceResponse<UserProfile>> loginWithEmailAndPassword(String email, String password) async {
    final authServiceResponse = await _authService.loginWithEmailAndPassword(email, password);
    User ? firebaseUser = authServiceResponse.data;

    if (firebaseUser != null) {
      _userProfile = UserProfile.fromFirebaseUser(firebaseUser);
      notifyListeners();
      return AuthServiceResponse(data: _userProfile);
    }
    return AuthServiceResponse(errorMessage: authServiceResponse.errorMessage);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}