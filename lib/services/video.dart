import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'auth.dart';

class VideoController {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  VideoController({
    required String videoUrl,
    required bool isOffline,
    bool requiresAuth = false,
    bool autoPlay = true,
  }) {
    if (isOffline) {
      _videoPlayerController = VideoPlayerController.file(File(videoUrl));
    } else {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: requiresAuth
            ? {'Authorization': 'Bearer ${Auth.instance.getJwt()}'}
            : {},
      );
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: autoPlay,
      looping: false,
      showControls: true,
    );
  }

  ChewieController get chewieController => _chewieController;

  void listenToEnd(VoidCallback callback) {
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position.inSeconds > 0) {
        if (_videoPlayerController.value.position >= _videoPlayerController.value.duration) {
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
            _videoPlayerController.pause(); // Pause the video before popping
            navigator.pop();
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
    _videoPlayerController.pause();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }
}