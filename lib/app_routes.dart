import 'package:flutter/material.dart';
import 'package:instagram_clone/auth/auth.screens/auth_manager.screen.dart';

import 'package:instagram_clone/auth/auth.screens/login_screen.dart';
import 'package:instagram_clone/auth/auth.screens/signup_email_otp_screen.dart';
import 'package:instagram_clone/auth/auth.screens/signup_email_screen.dart';
import 'package:instagram_clone/auth/auth.screens/signup_password_screen.dart';
import 'package:instagram_clone/home/home.screen.dart';
import 'package:instagram_clone/posts/posts.screen.dart';

import 'package:instagram_clone/user-profile/user.profile.screen.dart';
import 'package:instagram_clone/videos/videos.screen.dart';

import 'explore/explorer.screen.dart';



class AppRoutes{
  static const String signup = '/signup';
  static const String signupOtpEmail = '/signup-otp-email';
  static const String signupPassword = '/signup-password';
  static const String login = '/login';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String posts = '/posts';
  static const String videos = '/videos';
  static const String userProfile = '/userProfile';


  static const Widget entryScreen = AuthManagerScreen();

static Map<String, WidgetBuilder> getRoutes(){
  return{
    signup:(context) => const SignupEmailScreen(),
    signupOtpEmail:(context) => const SignupEmailOtpScreen(),
    signupPassword:(context) => const SignupPasswordScreen(),
    login:(context) => const LoginScreen(),
    home:(context) => const HomeScreen(),
    explore:(context) => const ExplorerScreen(),
    posts:(context) => const PostsScreen(),
    videos:(context) => const VideosScreen(),
    userProfile:(context) => const UserProfileScreen(),
  };
}
}

