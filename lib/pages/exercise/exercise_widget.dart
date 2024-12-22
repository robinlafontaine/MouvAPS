import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mouvaps/pages/exercise/exercise_download.dart';
import 'package:mouvaps/pages/exercise/precaution_dialog.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/services/video.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:shadcn_ui/shadcn_ui.dart';

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
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isEnabled ? 1.0 : 0.6,
      child: ListTile(
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
                  ? FileImage(File(widget.exercise.thumbnailUrl))
                  : NetworkImage(widget.exercise.thumbnailUrl),
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
          style: ShadTheme.of(context).textTheme.h3,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              icon: Icons.timer,
              text: '${widget.exercise.duration?.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(widget.exercise.duration?.inSeconds.remainder(60)).toString().padLeft(2, '0')}',
            ),
            _buildInfoRow(
              icon: Icons.payments,
              text: '${widget.exercise.rewardPoints} points',
            ),
          ],
        ),
        trailing: widget.isOffline ? const Icon(Icons.check_circle_outline) : ExerciseDownloadButton(exercise: widget.exercise, isEnabled: widget.isEnabled, onDownloadComplete: _onDownloadComplete),
        onTap: widget.isEnabled ? () async {
          final bool confirmed = await showPrecautionDialog(context);
          if (confirmed) {
            _openVideo();
          }
        } : null,
      ),
    );
  }
  void _openVideo() {
    VideoController video = VideoController(
      videoUrl: widget.exercise.url,
      isOffline: widget.isOffline,
    );
    video.openFullscreenVideo(context);
    video.listenToEnd(() {
      if (!_isDisposed && !watched && widget.isEnabled && !widget.isOffline) {
        Exercise.watched(widget.exercise).then((value) {
          if (!_isDisposed) {
            setState(() {
              watched = true;
            });
            widget.onWatchedCallback();
          }
        });
      }
    });
  }

  void _onDownloadComplete(Exercise exercise) {
    if (!_isDisposed) {
      setState(() {
        watched = true;
      });
    }
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: constants.primaryColor, size: 20),
        const SizedBox(width: 5),
        Text(
          text,
          style: ShadTheme.of(context).textTheme.p,
        ),
      ],
    );
  }
}