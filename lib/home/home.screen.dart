import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/app.components/post-list-view.dart';
import 'package:instagram_clone/app_constants.dart';
import 'package:instagram_clone/auth/auth.service.dart';
import 'package:instagram_clone/posts/post.dart';
import 'package:instagram_clone/posts/post.service.dart';
import '../app.components/app_bottom_navigation_bar.dart';
import '../services/location_service.dart';
import '../user-profile/user-profile.dart';
import '../user-profile/user-profile.service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserProfileService userProfileService = UserProfileService();
  final AuthService authService = AuthService();
  final PostService postService = PostService();
  final int currentScreenIndex = 0;

  UserProfile? _currentUserProfile;

  @override
  void initState() {
    _getUserProfile();
    super.initState();
  }

  Future<void> _getUserProfile() async{
    try{
      UserProfile? currentUserProfile = await userProfileService.getUserProfile(authService.currentFirebaseUser!.uid);

      if(!mounted) return;

      if(currentUserProfile != null) {
        setState(() {
          _currentUserProfile = currentUserProfile;
        });
      }
    }catch (error){
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        toolbarHeight: 64.0,
        leading: Padding(
              padding: EdgeInsets.only(left: AppConstants.defaultAppPaddingValue),
              child: SvgPicture.asset("assets/app-logos/instagram-clone-logo-text-dark.svg", semanticsLabel: "Text logo",),
        ),
        leadingWidth: 96.0,
        actions: [
          IconButton(
              padding: EdgeInsets.only(right: AppConstants.defaultAppPaddingValue),
              icon: const Icon (CupertinoIcons.heart),
              onPressed:() => print ("Open notifications"),
          )
        ],
      ),
      body: SafeArea(
          child: StreamBuilder<List<Post>>(
            stream: postService.getPosts(),
            builder: (context, snapshot) {
              // WAIT!!!!
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              // ERROR
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(
                    child: Text("Error"));
              }
              // EMPTY - NO POSTS
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text("No posts found"));
              }

              List<Post> posts = snapshot.data!;
              return PostListView(
                  currentUserId: _currentUserProfile!.uid,
                  currentUserFollowing: _currentUserProfile!.followers,
                  posts: posts, currentScreenIndex: currentScreenIndex,
                  postService: postService);
            },),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentScreenIndex),
    );
  }
}
