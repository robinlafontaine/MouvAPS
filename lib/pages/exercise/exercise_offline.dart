import 'package:flutter/material.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/pages/exercise/exercise_widget.dart';

class ExerciseOffline extends StatefulWidget {
  const ExerciseOffline({super.key});

  @override
  State<ExerciseOffline> createState() => _ExerciseOfflineState();
}

class _ExerciseOfflineState extends State<ExerciseOffline> with WidgetsBindingObserver {
  late Future<List<Exercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = Exercise.getLocalExercises();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2(content: 'Séances'),
              if (snapshot.data!.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: (snapshot.data!.length),
                  itemBuilder: (context, index) {
                    return ExerciseCard(exercise: snapshot.data![index], isOffline: true, onWatchedCallback: _refresh);
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(indent: 15, endIndent: 15,);
                  },
                )
              else
                const Center(child: P(content: 'Aucune séance téléchargée pour le moment.'))
            ],
          );
        }
      },
    );
  }

  void _refresh() async {
    setState(() {
      _exercisesFuture = Exercise.getLocalExercises();
    });
  }
}