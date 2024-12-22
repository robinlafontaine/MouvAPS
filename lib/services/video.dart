import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'auth.dart';

class VideoController {
  late ChewieController _chewieController;

  VideoController({
    required String videoUrl,
    required bool isOffline,
    bool requiresAuth = false,
  }) {
    VideoPlayerController videoPlayerController;

    if (isOffline) {
      videoPlayerController = VideoPlayerController.file(File(videoUrl));
    } else {
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: requiresAuth ? {'Authorization': 'Bearer ${Auth.instance.getJwt()}'} : {},
      );
    }

    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      showControls: true,
    );
  }

  ChewieController get chewieController => _chewieController;

  void listenToEnd(VoidCallback callback) {
    _chewieController.videoPlayerController.addListener(() {
      if (_chewieController.videoPlayerController.value.position.inSeconds > 0) {
        if (_chewieController.videoPlayerController.value.position >=
            _chewieController.videoPlayerController.value.duration) {
          callback();
        }
      }
    });
  }

  Future<void> openFullscreenVideo(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffold = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            navigator.pop();
            _chewieController.dispose();
          },
        ),
      ),
      body: Center(
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );

    if (navigator.mounted) {
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => scaffold,
          fullscreenDialog: true,
        ),
      );
    }
  }

  void dispose() {
    _chewieController.dispose();
  }
}