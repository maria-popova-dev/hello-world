import 'package:flutter/material.dart';
import 'package:instagram_clone/posts/post.service.dart';
import '../app.components/app_bottom_navigation_bar.dart';
import '../app.components/post-list-view.dart';
import '../posts/post.dart';

class UserPostsScreen extends StatelessWidget {
  final String currentUserId;
  final List<String> currentUserFollowing;
  final String userId;
  final int currentScreenIndex;
  final int? currentMediaIndex;

   UserPostsScreen({
     super.key,
     required this.userId,
     required this.currentScreenIndex,
     this.currentMediaIndex,
     required this.currentUserId,
     required this.currentUserFollowing});

  final PostService postService = PostService();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Post>>(
          stream: postService.getPostsByUserId(userId),
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
            return PostListView(
              posts: posts,
              currentScreenIndex: currentScreenIndex,
              postService: postService,
              currentMediaIndex: currentMediaIndex,
              currentUserId: currentUserId,
              currentUserFollowing: currentUserFollowing,
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentScreenIndex,),
    );
  }
}
