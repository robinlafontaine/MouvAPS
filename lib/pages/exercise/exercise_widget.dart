import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mouvaps/pages/exercise/exercise_download.dart';
import 'package:mouvaps/pages/exercise/precaution_dialog.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/services/video_controller.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final bool isEnabled;
  final bool isOffline;
  final VoidCallback onWatchedCallback;
  const ExerciseCard({super.key, required this.exercise, this.isEnabled = true, this.isOffline = false, required this.onWatchedCallback});

  @override
  State<StatefulWidget> createState() {
    return _ExerciseCardState();
  }
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool watched = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: widget.isEnabled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image(
          image: widget.isOffline
              ? FileImage(File(widget.exercise.thumbnailUrl)) as ImageProvider
                : NetworkImage(widget.exercise.thumbnailUrl) as ImageProvider,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Image.asset(
              'assets/images/default_exercise_image.jpg',
              fit: BoxFit.cover,
          );
        },
      ),
        ),
      ),
      title: Text(
        widget.exercise.name,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.timer_outlined,
            text: '${widget.exercise.duration?.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(widget.exercise.duration?.inSeconds.remainder(60)).toString().padLeft(2, '0')}',
          ),
          _buildInfoRow(
            icon: Icons.stars_outlined,
            text: '${widget.exercise.rewardPoints} points',
          ),
        ],
      ),
      trailing: widget.isOffline ? const Icon(Icons.check_circle_outline) : DownloadButton(exercise: widget.exercise, onDownloadComplete: _onDownloadComplete),
      onTap: () async {
        final bool confirmed = await showPrecautionDialog(context);
        if (confirmed) {
          _openVideo();
        }

      },
    );
  }
  void _openVideo() {
    VideoController video = VideoController(
      videoUrl: widget.exercise.url,
    );
    video.openFullscreenVideo(context);
    video.listenToEnd(() {
      if (!watched) {
        Exercise.watched(widget.exercise).then((value) {
          setState(() {
            watched = true;
          });
          widget.onWatchedCallback();
          });
      }
    });
  }

  void _onDownloadComplete(Exercise exercise) {
    print('!!!!!!!!!!!!!!!!Download complete');
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 18),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}