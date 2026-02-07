import 'package:flutter/material.dart';
import 'package:instagram_clone/posts/post.comment/comment.bottom_sheet.dart';
import 'package:instagram_clone/posts/post.service.dart';

import '../../posts/post.dart';

import 'package:intl/intl.dart';

import '../../util/numbers.dart';

enum ColorStyle {dark, light}

class HomePostDetailsCard extends StatelessWidget {
  final Post post;
  final PostService postService;
  final ColorStyle colorStyle;

  const HomePostDetailsCard({super.key, required this.post, required this.postService, this.colorStyle = ColorStyle.dark});

  @override
  Widget build(BuildContext context) {
    final Color color = colorStyle == ColorStyle.dark ? Colors.black : Colors.white;
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Row(
                    children: [
             HomePostDetailsStatistics(icon: Icons.favorite_outline, statValue: post.likes, color: color, onTap: () => postService.incrementLikes(post.id)),
             const SizedBox(width: 12.0,),
             HomePostDetailsStatistics(icon: Icons.chat_bubble_outline, statValue: post.comments, color: color, onTap: () => {
               showModalBottomSheet(
                   context: context,
                   isScrollControlled: true,
                   builder: (context) => CommentBottomSheet(post: post))
             }),
             const SizedBox(width: 12.0,),
             HomePostDetailsStatistics(icon: Icons.send_outlined, statValue: post.shares, color: color, onTap: () => postService.incrementShares(post.id)),
                    ],
             ),
             Icon(Icons.bookmark_border_outlined, color: color)
           ],
         ),
          const SizedBox(height: 12.0),
          Text.rich(
            style: const TextStyle(fontSize: 12.0),
            TextSpan(
              children: [
                TextSpan(text: "${post.userName}", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                TextSpan(text: post.caption, style: TextStyle(color: color))
              ]
            )
          ),
if(post.location != null && post.location! ['address'] != null)
  Padding(padding: const EdgeInsets.only(top: 4.0),
  child: Row(
    children: [
      const Icon(Icons.location_on, size: 12, color: Colors.grey),
      const SizedBox(width: 4),
      Expanded(child: Text(post.location! ['address']!,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.grey,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      ),
      ),
    ],
  ),
  ),
Text(DateFormat("MMMM dd yyyy").format(post.createdAt), style: TextStyle(fontSize: 10.0, color: colorStyle == ColorStyle.dark ? Colors.grey : Colors.white70))
          
        ],
      ),
    );
  }
}

class HomePostDetailsStatistics extends StatelessWidget {
  final IconData icon;
  final int statValue;
  final VoidCallback? onTap;
  final Color color;

   const HomePostDetailsStatistics({super.key, required this.icon, required this.statValue, this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color,),
          Text(shortenNumber(statValue), style: TextStyle(fontSize: 10.0, color: color),)
        ],),
    );
  }
}

