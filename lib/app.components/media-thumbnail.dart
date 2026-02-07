import 'package:flutter/material.dart';
import 'package:instagram_clone/home/media.dart';
import 'package:instagram_clone/user-profile/user-posts-screen.dart';
import 'package:instagram_clone/user-profile/user-profile.dart';
import 'package:video_player/video_player.dart';


class MediaThumbnail extends StatefulWidget {
  final String currentUserId;
  final List<String> currentUserFollowing;
  final UserPostMedia userPostMedia;
  final int currentScreenIndex;


  const MediaThumbnail({
    super.key,
    required this.userPostMedia,
    required this.currentScreenIndex,
    required this.currentUserId,
    required this.currentUserFollowing,});

  @override
  State<MediaThumbnail> createState() => _GalleryMediaThumbnailState();
}

class _GalleryMediaThumbnailState extends State<MediaThumbnail> {
   VideoPlayerController? _videoController;

  @override
  void initState() {
   if(widget.userPostMedia.media.type == MediaType.video){
_initializeVideo();
   }
    super.initState();
  }

  Future<void> _initializeVideo()async{
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.userPostMedia.media.value)
    );
    await _videoController!.initialize();

    if(mounted){
      setState(() {
        _videoController!.play();
        _videoController!.setVolume(0);
        _videoController!.setLooping(true);
      });
    }
  }

   @override
   void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final mediaSize = screenWidth / 3;

    return InkWell(
          onTap: () =>  Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      UserPostsScreen(
            currentUserId: widget.currentUserId,
            currentUserFollowing: widget.currentUserFollowing,
            userId: widget.userPostMedia.userId,
            currentScreenIndex: widget.currentScreenIndex,
            currentMediaIndex: widget.userPostMedia.mediaIndex,
          ))),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          SizedBox(
          width: mediaSize,
          height: mediaSize,
          child: widget.userPostMedia.media.type == MediaType.image ? Image.network(widget.userPostMedia.media.value, fit: BoxFit.cover) : VideoPlayer(_videoController!),
        ),
          Padding(padding: const EdgeInsets.only(right: 8.0, top: 8.0),
            child: widget.userPostMedia.media.type == MediaType.image ? const Icon(Icons.image, color: Colors.white, size: 16.0) : const Icon(Icons.video_collection, color: Colors.white, size: 16.0)
          ),
      ]),
    );
  }
}
