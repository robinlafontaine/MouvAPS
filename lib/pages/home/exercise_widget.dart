import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/services/exercise.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  const ExerciseCard({super.key, required this.exercise});


  @override
  State<StatefulWidget> createState() {
    return _ExerciseCardState();
  }
}
//TODO: Resize the image to fit the card
//TODO: Add Duration to card
//TODO: Add Difficulty (depending on pathology) to card
//TODO: Add pop-up for precautions

class _ExerciseCardState extends State<ExerciseCard> {
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Card(
          child: Column(
            children: [
              Image(
                image: AssetImage(widget.exercise.thumbnailUrl),
                errorBuilder:
                    (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return const Image(
                      image: AssetImage('assets/images/default_exercise_image.jpg'));
                },
              ),
              Text(widget.exercise.name),
              Row(
                children: [
                  const Icon(Icons.savings),
                  Text(widget.exercise.rewardPoints.toString())
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
