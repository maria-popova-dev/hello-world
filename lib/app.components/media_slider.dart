import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/home/media.dart';
import 'package:instagram_clone/posts/post.constant.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MediaSlider extends StatefulWidget {

  final List<Media> mediaList;
  final int? currentMediaIndex;
  final double? height;

  const MediaSlider({super.key, required this.mediaList, this.currentMediaIndex, this.height});

  @override
  State<MediaSlider> createState() => _MediaSliderState();
}

class _MediaSliderState extends State<MediaSlider> {
  int _currentIndex = 0;
  late List<VideoPlayerController?> _videoControllers;
  final Key _videoVisibilityKey = UniqueKey();

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.currentMediaIndex ?? 0;

    _initializeVideoControllers();
    _playCurrentVideo();
  }

  @override
  void dispose(){
    super.dispose();
    for(var controller in _videoControllers){
      controller?.dispose();
    }
  }



  bool mediaValueIsLocalFileUrl(String value)=>value.startsWith(localFileIdentifier);
  File localFile(String value)=>File(value.replaceFirst(localFileIdentifier, ""));

  void _initializeVideoControllers(){
    _videoControllers = widget.mediaList.map((media){
      if(media.type == MediaType.video){
        final videoPlayerController = mediaValueIsLocalFileUrl(media.value)
            ? VideoPlayerController.file(localFile(media.value))
            : VideoPlayerController.networkUrl(Uri.parse(media.value));

        final controller = videoPlayerController
        ..initialize().then((_){
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
        return controller;
      }
    }).toList();
  }

  void _handleVideoVisibilityChange(VisibilityInfo info){
if(info.visibleFraction>0.9){
  _playCurrentVideo();
}else{
  _pauseAllVideos();
}
  }

  void _playCurrentVideo(){
    if (widget.mediaList[_currentIndex].type == MediaType.video){
       _videoControllers[_currentIndex]!.play();
  }
}

  void _pauseAllVideos(){
    for(var controller in _videoControllers){
      controller?.pause();
    }
  }

  @override
  Widget build(BuildContext context){
    return VisibilityDetector(
      key: _videoVisibilityKey,
      onVisibilityChanged: _handleVideoVisibilityChange,
      child: Column(
        children: [
          CarouselSlider(
              items: widget.mediaList.asMap().entries.map((entry){
                int index = entry.key;
                Media media = entry.value;

                return Builder(
                    builder: (BuildContext context){
                      if(media.type == MediaType.image){
                        return mediaValueIsLocalFileUrl(media.value)
                            ? Image.file(localFile(media.value), fit: BoxFit.cover)
                            : Image.network(media.value, fit: BoxFit.cover);
                      }else {
                        return VideoPlayer(_videoControllers[index]!);
                      }
                    }
                );
              }).toList(),
      options: CarouselOptions(
      initialPage: _currentIndex,
      height: widget.height ?? 520.0,
      aspectRatio: 1,
      viewportFraction: 1.0,
      enableInfiniteScroll: false,
      onPageChanged: (index, _){
        setState(() {
          _currentIndex = index;
        });
        _pauseAllVideos();
        _playCurrentVideo();
      }
      )
      ),
      
      if(widget.mediaList.length>1)
        Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.mediaList.asMap().entries.map((entry){
          return Container(
          width: 6.0,
          height: 6.0,
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _currentIndex == entry.key ? Colors.blueAccent : Colors.blueGrey
               ),
             );
           }).toList(),
          ),
         )
        ],
      ),
    );
   }
}

