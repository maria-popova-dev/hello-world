import 'package:flutter/material.dart';
import 'package:instagram_clone/home/home.components/home_post_details_card.dart';
import 'package:instagram_clone/posts/post.dart';
import 'package:instagram_clone/posts/post.service.dart';
import 'package:instagram_clone/videos/videos.media_slider.dart';
import 'package:instagram_clone/videos/videos.util.dart';
import '../app.components/post_created_by_details.dart';

class VideosPostListView extends StatelessWidget {
  final String currentUserId;
  final List<String> currentUserFollowing;
  final List<PostVideo> postVideos;
  final int currentScreenIndex;

  VideosPostListView({
    super.key,
    required this.postVideos,
    required this.currentScreenIndex,
    required this.currentUserId,
    required this.currentUserFollowing});

  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: postVideos.length,
        itemBuilder: (context, index){
        PostVideo postVideo = postVideos[index];
        Post post = postVideo.post;

        return Stack(
          children: [
            VideoMediaSlider(videoMediaList: postVideo.videoMedia),
            SizedBox(
              height: videoDisplayHeight(context),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  PostCreatedByDetails(
                    post: postVideo.post,
                    currentScreenIndex: currentScreenIndex,
                    currentUserId: currentUserId,
                    currentUserFollowing: currentUserFollowing,
                  ),
                  HomePostDetailsCard(
                    post: post,
                    postService: _postService,
                    colorStyle: ColorStyle.light,)
                ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
