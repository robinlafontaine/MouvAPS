import 'package:flutter/material.dart';
import 'package:mouvaps/pages/admin/widgets/admin_content_list.dart';
import 'package:mouvaps/services/exercise.dart';

class ExerciseAdminScreen extends StatefulWidget {
  const ExerciseAdminScreen({super.key});

  @override
  State<ExerciseAdminScreen> createState() => _ExerciseAdminScreenState();
}

class _ExerciseAdminScreenState extends State<ExerciseAdminScreen> {
  late Future<List<Exercise>> _exercices;

  @override
  void initState() {
    super.initState();
    _exercices = Exercise.getAllAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _exercices,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ContentListAdmin(
            exercises: snapshot.data,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
