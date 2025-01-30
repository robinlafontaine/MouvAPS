import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mouvaps/services/video.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:mouvaps/notifiers/user_points_notifier.dart';
import 'package:mouvaps/services/exercise.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final Exercise exercise;
  final bool isOffline;
  final bool isEnabled;
  final VoidCallback onWatchedCallback;

  const ExerciseDetailsScreen(
      {super.key, required this.exercise, this.isOffline = false, required this.isEnabled, required this.onWatchedCallback});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  late VideoController _videoController;
  bool watched = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _videoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoController = VideoController(
      videoUrl: widget.exercise.url,
      isOffline: false,
      autoPlay: false,
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            H1(content: widget.exercise.name),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double width =
                    constraints.maxWidth; // Get the full width of the page
                return Container(
                  width: width,
                  // Set the height equal to the width - appBar height
                  height: width - kToolbarHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.isOffline
                          ? FileImage(File(widget.exercise.thumbnailUrl))
                          : NetworkImage(widget.exercise.thumbnailUrl),
                      fit: BoxFit
                          .cover, // Ensures the image covers the container
                      alignment: Alignment.center,
                    ),
                  ),
                );
              },
            ),
            Container(
              color: lightColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoRow(
                      icon: Icons.payments,
                      text: "${widget.exercise.rewardPoints} points"),
                  _buildInfoRow(
                    icon: Icons.timer,
                    text: widget.exercise.duration!.inSeconds < 60
                        ? "${widget.exercise.duration!.inSeconds} sec"
                        : "${widget.exercise.duration!.inMinutes} min",
                  ),
                ],
              ),
            ),
              const SizedBox(height: 30),
              ShadButton(
                width: double.infinity,
                onPressed: widget.isEnabled ? () async {
                    _openVideo();
                } : null,
                child: const Text("Commencer l'exercice", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildPrecautions(),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildPrecautions() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        H2(content: 'Précautions'),
        P(
          content:
          "Avant de faire du sport, il est essentiel de s'échauffer pendant 5 à 10 minutes pour préparer le corps et éviter les blessures. Assure-toi de porter des vêtements et des chaussures adaptés à l'activité, de rester bien hydraté avant, pendant et après l'effort, et de vérifier ton état de santé, surtout si tu as des conditions particulières (consulte un médecin si nécessaire). Choisis un environnement sécurisé, sans obstacles ni dangers, et commence l'exercice progressivement en augmentant l'intensité petit à petit. Enfin, évite de manger un repas copieux juste avant, mais ne fais pas de sport totalement à jeun.",
        ),
      ],
    );
  }

  Widget _buildInfoRow({IconData? icon, Widget? widget, required String text}) {
    return Row(
      children: [
        if (icon != null) Icon(icon, color: primaryColor, size: 20),
        if (widget != null) widget,
        const SizedBox(width: 5),
        Text(
          text,
          style: ShadTheme.of(context).textTheme.p,
        ),
      ],
    );
  }

  void _openVideo() {
    VideoController videoController = VideoController(
      videoUrl: widget.exercise.url,
      isOffline: widget.isOffline,
    );
    videoController.openFullscreenVideo(context).then((_) {
      videoController.dispose();
    });
    videoController.listenToEnd(() {
      if (!_isDisposed && !watched && widget.isEnabled && !widget.isOffline) {
        Exercise.watched(widget.exercise).then((value) {
          if (mounted) {
            Provider.of<UserPointsNotifier>(context, listen: false)
                .fetchUserPoints();
          }
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
}
