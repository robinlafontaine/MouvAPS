import 'package:flutter/material.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/services/video_controller.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final bool isEnabled;
  final bool isAdmin;
  const ExerciseCard({super.key, required this.exercise, this.isEnabled = true, this.isAdmin = false});

  @override
  State<StatefulWidget> createState() {
    return _ExerciseCardState();
  }
}

class _ExerciseCardState extends State<ExerciseCard> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: widget.isEnabled,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image(
            image: NetworkImage(widget.exercise.thumbnailUrl),
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
      trailing: IconButton(
    icon: Icon(widget.isAdmin ? Icons.edit_outlined : Icons.download_outlined, size: 30),
    onPressed: () {
    if (widget.isAdmin) {
    //TODO: Handle edit
    } else {
    //TODO: Handle download
    }
    },
    ),
    onTap: () {
      VideoController(
        videoUrl: widget.exercise.url,
      ).openFullscreenVideo(context);
    },
    );
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