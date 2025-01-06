import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';

class CustomFlickControlManager extends StatelessWidget {
  final FlickManager flickManager;

  const CustomFlickControlManager({super.key, required this.flickManager});

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(
      flickManager: flickManager,
      flickVideoWithControls: FlickVideoWithControls(
        controls: FlickPortraitControls(
          progressBarSettings: FlickProgressBarSettings(
            backgroundColor: Colors.grey,
            playedColor: Colors.red,
            bufferedColor: Colors.white,
            handleColor: Colors.red,
          ),
        ),
      ),
    );
  }
}
