import 'package:flutter/material.dart';
import 'package:instagram_clone/app.components/post_created_by_details.dart';
import 'package:instagram_clone/posts/post.service.dart';
import '../home/home.components/home-media-slider.dart';
import '../home/home.components/home_post_details_card.dart';
import '../posts/post.dart';

class PostListView extends StatelessWidget {
  final String currentUserId;
  final List<String> currentUserFollowing;
  final List<Post> posts;
  final int currentScreenIndex;
  final int? currentMediaIndex;
  final PostService postService;

   const PostListView({
     super.key,
     required this.posts,
     required this.currentScreenIndex,
     required this.postService,
     this.currentMediaIndex,
     required this.currentUserId,
     required this.currentUserFollowing});

  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  Post post = posts[index];
                  return Card(
                    elevation: 0.0,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            HomeMediaSlider(mediaList: post.media, currentMediaIndex: currentMediaIndex),
                            PostCreatedByDetails(currentUserId:currentUserId, currentUserFollowing: currentUserFollowing, post: post, currentScreenIndex: currentScreenIndex)
                          ],
                        ),
                        HomePostDetailsCard(post: post, postService: postService)
                      ],
                    ),
                  );
                }
            );
  }
}
