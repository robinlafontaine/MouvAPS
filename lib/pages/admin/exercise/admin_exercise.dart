import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../services/exercise.dart';

class AdminExercise extends StatefulWidget {
  final Exercise? exercise;
  final bool? newExercise;

  const AdminExercise({super.key, this.exercise, this.newExercise})
      : assert(exercise != null || newExercise != null,
            'exercise or newExercise must be provided');

  @override
  State<StatefulWidget> createState() {
    return _AdminExerciseState();
  }
}

class _AdminExerciseState extends State<AdminExercise> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exercise != null ? widget.exercise!.name : 'New Content',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      body: _buildExerciseContent(),
    );
  }

  Widget _buildExerciseContent() {
    // Implement the exercise content UI here
    return const Center(child: Text('Exercise Content'));
  }
}
