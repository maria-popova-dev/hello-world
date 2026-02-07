import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/home/media.dart';
import 'package:instagram_clone/videos/videos.util.dart';
import 'package:video_player/video_player.dart';

class VideoMediaSlider extends StatefulWidget {
  final List<Media> videoMediaList;

  const VideoMediaSlider({super.key, required this.videoMediaList});

  @override
  State<VideoMediaSlider> createState() => _VideoMediaSliderState();
}

class _VideoMediaSliderState extends State<VideoMediaSlider> {
  int _currentIndex = 0;
  late List<VideoPlayerController?> _videoControllers;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
  }

  Future<void> _initializeVideoControllers() async {
    _videoControllers = [];

    for (var videoMedia in widget.videoMediaList) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoMedia.value));
      await controller.initialize();
      controller.setVolume(1.0);
      _videoControllers.add(controller);
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      _playCurrentVideo();
    }
  }

  void _playCurrentVideo() {
    final controller = _videoControllers[_currentIndex];
    if (controller != null && controller.value.isInitialized) {
      controller.setVolume(1.0);
      controller.setLooping(false);
      controller.play();
    }
  }

  void _pauseAllVideos() {
    for (var controller in _videoControllers) {
      controller?.pause();
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _videoControllers.length != widget.videoMediaList.length) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        CarouselSlider(
          items: widget.videoMediaList.asMap().entries.map((entry) {
            int index = entry.key;

            return Builder(
              builder: (BuildContext context) {
                final controller = _videoControllers[index];

                if (!controller!.value.isInitialized) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                    VideoProgressIndicator(controller, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.white)),
                  ],
                );
              },
            );

          }).toList(),
          options: CarouselOptions(
            initialPage: _currentIndex,
            height: videoDisplayHeight(context),
            aspectRatio: 1,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            onPageChanged: (index, _) {
              setState(() {
                _currentIndex = index;
              });
              _pauseAllVideos();
              _playCurrentVideo();
            },
          ),
        ),
        if(widget.videoMediaList.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.videoMediaList.asMap().entries.map((entry) {
                return Container(
                  width: 6.0,
                  height: 6.0,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key ? Colors.blueAccent : Colors.blueGrey,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}







