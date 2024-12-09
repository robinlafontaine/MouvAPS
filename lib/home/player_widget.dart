import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/home/custom_flick_control_manager.dart';
import 'package:video_player/video_player.dart';

import '../services/auth.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Uri url;
  final bool requiresAuth;
  const VideoPlayerWidget({super.key, required this.url, this.requiresAuth = false});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late FlickManager flickManager;
  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
          widget.url,
          httpHeaders: widget.requiresAuth ? {'Authorization': 'Bearer ${Auth.instance.getJwt()}'} : {}),
      autoPlay: false,
      onVideoEnd: () {
        logger.i('Video ended via onVideoEnd');
      },
    );

    flickManager.flickVideoManager!.videoPlayerController
        ?.addListener(_videoListener);
  }

  void _videoListener() {
    final controller = flickManager.flickVideoManager!.videoPlayerController;
    if (controller!.value.isPlaying &&
        controller.value.position == Duration.zero) {
      // Video started
      logger.i('Video started');
    } else if (controller.value.position == controller.value.duration) {
      // Video ended
      logger.i('Video ended');
    }
  }

  @override
  void dispose() {
    flickManager.flickVideoManager!.videoPlayerController
        ?.removeListener(_videoListener);
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFlickControlManager(flickManager: flickManager);
  }
}
