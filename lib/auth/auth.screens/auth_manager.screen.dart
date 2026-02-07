import 'package:flutter/material.dart';
import 'package:instagram_clone/user-profile/user-profile.provider.dart';
import 'package:instagram_clone/auth/auth.screens/login_screen.dart';
import 'package:instagram_clone/auth/auth.screens/signup_email_screen.dart';
import 'package:instagram_clone/home/home.screen.dart';

import 'package:provider/provider.dart';

import '../../user-profile/user-profile.dart';


/*This page manages how the user is routed to the appropriate screen based on their authentification status & it is an entry point for the app.
GO TO SIGNUPPAGE: if user is not registered;
GO TO LOGINPAGE: if user is already registered;
GO TO HOMEPAGE: if user is authenticated;
 */

class AuthManagerScreen extends StatelessWidget {
  const AuthManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<UserProfileProvider>(context);

  return StreamBuilder(
      stream: authProvider.userProfileStream,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          final UserProfile? userAccount = snapshot.data;
          if(userAccount == null){
            return authProvider.hasSignedUpBefore ? LoginScreen() : SignupEmailScreen();
          }
          return const HomeScreen();
         }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
  );


  // return authProvider.hasSignedUpBefore ? LoginScreen() : SignupEmailScreen();


  }
}
