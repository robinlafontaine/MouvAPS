import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mouvaps/pages/exercise/exercise_details_screen.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/services/download.dart';
import 'package:mouvaps/widgets/download_button.dart';
import 'package:mouvaps/utils/constants.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final bool isEnabled;
  final bool isOffline;
  final VoidCallback onWatchedCallback;

  const ExerciseCard(
      {super.key,
      required this.exercise,
      this.isEnabled = true,
      this.isOffline = false,
      required this.onWatchedCallback});

  @override
  State<StatefulWidget> createState() {
    return _ExerciseCardState();
  }
}

class _ExerciseCardState extends State<ExerciseCard> {

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
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
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
              text:
                  '${widget.exercise.duration?.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(widget.exercise.duration?.inSeconds.remainder(60)).toString().padLeft(2, '0')}',
            ),
            _buildInfoRow(
              icon: Icons.payments,
              text: '${widget.exercise.rewardPoints} points',
            ),
          ],
        ),
        trailing: widget.isOffline
            ? const Icon(
                Icons.check_circle_outline,
                color: primaryColor,
              )
            : _buildDownloadButton(),
        onTap: widget.isEnabled
            ? () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExerciseDetailsScreen(
                    exercise: widget.exercise,
                    isOffline: widget.isOffline,
                    isEnabled: widget.isEnabled,
                    onWatchedCallback: widget.onWatchedCallback
                  ),
                ),
              );
              }
            : null,
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 5),
        Text(
          text,
          style: ShadTheme.of(context).textTheme.p,
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return DownloadButton<Exercise>(
      item: widget.exercise,
      itemId: widget.exercise.id!,
      isEnabled: widget.isEnabled && !widget.isOffline,
      downloadRequests: [
        DownloadRequest(
          url: widget.exercise.thumbnailUrl,
          filename: 'e_${widget.exercise.name}_t',
          fileExtension: widget.exercise.thumbnailUrl.split('.').last,
        ),
        DownloadRequest(
          url: widget.exercise.url,
          filename: 'e_${widget.exercise.name}_v',
          fileExtension: widget.exercise.url.split('.').last,
        ),
      ],
      onSave: (paths) async {
        await Exercise.saveLocalExercise(widget.exercise, paths[1], paths[0]);
      }, onDownloadComplete: (T) {  },
    );
  }
}
