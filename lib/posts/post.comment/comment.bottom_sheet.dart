import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:instagram_clone/posts/post.comment/comment.dart';
import 'package:instagram_clone/posts/post.comment/comment.service.dart';
import 'package:instagram_clone/posts/post.dart';
import 'package:instagram_clone/user-profile/user-profile.provider.dart';


class CommentBottomSheet extends StatefulWidget {
  final Post post;

  const CommentBottomSheet({super.key, required this.post});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final CommentService commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose(){
    super.dispose();
    _commentController.dispose();
  }

  Future<void> _submitComment(String userId) async {
    String comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await commentService.addComment(widget.post.id, userId, comment);

      if(mounted){
        _commentController.clear();
      }

    } catch (error) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
        Text("Error posting comment")));
      }
    } finally {
      if(mounted){
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProfileProvider>().userProfile;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      width: MediaQuery.of(context).size.width,
      child:
      Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 20.0),
          child: Column(
          
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold),),

          
             Expanded(
               child: StreamBuilder<List<Comment>>(
                  stream: commentService.getPostComments(widget.post.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data ?? [];

                    return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(comment.userAvatar),
                                ),
                                const SizedBox(width: 8.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                          Text(timeago.format(comment.createdAt),
                                       style: TextStyle(color: Colors.grey[600],
                                          fontSize: 10.0),),
                                    Text(comment.text,
                          style: const TextStyle(fontSize: 12.0),)
                                  ],
                                )

                              ],
                            ),
                          );
                        }
                    );
                  }
               ),
             ),
                const SizedBox(height: 8.0,),
                Row(
                  children: [
                  if (userProfile?.avatar != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(userProfile!.avatar)
                    ),
                const SizedBox(width: 8.0,),
              Expanded(
                  child: Container(

                    padding: const EdgeInsets.only(left: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(100.0)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(

                              controller: _commentController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                              hintText: "Add a comment...",
                                border: InputBorder.none
                              ),
                              ),
                        ),
                        IconButton(onPressed: () {
                          if(_isSubmitting) return;
                          final userId = userProfile?.uid;
                          if(userId == null) return;
                          _submitComment(userId);

                        }, icon: const Icon(Icons.send))
          
          
                      ],
                    ),
                  ),
                ),
              ],)
            ],

          ),
      )
    );
  }
}
