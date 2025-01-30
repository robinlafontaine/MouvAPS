import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/services/video.dart';
import 'package:mouvaps/widgets/content_upload_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/utils/constants.dart';

import '../../../utils/text_utils.dart';
import '../widgets/upload_file_button.dart';

class AdminExercise extends StatefulWidget {
  final Exercise? exercise;

  const AdminExercise({super.key, this.exercise});

  @override
  State<StatefulWidget> createState() {
    return _AdminExerciseState();
  }
}

class _AdminExerciseState extends State<AdminExercise> {
  late Exercise _exercise;
  final ContentUploadService _uploadServiceThumbnail = ContentUploadService(
    directoryPath: 'exercises/thumbnails',
    type: FileType.image,
  );
  final ContentUploadService _uploadServiceVideo = ContentUploadService(
    directoryPath: 'exercises/videos',
    type: FileType.video,
  );
  late VideoController _videoController;

  void _updateExerciseName(String value) {
    setState(() {
      _exercise.name = value;
    });
  }

  void _updateExerciseRewardPoints(String value) {
    setState(() {
      _exercise.rewardPoints = int.parse(value);
    });
  }

  void _updateExerciseDuration(String value) {
    setState(() {
      _exercise.duration = Duration(seconds: int.parse(value));
    });
  }

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise ?? Exercise();

    _videoController = VideoController(
      videoUrl: widget.exercise?.url ?? '',
      isOffline: false,
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _exercise.name ?? 'New Exercise',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      body: _buildExerciseContent(),
      floatingActionButton: _buildSaveFAB(),
    );
  }

  Widget _buildExerciseContent() {
    // Implement the exercise content UI here
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        _buildExerciseThumbnail(),
        _buildExerciseVideo(),
        _buildExerciseName(),
        _buildExerciseRewardPoints(),
        _buildExerciseDuration(),
      ],
    ));
  }

  Widget _buildExerciseThumbnail() {
    return Center(
      child: Column(
        children: [
          if (_exercise.thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image(
                  image: _exercise.thumbnailUrl!.contains("https://")
                      ? NetworkImage(_exercise.thumbnailUrl ?? '')
                      : FileImage(File(_exercise.thumbnailUrl ?? '')),
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 30,
                    );
                  },
                ),
              ),
            )
          else
            UploadFileButton(
                contentUploadService: _uploadServiceThumbnail,
                onUpload: () {
                  setState(() {
                    _exercise.thumbnailUrl =
                        _uploadServiceThumbnail.uploadManager.getFile();
                  });
                })
        ],
      ),
    );
  }

  Widget _buildExerciseVideo() {
    return Center(
      child: Column(
        children: [
          if (_exercise.url != null)
            SizedBox(
              height: 200,
              child: Chewie(controller: _videoController.chewieController),
            )
          else
            UploadFileButton(
                contentUploadService: _uploadServiceVideo,
                onUpload: () {
                  setState(() {
                    _exercise.url = _uploadServiceVideo.uploadManager.getFile();
                  });
                })
        ],
      ),
    );
  }

  Widget _buildExerciseName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const H3(content: "Nom: "),
        ShadInput(
          placeholder: const Text("Nom de la séance"),
          onChanged: _updateExerciseName,
          initialValue: _exercise.name,
        ),
      ],
    );
  }

  Widget _buildExerciseRewardPoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const H3(content: "Points de récompense: "),
        ShadInput(
          placeholder: const Text("Points de récompense"),
          onChanged: _updateExerciseRewardPoints,
          initialValue: _exercise.rewardPoints.toString(),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildExerciseDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const H3(content: "Durée: "),
        ShadInput(
          placeholder: const Text("Durée de la séance"),
          onChanged: _updateExerciseDuration,
          initialValue: _exercise.duration?.inSeconds.toString(),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildSaveFAB() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: primaryColor),
      ),
      onPressed: () async {
        if (_exercise.id == null) {
          await _exercise.create();
        } else {
          await _exercise.update();
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      child: const Icon(FontAwesomeIcons.floppyDisk, color: primaryColor),
    );
  }
}
