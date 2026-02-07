import 'package:flutter/material.dart';
import '../posts/post.dart';
import '../user-profile/user-page-screen.dart';
import 'app_follow_button.dart';

class PostCreatedByDetails extends StatelessWidget {
  final String currentUserId;
  final List<String> currentUserFollowing;
  final Post post;
  final int currentScreenIndex;

  const PostCreatedByDetails(
      {super.key,
        required this.post,
        required this.currentScreenIndex,
        required this.currentUserId,
        required this.currentUserFollowing});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) =>
              UserPageScreen
                (currentScreenIndex: currentScreenIndex,
                userId: post.userId,
                userName: post.userName,
              ))),
      child: Row(
        children: [
          SizedBox(
            width: 28.0,
            height: 28.0,
            child: CircleAvatar(
              backgroundImage: NetworkImage(post.userAvatar),
            ),
          ),
          const SizedBox(width: 12.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.userName, style: const TextStyle(fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
              const Text("Suggested for you",
                style: TextStyle(fontSize: 10.0, color: Colors.white),)
            ],)
        ],
      ),
    ),
    Row(children: [
      AppFollowButton(
        currentUserId: currentUserId,
        followedUserId: post.userId,
        isCurrentlyFollowing: currentUserFollowing.contains(currentUserId)),
      const SizedBox(width: 16.0,),
      const Icon(Icons.more_horiz, color: Colors.white,)
           ],)
          ],
         ),
        ),
     );
  }
}




