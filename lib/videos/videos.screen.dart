import 'package:flutter/material.dart';
import 'package:instagram_clone/auth/auth.service.dart';
import 'package:instagram_clone/posts/post.dart';
import 'package:instagram_clone/posts/post.service.dart';
import 'package:instagram_clone/user-profile/user-profile.service.dart';
import 'package:instagram_clone/videos/videos.post-list-view.dart';
import '../home/media.dart';
import '../user-profile/user-profile.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final PostService postService = PostService();
  final AuthService authService = AuthService();
  final UserProfileService userProfileService = UserProfileService();
  UserProfile? _currentUserProfile;

  @override
  void initState(){
    _getUserProfile();
    super.initState();
  }

  Future<void> _getUserProfile() async{
    try{
      UserProfile? currentUserProfile = await userProfileService.getUserProfile(authService.currentFirebaseUser!.uid);
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
                return const Center(child: Text("Error"));
              }
              // EMPTY - NO POSTS
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No posts found"));
              }

              List<Post> posts = snapshot.data!;

              List<PostVideo> postVideos = posts.map((post){
                return PostVideo(
                    post: post,
                    videoMedia: post.media.where((mediaItem) => mediaItem.type == MediaType.video).toList()
                );
              }).toList();

              return VideosPostListView(
                postVideos: postVideos.where((postVideo) => postVideo.videoMedia.isNotEmpty).toList(),
                currentScreenIndex: 3,
                currentUserId: _currentUserProfile!.uid,
                currentUserFollowing: _currentUserProfile!.followers,
              );
            },
          ),
      ),
    );
  }
}
